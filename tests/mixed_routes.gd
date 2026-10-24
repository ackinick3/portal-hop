extends SceneTree
var failures := 0
func check(ok: bool,message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await physics_frame
func release() -> void:
	for action in ["move_left","move_right","jump"]: Input.action_release(action)
func shot(game: Node2D,point: Vector2,color: int) -> bool:
	return game.portals.shoot(game.gun_origin(),point,color)
func run() -> void:
	var maps = load("res://levels/maps.gd")
	check(not maps.get_level(25).is_empty(),"Mixed coating and laser rooms exist")
	if maps.get_level(25).is_empty():
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for room in range(26,36):
		game.start_level(room-1)
		await frames(4)
		var reverse := room in [30,35]
		var entry := Vector2(300,110)
		var output := Vector2(610,140)
		if room in [28,30]: entry = Vector2(220,270)
		if room == 29: output = Vector2(540,200)
		if room in [32,33,34,35]: entry = Vector2(120,340)
		if reverse:
			entry.x = 960-entry.x
			output.x = 960-output.x
		check(shot(game,entry,0),"Room %d places the laser entry from spawn" % room)
		var first_output := false
		var second_output := false
		if room not in [32,33,35]:
			first_output = shot(game,output,1)
			await frames(3)
			if room in [27,31]:
				if room == 31: check(shot(game,Vector2(300,180),0),"Second source is selected with actual RED shot")
				second_output = shot(game,Vector2(610,180),1)
				await frames(3)
		var direction := "move_left" if reverse else "move_right"
		Input.action_press(direction)
		var peak := 0.0
		for i in 700:
			await physics_frame
			peak = maxf(peak,absf(game.player.velocity.x))
			var progress: float = 960-game.player.position.x if reverse else game.player.position.x
			if room in [32,33,35] and game.player.bounces > 0 and progress > 450 and not first_output:
				first_output = shot(game,output,1)
			if room in [33,35] and first_output and progress > 560 and not second_output:
				var second := Vector2(350,180) if reverse else Vector2(610,180)
				second_output = shot(game,second,1)
			if room == 34 and progress > 260 and not second_output:
				second_output = shot(game,Vector2(610,180),1)
			if game.state == "won" or game.deaths > 0: break
		release()
		var powered := true
		for receiver in game.stage.receivers: powered = powered and receiver.active
		print("MIXED_ROOM ",room," win=",game.state," p=",game.player.position," bounce=",game.player.bounces," run=",game.player.boost_distance," peak=",peak," power=",powered)
		check(first_output and powered,"Room %d uses actual portal-directed laser power" % room)
		check(game.player.bounces > 0 and game.player.boost_distance > 50 and peak > 500,"Room %d actually uses both coatings" % room)
		check(game.state == "won" and game.deaths == 0,"Room %d completes with real inputs" % room)
	game.start_level(25)
	await frames(4)
	Input.action_press("move_right")
	for i in 650:
		await physics_frame
		if game.deaths > 0 or game.state == "won": break
	release()
	check(game.state != "won","Unpowered gate blocks even a boosted blue launch")
	await game.drain_audio()
	OS.delay_msec(350)
	paused = false
	game.queue_free()
	await process_frame
	print("MIXED_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
