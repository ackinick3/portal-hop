extends SceneTree

func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(2)
	await process_frame
	game.player.set_physics_process(false)
	game.enemy.set_physics_process(false)
	game.player.position = game.enemy.position - Vector2(0,31)
	game.enemy.hit(game.player,game.enemy.position-Vector2(0,60),Vector2(0,200))
	game.player.portal_flash = 0.18
	game.player.set_process(false)
	game.set_physics_process(false)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/stomp-preview.png")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	quit()
