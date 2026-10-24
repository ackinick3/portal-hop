extends SceneTree
var failed := 0
func check(ok: bool, text: String) -> void:
	print("PASS: " if ok else "FAIL: ",text)
	if not ok: failed += 1
func _initialize() -> void: call_deferred("run")
func step(count: int) -> void:
	for i in count: await physics_frame
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(2)
	await step(3)
	check(game.portals.shoot(game.gun_origin(),Vector2(510,197),1),"Room 3 ceiling target visible from upper position")
	Input.action_press("move_left")
	await step(100)
	Input.action_release("move_left")
	await step(50)
	check(game.player.is_on_floor(),"Room 3 player reaches lower firing position")
	check(game.portals.shoot(game.gun_origin(),Vector2(200,430),0),"Room 3 floor target visible from lower position")
	check(not game.portals.doors[1].is_empty(),"Ceiling portal survives repositioning")
	Input.action_press("move_right")
	var ceiling_exit := false
	for i in 240:
		await physics_frame
		if game.player.position.x > 400 and game.player.position.y < 260:
			ceiling_exit = true
			Input.action_release("move_right")
			# Preserve the portal's tangential direction; allow normal air steering toward guard.
			Input.action_press("move_right")
		if game.deaths > 0 or not game.enemy.alive: break
	for action in ["move_left","move_right","jump"]: Input.action_release(action)
	check(ceiling_exit,"Room 3 physically exits downward from ceiling")
	print("CEILING_END ",game.player.position," guard=",game.enemy.position," alive=",game.enemy.alive," deaths=",game.deaths)
	check(not game.enemy.alive and game.deaths == 0,"Ceiling drop stomps guard")
	Input.action_press("move_right")
	for i in 400:
		await physics_frame
		if game.player.is_on_floor() and game.player.position.x > 610:
			Input.action_press("jump")
		else: Input.action_release("jump")
		if game.state == "won" or game.deaths > 0: break
	for action in ["move_right","jump"]: Input.action_release(action)
	check(game.state == "won", "Room 3 portal route reaches goal")
	game.get_tree().paused = false
	game.queue_free()
	await process_frame
	print("CEILING_ROUTE_FAILURES=",failed)
	quit(0 if failed == 0 else 1)


