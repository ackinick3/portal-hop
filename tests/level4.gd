extends SceneTree

var failures := 0
func check(ok: bool, text: String) -> void:
	print("PASS: " if ok else "FAIL: ",text)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await physics_frame
func release() -> void:
	for action in ["move_left","move_right","jump"]: Input.action_release(action)
func run() -> void:
	var maps = load("res://levels/maps.gd")
	var fourth: Dictionary = maps.get_level(3)
	check(fourth.name == "THE VECTOR SWITCH","Index 3 is the new fourth room, not a copy of room 3")
	if fourth.name != "THE VECTOR SWITCH":
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	# Real input routes; no assigning a launch velocity or teleporting player into the solution.
	for setting in [Vector2(300,830),Vector2(295,820),Vector2(305,840),Vector2(300,540)]:
		game.start_level(3)
		await frames(4)
		var ceiling: bool = setting.y == 540
		var output := Vector2(540,160) if ceiling else Vector2(setting.y,300)
		game.portals.feedback.connect(func(kind):
			if kind == "teleport": print("ROOM4_EXIT ",game.player.position," v=",game.player.velocity)
		)
		check(game.portals.shoot(game.gun_origin(),output,1),"Exit surface is visible from spawn: " + str(setting))
		Input.action_press("move_right")
		var entry_placed := false
		var crossed := false
		var landed := false
		var exit_velocity := Vector2.ZERO
		for i in 550:
			await physics_frame
			if not entry_placed and game.player.position.x > 211:
				entry_placed = game.portals.shoot(game.gun_origin(),Vector2(310,setting.x),0)
			if game.transfers > 0 and not crossed:
				crossed = true
				exit_velocity = game.player.velocity
				release()
				Input.action_press("move_right" if ceiling else "move_left")
			if crossed and game.player.is_on_floor() and absf(game.player.position.y - 270) < 1 and game.player.position.x > 480:
				landed = true
				release()
				Input.action_press("move_right" if game.player.position.x < game.data.goal.get_center().x else "move_left")
			if game.state == "won" or game.deaths > 0: break
		release()
		check(entry_placed,"Wall entry is visible after stepping clear of the starting ledge")
		print("ROOM4_ROUTE ",setting," ceiling=",ceiling," exit_velocity=",exit_velocity," end=",game.player.position," landed=",landed," deaths=",game.deaths)
		check(crossed,"Route physically traverses a portal")
		check(exit_velocity.y > 0 if ceiling else exit_velocity.y < 0,"Exit vertical direction matches chosen surface")
		check(landed or ceiling and game.state == "won","Floor route lands; downward ceiling route may touch the gate in midair")
		check(game.state == "won" and game.deaths == 0,"Route completes without death")
	game.start_level(3)
	await frames(4)
	game.player.die()
	await frames(50)
	check(game.deaths == 1 and game.player.position.distance_to(game.player.spawn) < 1,"Fourth room retry returns to starting ledge")
	check(game.portals.doors[0].is_empty() and game.portals.doors[1].is_empty(),"Fourth room retry clears both portals")
	check(maps.get_level(-1).is_empty() and maps.get_level(maps.LEVEL_COUNT).is_empty(),"Invalid room indices return no room")
	await game.drain_audio()
	paused = false
	game.queue_free()
	await process_frame
	print("LEVEL4_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
