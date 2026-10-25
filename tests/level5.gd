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
	check(maps.get_level(4).get("name","") == "THE FINAL RELAY","Fifth map exists and is distinct")
	if maps.get_level(4).get("name","") != "THE FINAL RELAY":
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for delay in [0,20,40]:
		game.start_level(4)
		await frames(4 + delay)
		check(game.enemy != null and game.enemy.position.y == 373,"Fifth room creates its own guard on the correct platform")
		check(game.portals.shoot(game.gun_origin(),Vector2(120,90),1),"Wall portal is shootable from starting ledge")
		Input.action_press("move_right")
		var floor_placed := false
		var launched := false
		var max_speed := 0.0
		var jump_hold := 0
		for i in 720:
			await physics_frame
			if not launched:
				if not floor_placed and game.player.position.x > 344:
					floor_placed = game.portals.shoot(game.gun_origin(),Vector2(440,470),0)
				if game.player.position.x > 384 and game.player.velocity.x > 15:
					Input.action_release("move_right")
					Input.action_press("move_left")
				if game.player.position.x > 384 and absf(game.player.velocity.x) < 15:
					Input.action_release("move_left")
				if game.transfers > 0:
					launched = true
					release()
					Input.action_press("move_right")
			else:
				if game.player.is_on_floor() and not Input.is_action_pressed("jump") and game.player.position.x > 660:
					Input.action_press("jump")
					jump_hold = 50
				elif jump_hold > 0: jump_hold -= 1
				else: Input.action_release("jump")
				if game.player.position.x > 910:
					Input.action_release("move_right")
					Input.action_press("move_left")
			max_speed = maxf(max_speed,game.player.velocity.x)
			if game.state == "won" or game.deaths > 0: break
		release()
		print("ROOM5_ROUTE delay=",delay," launch=",max_speed," guard_alive=",game.enemy.alive," end=",game.player.position," deaths=",game.deaths)
		check(floor_placed and launched and max_speed > 650,"Fifth route uses actual gravity launch")
		check(game.state == "won" and game.deaths == 0,"Fifth route reaches the goal without death")
		check(not game.enemy.alive,"Forward launch stomps the guard without the old early braking")
	game.start_level(4)
	await frames(4)
	check(game.portals.shoot(game.gun_origin(),Vector2(120,90),1),"Retry fixture places wall portal")
	Input.action_press("move_right")
	for i in 100:
		await physics_frame
		if game.player.position.x > 344: break
	release()
	check(game.portals.shoot(game.gun_origin(),Vector2(440,470),0),"Retry fixture places floor portal after leaving ledge")
	game.enemy.alive = false
	game.enemy.hide()
	game.player.die()
	await frames(50)
	check(game.enemy.alive and game.enemy.position.y == 373 and game.enemy.position.x >= 680 and game.enemy.position.x <= 760,"Death restores fifth-room guard to its own patrol")
	check(game.player.position.distance_to(game.player.spawn) < 1 and game.portals.doors[0].is_empty() and game.portals.doors[1].is_empty(),"Fifth-room retry restores start and clears both placed portals")
	game.start_level(2)
	await frames(4)
	check(game.enemy.position.y == 413 and game.enemy.low == 440 and game.enemy.high == 580,"Third-room guard keeps original spawn and patrol")
	await game.drain_audio()
	paused = false
	game.queue_free()
	await process_frame
	print("LEVEL5_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
