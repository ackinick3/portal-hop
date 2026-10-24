extends SceneTree
var failures := 0
func check(ok: bool,message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func button(game: Node2D,prefix: String) -> Button:
	for child in game.panel.get_children():
		if child is Button and child.text.begins_with(prefix): return child
	return null
func run() -> void:
	var maps = load("res://levels/maps.gd")
	var complete_maps := maps.LEVEL_COUNT == 50
	for i in 50:
		if maps.get_level(i).is_empty():
			print("MISSING_MAP=",i+1)
			complete_maps = false
	check(complete_maps,"All fifty rooms exist at their actual map boundaries")
	if not complete_maps:
		quit(1)
		return
	check(maps.get_level(-1).is_empty() and maps.get_level(50).is_empty(),"Campaign rejects both invalid boundaries")
	var names: Array = []
	for i in 50:
		var data: Dictionary = maps.get_level(i)
		check(data.name not in names,"Room %02d has its own title" % (i+1))
		names.append(data.name)
		check(data.goal.position.x >= 0 and data.goal.end.x <= 960 and data.goal.position.y >= 0 and data.goal.end.y <= 540,"Room %02d goal is inside the visible playfield" % (i+1))
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var save := ConfigFile.new()
	save.set_value("progress","unlocked",8)
	save.set_value("settings","volume",0.35)
	game.restore_progress(save)
	check(game.unlocked == 8 and is_equal_approx(game.volume,0.35),"Old eight-room progress and settings survive without inventing completion")
	for page in 5:
		game.level_select(page)
		await process_frame
		await process_frame
		var rooms := 0
		var boxes: Array[Rect2] = []
		for child in game.panel.get_children():
			if child is Button:
				check(Rect2(0,0,960,540).encloses(child.get_rect()),"Page %d button is fully visible: %s" % [page+1,child.text])
				for box in boxes: check(not box.intersects(child.get_rect()),"Selection controls do not overlap")
				boxes.append(child.get_rect())
				if child.text.left(2).is_valid_int():
					rooms += 1
					check(child.disabled == (int(child.text.left(2)) > 8),"Page %d correctly preserves locks" % (page+1))
		check(rooms == 10,"Page %d contains ten selectable room slots" % (page+1))
	game.start_level(7)
	game.complete()
	check(game.unlocked == 9 and button(game,"NEXT ROOM") != null,"Beating room8 unlocks the ninth relay")
	# This tests navigation only; authentic physical solutions live in chapter route suites.
	for i in range(8,50):
		game.enter_level(i)
		await process_frame
		await process_frame
		check(game.state == "briefing","Room %02d has a pre-play explanation" % (i+1))
		for child in game.panel.get_children():
			if child is Label and child.position.y == 155:
				check(child.get_rect().end.y < 405,"Room %02d explanation does not cover START" % (i+1))
		var start := button(game,"START ROOM")
		check(start != null,"Room %02d briefing starts the actual level" % (i+1))
		if start != null: start.pressed.emit()
		check(game.index == i and game.state == "playing","Room %02d loads its own playable scene" % (i+1))
		game.complete()
		check(game.unlocked == mini(i+2,50),"Room %02d unlocks only its successor" % (i+1))
		check((button(game,"NEXT ROOM") != null) == (i < 49),"Final page appears only after room50")
	await game.drain_audio()
	OS.delay_msec(350)
	paused = false
	game.queue_free()
	await process_frame
	print("CAMPAIGN_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
