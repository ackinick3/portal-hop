extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func find_button(game, source: String) -> Button:
	for child in game.panel.get_children():
		if child is Button and child.text == game.text(source): return child
	return null
func capture(name: String) -> void:
	if OS.get_cmdline_user_args().has("--capture"):
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/v1-" + name + ".png")
func check_layout(game) -> void:
	await process_frame
	await process_frame
	for child in game.panel.get_children():
		if child is Control:
			check(Rect2(0,0,960,540).encloses(child.get_rect()),"Fits viewport: " + str(child.get_class()))
			if child is Button:
				check(child.get_theme_font("font").get_string_size(child.text,HORIZONTAL_ALIGNMENT_LEFT,-1,child.get_theme_font_size("font_size")).x <= child.size.x-12,"Button text fits: " + child.text)
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	check(game.language == "zh_CN","Fresh game defaults to Simplified Chinese")
	check(ProjectSettings.get_setting("application/config/version","") == "1.0","Release version is 1.0")
	check(find_button(game,"START GAME").text == "开始游戏","Default menu renders Chinese")
	check(find_button(game,"LANGUAGE / 语言") != null,"Language entry exists on main menu")
	var legacy := ConfigFile.new()
	legacy.set_value("progress","order_version",2)
	legacy.set_value("progress","unlocked",17)
	legacy.set_value("settings","volume",0.37)
	game.restore_progress(legacy)
	check(game.language=="zh_CN" and game.unlocked==17 and is_equal_approx(game.volume,0.37),"Old save gains Chinese while preserving progress/volume")
	var real_save := "user://progress.cfg"
	var before := [FileAccess.get_sha256(real_save),FileAccess.get_modified_time(real_save)]
	var isolated := "user://localization-test.cfg"
	game.language_select()
	game.set_language("en")
	check(find_button(game,"BACK").text=="BACK","Selecting English immediately translates page")
	game.persistence_enabled = true
	game.save_progress(isolated)
	game.persistence_enabled = false
	var saved := ConfigFile.new()
	check(saved.load(isolated)==OK,"Language setting writes an isolated settings file")
	game.language = "zh_CN"
	game.restore_progress(saved)
	check(game.language=="en" and game.unlocked==17 and is_equal_approx(game.volume,0.37),"Saved English survives reload with progress/volume")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(isolated))
	var bundled_font: Font = load("res://ui/theme.tres").default_font
	var missing := {}
	for translated in game.Languages.ZH.values():
		for character in translated:
			if character != "\n" and not bundled_font.has_char(character.unicode_at(0)): missing[character] = true
	check(missing.is_empty(),"Bundled font covers all translated glyphs: " + str(missing))
	for locale in ["zh_CN","en"]:
		game.unlocked = 17
		game.set_language(locale)
		game.menu()
		await check_layout(game)
		await capture(locale + "-menu")
		find_button(game,"LANGUAGE / 语言").pressed.emit()
		await check_layout(game)
		await capture(locale + "-language")
		game.controls()
		await check_layout(game)
		await capture(locale + "-controls")
		game.settings()
		await check_layout(game)
		await capture(locale + "-settings")
		for page in 3:
			game.level_select(page)
			await check_layout(game)
			await capture(locale + "-select" + str(page+1))
		for i in game.Maps.LEVEL_COUNT:
			var title: String = game.Maps.get_level(i).name
			check(game.Languages.ZH.has(title),"Chinese name exists: " + title)
		game.start_level(28)
		game.pause_menu()
		await check_layout(game)
		await capture(locale + "-pause")
		game.complete()
		await check_layout(game)
		await capture(locale + "-complete")
	check([FileAccess.get_sha256(real_save),FileAccess.get_modified_time(real_save)] == before,"Real player save remains unchanged")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("LOCALIZATION_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
