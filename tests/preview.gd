extends SceneTree
const Maps = preload("res://levels/maps.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	scene.persistence_enabled = false
	root.add_child(scene)
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://docs/menu.png")
	for i in Maps.LEVEL_COUNT:
		scene.start_level(i)
		await create_timer(0.12).timeout
		root.get_texture().get_image().save_png("res://docs/room%d.png" % (i+1))
	scene.menu()
	scene.unlocked = Maps.LEVEL_COUNT
	scene.level_select()
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://docs/level-select.png")
	paused = false
	await scene.drain_audio()
	scene.queue_free()
	await process_frame
	quit()

