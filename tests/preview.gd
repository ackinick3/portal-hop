extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	scene.persistence_enabled = false
	root.add_child(scene)
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://docs/menu.png")
	for i in 3:
		scene.start_level(i)
		await process_frame
		await process_frame
		root.get_texture().get_image().save_png("res://docs/room%d.png" % (i+1))
	paused = false
	await scene.drain_audio()
	scene.queue_free()
	await process_frame
	quit()

