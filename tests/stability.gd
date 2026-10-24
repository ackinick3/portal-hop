extends SceneTree

var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await physics_frame
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(2)
	await frames(10)
	game.player.stomp_feedback()
	game.pause_menu()
	var pos: Vector2 = game.player.position
	var guard: Vector2 = game.enemy.position
	var elapsed: float = game.elapsed
	var effect: float = game.player.stomp_stretch
	await create_timer(0.12).timeout
	check(game.player.position == pos and game.enemy.position == guard,"Pause freezes player and guard")
	check(game.elapsed == elapsed and game.player.stomp_stretch == effect,"Pause freezes timer and action animation")
	game.resume()
	await frames(40)
	check(game.elapsed > elapsed and game.player.stomp_stretch == 0,"Resume advances timer and settles animation")
	game.transfers = 1
	game.player.die()
	check(game.transfers == 0,"Death resets tutorial transfer state")
	for i in 12:
		game.start_level(i % 3)
		await frames(2)
	check(game.audio.get_child_count() == 10,"Repeated room switches keep a fixed audio pool")
	await game.drain_audio()
	paused = false
	game.queue_free()
	await process_frame
	# Two nearby facing wall portals: repeatedly traverse with real player gravity and collision.
	var portals = load("res://portals/system.gd").new()
	root.add_child(portals)
	var blocks: Array[Rect2] = [Rect2(410,100,40,340),Rect2(540,100,40,340)]
	var faces: Array[Dictionary] = [{"a":Vector2(450,150),"b":Vector2(450,400),"n":Vector2.RIGHT},{"a":Vector2(540,150),"b":Vector2(540,400),"n":Vector2.LEFT}]
	portals.configure(blocks,faces)
	check(portals.shoot(Vector2(495,270),Vector2(450,270),0),"Nearby facing red wall portal places legally")
	check(portals.shoot(Vector2(495,270),Vector2(540,270),1),"Nearby facing blue wall portal places legally")
	var count := [0]
	portals.feedback.connect(func(kind):
		if kind == "teleport": count[0] += 1
	)
	var player = load("res://actors/player.gd").new()
	player.position = Vector2(495,270)
	player.velocity = Vector2(-900,0)
	player.portal_system = portals
	root.add_child(player)
	await frames(600)
	check(count[0] >= 20 and count[0] <= 70,"Continuous traversal stays finite and active for 600 physics frames")
	check(player.position.is_finite() and player.velocity.x < -400 and player.velocity.x > -950,"Close-portal loop remains bounded with gentle horizontal drag")
	check(player.dead_time == 0,"Close-portal loop does not trap or kill player")
	print("CONTINUOUS_TRANSFERS=",count[0])
	player.queue_free()
	portals.queue_free()
	await process_frame
	print("STABILITY_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
