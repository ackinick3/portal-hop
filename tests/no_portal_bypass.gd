extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(3)
	game.player.jumped.connect(func(): print("JUMP ",game.player.position))
	game.player.landed.connect(func(): print("LAND ",game.player.position))
	Input.action_press("move_right")
	var jump_hold := 0
	for i in 400:
		await physics_frame
		var x: float = game.player.position.x
		if game.player.is_on_floor() and not Input.is_action_pressed("jump") and (x > 140 and x < 200 or x > 330 and x < 350):
			Input.action_press("jump")
			jump_hold = 50
		elif jump_hold > 0: jump_hold -= 1
		else: Input.action_release("jump")
		if game.state == "won": break
	Input.action_release("move_right")
	Input.action_release("jump")
	var blocked: bool = game.state != "won"
	print("NO_PORTAL_BYPASS_PASS=",blocked," final_position=",game.player.position)
	await game.drain_audio()
	paused = false
	game.queue_free()
	await process_frame
	quit(0 if blocked else 1)
