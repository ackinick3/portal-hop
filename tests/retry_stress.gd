extends SceneTree
var failures := 0
var cases := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func frames(count: int) -> void:
	for i in count: await physics_frame
func shot(game: Node2D,point: Vector2,color: int) -> bool:
	return game.portals.shoot(game.gun_origin(),point,color)
func prepare_power(game: Node2D,number: int) -> void:
	var reverse := number == 44
	var floor_y := 500.0 if number in [43,48] else 480.0
	var target := Vector2(60 if reverse else 900,280 if number == 48 else 200)
	check(shot(game,Vector2(560 if reverse else 400,220),0),"Powered retry %d prepares the real beam entrance" % number)
	var origin: Vector2 = game.gun_origin()
	var virtual := Vector2(target.x,2*floor_y-target.y)
	var aim := origin+(virtual-origin)*((floor_y-origin.y)/(virtual.y-origin.y))
	check(shot(game,aim,1),"Powered retry %d reflects the real exit shot" % number)
	await frames(6)
	if number in [47,50]:
		check(shot(game,Vector2(845,400) if number == 47 else Vector2(900,260),1),"Powered retry lights the second actual circuit")
		await frames(6)
	check(game.stage.receivers.all(func(r): return r.active),"Powered retry %d starts with its receivers lit" % number)
func retry_case(game: Node2D,number: int,phase: int,powered: bool) -> void:
	game.start_level(load("res://levels/maps.gd").index_for_id(number))
	await frames(5)
	if powered: await prepare_power(game,number)
	await frames(phase)
	var mover_positions: Array = []
	for mover in game.stage.movers: mover_positions.append(mover.platform.bounds())
	var player_position: Vector2 = game.player.position
	var clock: float = game.stage.time
	game.pause_menu()
	await frames(12)
	var frozen: bool = game.player.position.is_equal_approx(player_position) and is_equal_approx(game.stage.time,clock)
	for i in game.stage.movers.size(): frozen = frozen and game.stage.movers[i].platform.bounds().is_equal_approx(mover_positions[i])
	check(frozen,"Room %d phase %d pause freezes rider and machinery" % [number,phase])
	game.resume()
	var deaths_before: int = game.deaths
	var retry := InputEventKey.new()
	retry.pressed = true
	retry.physical_keycode = KEY_R
	game._unhandled_input(retry)
	await frames(45)
	var dark: bool = game.stage.receivers.all(func(r): return not r.active)
	var closed: bool = game.stage.gates.all(func(gate): return not gate.open)
	check(game.state == "playing" and game.player.dead_time <= 0 and game.deaths == deaths_before+1,"Room %d phase %d R respawns once without a death loop" % [number,phase])
	check(dark and closed and game.portals.doors.all(func(door): return door.is_empty()),"Room %d phase %d clears circuits, gates and portals" % [number,phase])
	check(game.player.position.distance_to(game.player.spawn) < 85,"Room %d phase %d returns near its actual spawn" % [number,phase])
	check(is_finite(game.player.velocity.x) and is_finite(game.player.velocity.y),"Room %d retry leaves finite movement" % number)
	for i in game.stage.movers.size():
		var spec: Dictionary = game.data.movers[i]
		if not spec.get("requires",[]).is_empty():
			check(not game.stage.movers[i].platform.enabled and game.stage.movers[i].platform.bounds().position.is_equal_approx(spec.rect.position),"Powered mover %d returns to its parked origin" % number)
	cases += 1
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for number in load("res://levels/maps.gd").ROOM_IDS:
		for phase in [1,47,173]: await retry_case(game,number,phase,false)
	for number in [38,48,50]:
		for phase in [1,47,173]: await retry_case(game,number,phase,true)
	await game.drain_audio()
	OS.delay_msec(350)
	paused = false
	game.queue_free()
	await process_frame
	print("RETRY_STRESS_CASES=",cases," FAILURES=",failures)
	quit(0 if failures==0 else 1)
