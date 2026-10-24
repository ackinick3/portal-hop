extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(2)
	await process_frame
	game.set_process(false)
	game.set_physics_process(false)
	game.player.set_process(false)
	game.player.set_physics_process(false)
	game.player.aim_at(Vector2(510, 197))
	game.portals.shoot(game.gun_origin(), Vector2(510, 197), 1)
	game.portals.set_process(false)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/feedback-preview.png")
	game.queue_free()
	await process_frame
	quit()
