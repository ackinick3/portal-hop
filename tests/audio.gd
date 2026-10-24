extends SceneTree

var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var audio = load("res://assets/sounds.gd").new()
	root.add_child(audio)
	var kinds := ["jump","land","red","blue","invalid","teleport","death","checkpoint","stomp","win"]
	for i in 200:
		audio.play(kinds[i % kinds.size()])
	check(audio.get_child_count() <= 10,"200 cues use at most ten reusable players")
	check(audio.has_method("shutdown"),"Audio has explicit resource shutdown")
	if audio.has_method("shutdown"):
		audio.shutdown()
		for voice in audio.get_children():
			check(not voice.playing and voice.stream == null,"Shutdown stops voice and releases stream")
		audio.play("win")
		check(audio.get_child_count() <= 10,"Late cue cannot allocate players after shutdown")
	await create_timer(0.06).timeout
	audio.queue_free()
	await process_frame
	print("AUDIO_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
