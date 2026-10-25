extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/curated-preview")
	var maps = load("res://levels/maps.gd")
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for i in maps.LEVEL_COUNT:
		game.enter_level(i)
		await create_timer(0.08).timeout
		root.get_texture().get_image().save_png("res://docs/curated-preview/room%02d.png" % (i+1))
	game.unlocked = maps.LEVEL_COUNT
	for page in 3:
		game.level_select(page)
		await process_frame
		await process_frame
		root.get_texture().get_image().save_png("res://docs/curated-preview/select%d.png" % (page+1))
	game.menu()
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://docs/curated-preview/menu.png")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("CURATED_PREVIEW_COUNT=",maps.LEVEL_COUNT)
	quit()
