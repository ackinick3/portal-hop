extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(2)
	for i in 3: await physics_frame
	game.player.position = Vector2(600,415)
	game.player.previous_position = Vector2(600,415)
	game.player.previous_velocity = Vector2(-210,0)
	game.player.die()
	for i in 48: await physics_frame
	var okay: bool = game.deaths == 1 and game.player.dead_time <= 0 and game.player.position.x < 250
	print("RESPAWN_HISTORY_PASS=",okay," deaths=",game.deaths," position=",game.player.position)
	game.queue_free()
	paused = false
	await process_frame
	quit(0 if okay else 1)
