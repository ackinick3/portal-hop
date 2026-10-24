extends SceneTree

var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var old_mouse := DisplayServer.mouse_get_position()
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(1)
	for size in [Vector2i(1280,720),Vector2i(1000,700),Vector2i(800,800)]:
		DisplayServer.window_set_size(size)
		for i in 4: await process_frame
		print("DISPLAY_PROBE requested=",size," visible=",root.get_visible_rect()," scale=",root.content_scale_size," aspect=",root.content_scale_aspect," transform=",game.get_viewport_transform())
		check(root.get_visible_rect().size.is_equal_approx(Vector2(960,540)),"Resizing preserves 960x540 logical view")
		var target := Vector2(180,90)
		Input.warp_mouse(game.get_viewport_transform() * target)
		for i in 3: await process_frame
		print("MOUSE_PROBE expected=",target," actual=",game.get_global_mouse_position())
		check(game.get_global_mouse_position().distance_to(target) < 1,"Mouse aiming maps correctly through window letterboxing")
		check(not game.portals.candidate(game.gun_origin(),game.get_global_mouse_position(),1).is_empty(),"Same mouse target stays shootable at each window size")
	game.toggle_fullscreen()
	for i in 8: await process_frame
	print("FULLSCREEN_MODE=",DisplayServer.window_get_mode()," visible=",root.get_visible_rect())
	check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN and root.get_visible_rect().size == Vector2(960,540),"Fullscreen keeps the same logical view")
	game.toggle_fullscreen()
	for i in 8: await process_frame
	print("WINDOWED_MODE=",DisplayServer.window_get_mode()," visible=",root.get_visible_rect())
	check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED and root.get_visible_rect().size == Vector2(960,540),"Returning to window restores fixed logical view")
	DisplayServer.warp_mouse(old_mouse - DisplayServer.window_get_position())
	for i in 3: await process_frame
	check(DisplayServer.mouse_get_position().distance_to(old_mouse) < 2,"Display test restores original desktop cursor position")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("DISPLAY_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
