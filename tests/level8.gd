extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await physics_frame
func release() -> void:
	for action in ["move_left","move_right","jump"]: Input.action_release(action)
func run() -> void:
	var maps = load("res://levels/maps.gd")
	check(maps.get_level(7).get("name","") == "THE HIGH ROAD","Eighth room exists as a distinct placement puzzle")
	if maps.get_level(7).get("name","") != "THE HIGH ROAD":
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(7)
	await frames(4)
	for setting in [Vector2(90,430),Vector2(80,420),Vector2(95,440),Vector2(160,430)]:
		game.start_level(7)
		await frames(4)
		var blue := Vector2(100,setting.x)
		var red := Vector2(setting.y,480)
		check(game.portals.shoot(game.gun_origin(),blue,1),"Wall exit is visible before movement: " + str(setting))
		check(game.portals.shoot(game.gun_origin(),red,0),"Floor entry is visible before movement: " + str(setting))
		Input.action_press("move_right")
		var crossed := false
		var cleared := false
		var landed := false
		var max_speed := 0.0
		for i in 650:
			await physics_frame
			crossed = crossed or game.transfers > 0
			cleared = cleared or game.player.position.x > 660 and game.player.position.y < 335
			landed = landed or game.player.is_on_floor() and game.player.position.x > 710 and absf(game.player.position.y - 385) < 1
			max_speed = maxf(max_speed,game.player.velocity.x)
			if game.state == "won" or game.deaths > 0: break
		release()
		print("ROOM8_ROUTE ",setting," crossed=",crossed," cleared=",cleared," landed=",landed," speed=",max_speed," end=",game.player.position," deaths=",game.deaths)
		check(crossed,"Prepared portals are traversed with movement input")
		if setting.x < 125:
			check(cleared and landed and game.state == "won" and game.deaths == 0,"High exit clears the obstacle and lands at the goal without midair shots or jumping")
		else:
			check(not cleared and game.state != "won","Low exit demonstrates why placement height matters")
	game.start_level(7)
	await frames(4)
	game.portals.shoot(game.gun_origin(),Vector2(100,90),1)
	game.portals.shoot(game.gun_origin(),Vector2(430,480),0)
	var retry := InputEventKey.new()
	retry.pressed = true
	retry.physical_keycode = KEY_R
	game._unhandled_input(retry)
	await frames(50)
	check(game.player.position.distance_to(game.player.spawn) < 1 and game.transfers == 0,"Eighth retry restores the starting ledge")
	check(game.portals.doors[0].is_empty() and game.portals.doors[1].is_empty(),"Eighth retry clears both prepared portals")
	game.start_level(7)
	await frames(4)
	Input.action_press("move_right")
	Input.action_press("jump")
	await frames(50)
	Input.action_release("jump")
	await frames(250)
	release()
	check(game.state != "won","Ordinary jumping cannot bypass the placement puzzle")
	await game.drain_audio()
	paused = false
	game.queue_free()
	await process_frame
	print("LEVEL8_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
