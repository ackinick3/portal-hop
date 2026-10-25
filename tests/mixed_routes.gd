extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func frames(n: int) -> void:
	for i in n: await physics_frame
func run() -> void:
	var maps = load("res://levels/maps.gd")
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(maps.index_for_id(34))
	await frames(4)
	check(game.portals.shoot(game.gun_origin(),Vector2(120,340),0),"New18 places the real laser entrance")
	check(game.portals.shoot(game.gun_origin(),Vector2(610,140),1),"New18 powers the first circuit with a real shot")
	await frames(4)
	check(game.stage.receivers[0].active and not game.stage.receivers[1].active,"First light leaves the final circuit unpowered")
	Input.action_press("move_right")
	var changed := false
	var peak := 0.0
	for i in 700:
		await physics_frame
		peak = maxf(peak,absf(game.player.velocity.x))
		if game.player.position.x > 260 and not changed:
			changed = game.portals.shoot(game.gun_origin(),Vector2(610,180),1)
		if game.state == "won" or game.deaths > 0: break
	Input.action_release("move_right")
	check(changed and game.stage.receivers.all(func(r): return r.active),"New18 opens both circuits through actual beam paths")
	check(game.player.bounces > 0 and game.player.boost_distance > 50 and peak > 500,"New18 uses both coatings")
	check(game.state == "won" and game.deaths == 0,"New18 actual-input route completes")
	game.start_level(maps.index_for_id(34))
	await frames(4)
	Input.action_press("move_right")
	await frames(400)
	Input.action_release("move_right")
	check(game.state != "won" and game.player.position.x < 230,"Without power the first real gate blocks the route")
	await game.drain_audio()
	OS.delay_msec(350)
	paused = false
	game.queue_free()
	await process_frame
	print("MIXED_FAILURES=",failures)
	quit(0 if failures==0 else 1)
