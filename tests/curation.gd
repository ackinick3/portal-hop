extends SceneTree
var failures := 0
const EXPECTED_IDS := [1,2,3,4,5,6,7,8,9,10,11,14,17,19,20,21,25,34,36,37,38,48,50]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func find_button(game: Node2D,prefix: String) -> Button:
	for child in game.panel.get_children():
		if child is Button and child.text.begins_with(prefix): return child
	return null
func run() -> void:
	var maps = load("res://levels/maps.gd")
	check(maps.LEVEL_COUNT == 23,"Exactly23 curated rooms remain")
	if maps.LEVEL_COUNT != 23:
		quit(1)
		return
	check(maps.ROOM_IDS == EXPECTED_IDS,"Displayed order matches all27 user deletions")
	check(maps.get_level(-1).is_empty() and maps.get_level(23).is_empty(),"Deleted tail indices cannot be loaded")
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.menu()
	check(find_button(game,"HOW TO PLAY") == null and find_button(game,"MATERIALS") == null,"Tutorial entries are removed")
	for i in 23:
		var data: Dictionary = maps.get_level(i)
		check(not data.is_empty() and not data.has("hint") and not data.has("guide") and not data.has("briefing"),"New room%02d has no hint metadata" % (i+1))
		game.enter_level(i)
		check(game.index == i and game.state == "playing" and not paused,"New room%02d enters gameplay directly" % (i+1))
		check(game.panel.get_child_count() == 0,"New room%02d has no tutorial panel" % (i+1))
		game.complete()
		check((find_button(game,"NEXT ROOM") != null) == (i<22),"Only new room23 ends the campaign")
	game.unlocked = 13
	for page in 3:
		game.level_select(page)
		await process_frame
		await process_frame
		var slots := 0
		for child in game.panel.get_children():
			if child is Button:
				check(Rect2(0,0,960,540).encloses(child.get_rect()),"Selection controls fit on page%d" % (page+1))
				if child.text.left(2).is_valid_int():
					slots += 1
					check(child.disabled == (int(child.text.left(2))>13),"Renumbered locks correspond to new progress")
		check(slots == (3 if page==2 else 10),"Page%d has the correct room count" % (page+1))
	var legacy := ConfigFile.new()
	legacy.set_value("settings","volume",0.35)
	for setting in [Vector2i(1,1),Vector2i(8,8),Vector2i(12,12),Vector2i(14,12),Vector2i(22,17),Vector2i(34,18),Vector2i(44,22),Vector2i(49,23),Vector2i(50,23)]:
		legacy.set_value("progress","unlocked",setting.x)
		game.restore_progress(legacy)
		check(game.unlocked == setting.y and is_equal_approx(game.volume,0.35),"Legacy unlock%d migrates to new%d without replaying completed survivors" % [setting.x,setting.y])
	legacy.set_value("progress","order_version",2)
	for value in [1,12,20,23]:
		legacy.set_value("progress","unlocked",value)
		game.restore_progress(legacy)
		check(game.unlocked == value,"Version2 unlock%d is not migrated twice" % value)
	await game.drain_audio()
	OS.delay_msec(350)
	paused = false
	game.queue_free()
	await process_frame
	print("CURATION_FAILURES=",failures)
	quit(0 if failures==0 else 1)
