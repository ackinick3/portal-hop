extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var embedded := FileAccess.file_exists("res://project.binary")
	print("EMBEDDED_PROJECT=",embedded)
	var maps = load("res://levels/maps.gd")
	if not embedded or maps.LEVEL_COUNT != 28:
		push_error("Expected the exported twenty-eight-room pack, not loose project sources")
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for i in 28:
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
		if i==23 and (game.enemy==null or not game.enemy.vertical or game.enemy.spawn!=Vector2(542,208.5)):
			push_error("Exported room24 is missing the vertical guard")
			await game.drain_audio()
			quit(1)
			return
		if i==24 and game.data.name!="THE SECOND ASCENT":
			push_error("Exported room25 was not retained")
			await game.drain_audio()
			quit(1)
			return
		if i==25 and (game.data.name!="THE CRIMSON ARC" or game.portals.polygons.size()!=3):
			push_error("Exported room26 was not retained")
			await game.drain_audio()
			quit(1)
			return
		if i==26 and (game.data.name!="THE WANDERING FINISH" or game.portals.gun_screens.size()!=1 or game.stage.movers.size()!=1 or game.data.get("goal_mover",-1)!=0):
			push_error("Exported room27 was not retained")
			await game.drain_audio()
			quit(1)
			return
	print("EXPORTED_ROOMS_STARTED=28")
	print("EXPORTED_FINAL=",game.data.name," polygons=",game.portals.polygons.size()," movers=",game.stage.movers.size()," receivers=",game.stage.receivers.size())
	if game.data.name!="THE KINETIC CHAMBER" or game.stage.movers.size()!=2 or game.stage.movers[0].platform.path_points.size()!=5 or game.stage.movers[1].platform.path_points.size()!=3 or game.data.get("goal_mover",-1)!=0 or game.enemies.size()!=6 or game.hazard_rects().size()!=1:
		push_error("Exported final room is missing the polyline target, moving spikes or six guards")
		await game.drain_audio()
		quit(1)
		return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			RenderingServer.force_draw()
			root.get_texture().get_image().save_png(arg.trim_prefix("--capture="))
		if arg.begins_with("--capture-selection="):
			game.unlocked = maps.LEVEL_COUNT
			game.level_select(2)
			await process_frame
			await process_frame
			RenderingServer.force_draw()
			root.get_texture().get_image().save_png(arg.trim_prefix("--capture-selection="))
	await game.drain_audio()
	game.queue_free()
	await process_frame
	quit(0)
