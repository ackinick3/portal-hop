extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var embedded := FileAccess.file_exists("res://project.binary")
	print("EMBEDDED_PROJECT=",embedded)
	var maps = load("res://levels/maps.gd")
	if not embedded or maps.LEVEL_COUNT != 24:
		push_error("Expected the exported twenty-four-room pack, not loose project sources")
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for i in 24:
		game.enter_level(i)
		await process_frame
		await process_frame
		if game.index != i or game.data.is_empty():
			push_error("Exported room could not start: %d" % (i+1))
			await game.drain_audio()
			quit(1)
			return
		if game.state != "playing" or game.panel.get_child_count() != 0 or game.data.has("hint") or game.data.has("guide") or game.data.has("briefing"):
			push_error("Exported room still shows tutorial content: %d" % (i+1))
			await game.drain_audio()
			quit(1)
			return
	print("EXPORTED_ROOMS_STARTED=24")
	print("EXPORTED_FINAL=",game.data.name," polygons=",game.portals.polygons.size()," movers=",game.stage.movers.size()," receivers=",game.stage.receivers.size())
	if game.enemy==null or not game.enemy.vertical or game.enemy.spawn!=Vector2(542,208.5):
		push_error("Exported final room is missing the vertical guard")
		await game.drain_audio()
		quit(1)
		return
	print("EXPORTED_VERTICAL_GUARD=",game.enemy.spawn," range=",game.enemy.low,"..",game.enemy.high)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			root.get_texture().get_image().save_png(arg.trim_prefix("--capture="))
	await game.drain_audio()
	game.queue_free()
	await process_frame
	quit(0)
