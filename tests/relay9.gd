extends SceneTree
var failures := 0
func check(ok: bool,message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await physics_frame
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(8)
	await frames(4)
	check(game.portals.shoot(game.gun_origin(),Vector2(365,430),1),"First relay exit is visible at the starting lip")
	check(game.portals.shoot(game.gun_origin(),Vector2(230,470),0),"Initial low entry can be prepared")
	check(game.portals.candidate(game.gun_origin(),Vector2(575,430),0).is_empty(),"Next floor is hidden below the high-point window")
	Input.action_press("move_right")
	var placed_second := false
	var placed_third := false
	var first_speed := 0.0
	var last_transfer := 0
	for i in 1400:
		await physics_frame
		if game.transfers == 0:
			if game.player.position.x > 190 and game.player.velocity.x > 12:
				Input.action_release("move_right")
				Input.action_press("move_left")
			if game.player.position.x > 190 and absf(game.player.velocity.x) < 12: Input.action_release("move_left")
		elif game.transfers == 1:
			if first_speed == 0:
				first_speed = game.player.velocity.length()
				Input.action_release("move_left")
				Input.action_release("move_right")
			if not placed_second and game.player.position.y < 200:
				placed_second = game.portals.shoot(game.gun_origin(),Vector2(575,430),0)
		elif game.transfers == 2:
			if not placed_third and game.player.position.y < 190:
				placed_third = game.portals.shoot(game.gun_origin(),Vector2(775,430),1)
		else:
			Input.action_press("move_right")
		if game.transfers != last_transfer:
			last_transfer = game.transfers
			print("RELAY_TRANSFER ",last_transfer," p=",game.player.position," v=",game.player.velocity)
		if game.state == "won" or game.deaths > 0: break
	Input.action_release("move_left")
	Input.action_release("move_right")
	print("RELAY_END p=",game.player.position," transfers=",game.transfers," speed=",first_speed," death=",game.deaths)
	check(placed_second and placed_third and game.transfers >= 3,"High-point shots advance both relay exits")
	check(game.state == "won" and game.deaths == 0,"Initial gravity energy carries the complete spike relay")
	await game.drain_audio()
	OS.delay_msec(350)
	paused = false
	game.queue_free()
	await process_frame
	print("RELAY_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
