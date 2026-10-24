extends SceneTree
const Maps = preload("res://levels/maps.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func find_button(game: Node2D, prefix: String) -> Button:
	for child in game.panel.get_children():
		if child is Button and child.text.begins_with(prefix): return child
	return null
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	check(game.has_method("restore_progress"),"Legacy progress is restored through the actual load path")
	if not game.has_method("restore_progress"):
		await game.drain_audio()
		game.queue_free()
		await process_frame
		quit(1)
		return
	var legacy := ConfigFile.new()
	legacy.set_value("progress","unlocked",3)
	legacy.set_value("settings","volume",0.35)
	game.restore_progress(legacy)
	check(game.unlocked == 3 and is_equal_approx(game.volume,0.35),"Old three-room progress and volume survive without clearing")
	game.level_select()
	var fourth := find_button(game,"04")
	check(fourth != null and fourth.disabled,"Fourth room appears locked before beating room 3")
	game.start_level(2)
	game.complete()
	check(game.unlocked == 4,"Beating room 3 unlocks room 4")
	var next := find_button(game,"NEXT ROOM")
	check(next != null,"Room 3 results now offer next room")
	if next != null: next.pressed.emit()
	check(game.index == 3 and game.data.name == "THE VECTOR SWITCH" and game.state == "playing","Next-room button starts actual fourth map")
	var current_player = game.player
	game.start_level(Maps.LEVEL_COUNT)
	check(game.index == 3 and game.player == current_player,"Invalid room request leaves current room intact")
	game.complete()
	check(game.unlocked == 5,"Beating room 4 unlocks room 5")
	next = find_button(game,"NEXT ROOM")
	check(next != null,"Room 4 results offer room 5")
	if next != null: next.pressed.emit()
	check(game.index == 4 and game.data.name == "THE FINAL RELAY" and game.state == "playing","Next-room button starts actual fifth map")
	game.complete()
	check(game.unlocked == 6,"Beating room 5 unlocks room 6")
	next = find_button(game,"NEXT ROOM")
	check(next != null,"Room 5 results offer room 6")
	if next != null: next.pressed.emit()
	check(game.state == "briefing","Room 6 entry teaches airborne replacement before starting")
	var start := find_button(game,"START ROOM")
	if start != null: start.pressed.emit()
	check(game.index == 5 and game.data.name == "AIRBORNE RELAY" and game.state == "playing","Briefing opens the actual sixth map")
	game.complete()
	check(game.unlocked == 7,"Beating room 6 unlocks room 7")
	next = find_button(game,"NEXT ROOM")
	check(next != null,"Room 6 results offer room 7")
	if next != null: next.pressed.emit()
	check(game.state == "briefing","Room 7 entry explains the two airborne shots")
	start = find_button(game,"START ROOM")
	if start != null: start.pressed.emit()
	check(game.index == 6 and game.data.name == "MIDAIR SWITCHBACK" and game.state == "playing","Briefing opens the actual seventh map")
	game.complete()
	check(find_button(game,"NEXT ROOM") == null,"Room 7 is the final room")
	game.level_select()
	fourth = find_button(game,"04")
	check(fourth != null and not fourth.disabled,"Unlocked room 4 can be selected")
	legacy.set_value("progress","unlocked",4)
	game.restore_progress(legacy)
	check(game.unlocked == 4,"Old four-room progress is preserved without assuming completion")
	game.level_select()
	var fifth := find_button(game,"05")
	check(fifth != null and fifth.disabled,"Old save unlocks room 5 only after beating room 4")
	legacy.set_value("progress","unlocked",5)
	game.restore_progress(legacy)
	check(game.unlocked == 5 and is_equal_approx(game.volume,0.35),"Five-room progress and volume restore correctly")
	game.level_select()
	fifth = find_button(game,"05")
	check(fifth != null and not fifth.disabled,"Unlocked fifth room can be selected")
	var sixth := find_button(game,"06")
	check(sixth != null and sixth.disabled,"Old five-room save does not assume room 5 was completed")
	legacy.set_value("progress","unlocked",6)
	game.restore_progress(legacy)
	game.level_select()
	sixth = find_button(game,"06")
	check(game.unlocked == 6 and sixth != null and not sixth.disabled and is_equal_approx(game.volume,0.35),"Six-room progress, volume and selection restore correctly")
	if sixth != null: sixth.pressed.emit()
	check(game.state == "briefing" and find_button(game,"START ROOM") != null,"Selecting room 6 also shows its briefing")
	game.level_select()
	var seventh := find_button(game,"07")
	check(seventh != null and seventh.disabled,"Old six-room progress keeps room 7 locked until room 6 is completed")
	legacy.set_value("progress","unlocked",7)
	game.restore_progress(legacy)
	game.level_select()
	seventh = find_button(game,"07")
	check(game.unlocked == 7 and seventh != null and not seventh.disabled and is_equal_approx(game.volume,0.35),"Seven-room progress and volume restore correctly")
	if seventh != null: seventh.pressed.emit()
	var seventh_title := false
	for child in game.panel.get_children():
		if child is Label and child.text == "MIDAIR SWITCHBACK": seventh_title = true
	check(game.state == "briefing" and seventh_title and find_button(game,"START ROOM") != null,"Seventh selection opens its own briefing, not room 6's")
	# Unlike real UI input, the assertions above finish five rooms in the same frame.
	# Let those overlapping result cues finish; immediate close is tested by audio_quit.
	await create_timer(0.3).timeout
	await game.drain_audio()
	paused = false
	game.queue_free()
	await process_frame
	print("PROGRESSION_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
