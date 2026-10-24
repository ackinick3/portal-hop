extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://docs/campaign-preview")
	var maps = load("res://levels/maps.gd")
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var count := 0
	for i in maps.LEVEL_COUNT:
		if maps.get_level(i).is_empty(): continue
		game.start_level(i)
		await create_timer(0.08).timeout
		root.get_texture().get_image().save_png("res://docs/campaign-preview/room%02d.png" % (i+1))
		if i >= 8:
			game.enter_level(i)
			await process_frame
			await process_frame
			root.get_texture().get_image().save_png("res://docs/campaign-preview/briefing%02d.png" % (i+1))
		count += 1
	game.unlocked = 50
	for page in 5:
		game.level_select(page)
		await process_frame
		await process_frame
		root.get_texture().get_image().save_png("res://docs/campaign-preview/select%d.png" % (page+1))
	game.unlocked = 8
	game.level_select(0)
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://docs/campaign-preview/select-locked.png")
	game.machines_instructions()
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://docs/campaign-preview/materials-help.png")
	game.menu()
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png("res://docs/campaign-preview/menu.png")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("CAMPAIGN_PREVIEW_COUNT=",count)
	quit(0 if count == 50 else 1)
