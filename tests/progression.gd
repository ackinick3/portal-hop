extends SceneTree
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
	game.start_level(4)
	check(game.index == 3 and game.player == current_player,"Invalid room request leaves current room intact")
	game.complete()
	check(find_button(game,"NEXT ROOM") == null,"Room 4 is the final room; no nonexistent room 5 button")
	game.level_select()
	fourth = find_button(game,"04")
	check(fourth != null and not fourth.disabled,"Unlocked room 4 can be selected")
	legacy.set_value("progress","unlocked",4)
	game.restore_progress(legacy)
	check(game.unlocked == 4,"New four-room progress restores correctly")
	# Unlike real UI input, the assertions above finish two rooms in the same frame.
	# Let those overlapping result cues finish; immediate close is tested by audio_quit.
	await create_timer(0.3).timeout
	await game.drain_audio()
	paused = false
	game.queue_free()
	await process_frame
	print("PROGRESSION_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
