extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func find_button(game, text: String) -> Button:
	for child in game.panel.get_children():
		if child is Button and child.text == game.text(text): return child
	return null
func capture(file: String) -> void:
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		get_root().get_texture().get_image().save_png(file)
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var entry := find_button(game,"CONTROLS")
	check(entry != null,"Main menu exposes controls")
	if entry != null:
		await capture("res://docs/controls-menu.png")
		entry.pressed.emit()
		check(game.state == "controls" and paused,"Controls opens while gameplay stays paused")
		var labels: Array[String] = []
		for child in game.panel.get_children():
			if child is Label:
				labels.append(child.text)
				check(child.position.x + child.size.x <= 960 and child.position.y + child.size.y <= 540,"Help text fits viewport: " + child.text)
		for key in ["A / D","SPACE","MOUSE","LEFT CLICK","RIGHT CLICK","R","ESC","F11"]:
			check(labels.has(game.text(key)),"Documents " + key)
		await capture("res://docs/controls-help.png")
		find_button(game,"BACK").pressed.emit()
		check(game.state == "menu" and find_button(game,"CONTROLS") != null,"Back restores main menu")
		game.start_level(0)
		game.pause_menu()
		game.menu()
		find_button(game,"CONTROLS").pressed.emit()
		var retry := InputEventKey.new()
		retry.physical_keycode = KEY_R
		retry.pressed = true
		game._unhandled_input(retry)
		check(game.deaths == 0 and paused,"Help opened after gameplay blocks retry input")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("CONTROLS_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
