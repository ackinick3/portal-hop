extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(2)
	game.audio.play("win")
	print("WINDOW_CLOSE_PATH_STARTED")
	game.notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	await create_timer(2).timeout
	push_error("Graceful window close did not finish")
	quit(1)
