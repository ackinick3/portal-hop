extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,text: String) -> void:
	print("PASS: " if ok else "FAIL: ",text)
	if not ok: failures+=1
func save_identity() -> Dictionary:
	var file := "user://progress.cfg"
	return {"exists":FileAccess.file_exists(file),"hash":FileAccess.get_sha256(file) if FileAccess.file_exists(file) else "","modified":FileAccess.get_modified_time(file)}
func run() -> void:
	check(OS.get_cmdline_user_args().has("--challenge"),"Challenge startup test receives the real command-line flag")
	var before := save_identity()
	var game = load("res://scenes/main.tscn").instantiate()
	# Deliberately start with normal persistence: the production entry must disable it.
	root.add_child(game)
	check(not game.persistence_enabled and game.index==28 and game.state=="playing" and game.data.name=="THE BORROWED EXIT","--challenge enters room29 with persistence disabled before any play")
	if not game.persistence_enabled:
		game.complete() # Progression fixture, not route evidence.
		game.save_progress()
		game.menu()
		game.save_progress()
	check(save_identity()==before,"Completion and menu in challenge mode preserve real save bytes and modification time")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("CHALLENGE_ENTRY_FAILURES=",failures)
	quit(0 if failures==0 else 1)
