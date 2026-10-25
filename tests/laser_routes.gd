extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await physics_frame
func release() -> void:
	for action in ["move_left","move_right","jump"]: Input.action_release(action)
func shoot(game: Node2D,target: Vector2,color: int) -> void:
	game.player.aim_at(target)
	var accepted: bool = game.portals.shoot(game.gun_origin(),target,color)
	check(accepted,"Room %d real gun shot %s color%d at %s" % [game.index+1,str(target),color,str(game.player.position)])
	await frames(5)
func walk_to(game: Node2D,x: float,limit: int = 650) -> void:
	Input.action_press("move_right")
	for i in limit:
		await physics_frame
		if game.player.position.x >= x or game.state != "playing" or game.deaths > 0: break
	Input.action_release("move_right")
	await frames(12)
func jump_to(game: Node2D,x: float) -> void:
	Input.action_press("move_right")
	Input.action_press("jump")
	for i in 100:
		await physics_frame
		if game.player.position.x >= x or game.state != "playing" or game.deaths > 0: break
	release()
	await frames(95)
func all_powered(game: Node2D) -> bool:
	for receiver in game.stage.receivers:
		if not receiver.active: return false
	return true
func all_dark(game: Node2D) -> bool:
	for receiver in game.stage.receivers:
		if receiver.active: return false
	return true
func prepare(game: Node2D,index: int) -> void:
	match index:
		19:
			await shoot(game,Vector2(340,300),0)
			await shoot(game,Vector2(100,480),1)
		20:
			await shoot(game,Vector2(300,480),0)
			await shoot(game,Vector2(620,480),1)
		24:
			await shoot(game,Vector2(300,220),0)
			await walk_to(game,390)
			await shoot(game,Vector2(440,100),1)
			check(game.stage.gates[0].open and not game.stage.gates[1].open,"First circuit unlocks access but cannot open the final gate")
			await walk_to(game,620)
			await shoot(game,Vector2(700,480),0)
			await shoot(game,Vector2(820,280),1)
	await frames(8)
func finish(game: Node2D,index: int) -> void:
	match index:
		20:
			await walk_to(game,240)
			await jump_to(game,390)
			await walk_to(game,560)
			await jump_to(game,710)
		24:
			await walk_to(game,640)
			await jump_to(game,785)
	await walk_to(game,925)
func run() -> void:
	check(ResourceLoader.exists("res://levels/laser_rooms.gd"),"Curated laser chapter exists")
	if not ResourceLoader.exists("res://levels/laser_rooms.gd"):
		quit(1)
		return
	var maps = load("res://levels/maps.gd")
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for index in [19,20,24]:
		check(not maps.get_level(maps.index_for_id(index+1)).is_empty(),"Room %d is delegated through Maps" % [index+1])
		if maps.get_level(maps.index_for_id(index+1)).is_empty(): continue
		game.start_level(maps.index_for_id(index+1))
		await frames(5)
		await walk_to(game,925,520)
		check(game.state != "won" and all_dark(game),"Room %d unaltered laser and ordinary walking cannot bypass its closed gate" % [index+1])
		check(game.player.position.x <= game.stage.gates[0].rect.position.x - 10.9,"Room %d closed gate physically stops the player" % [index+1])
		game.start_level(maps.index_for_id(index+1))
		await frames(5)
		await prepare(game,index)
		check(all_powered(game),"Room %d powers every receiver by real portal beams" % [index+1])
		var retry := InputEventKey.new()
		retry.pressed = true
		retry.physical_keycode = KEY_R
		game._unhandled_input(retry)
		await frames(55)
		check(all_dark(game) and game.portals.doors[0].is_empty() and game.portals.doors[1].is_empty(),"Room %d R clears power and portals" % [index+1])
		check(game.player.position.distance_to(game.player.spawn) < 1,"Room %d R restores actual spawn" % [index+1])
		for gate in game.stage.gates:
			check(not gate.open and gate.body.collision_layer == 1,"Room %d R restores closed gate collision" % [index+1])
		game.start_level(maps.index_for_id(index+1))
		await frames(5)
		await prepare(game,index)
		await finish(game,index)
		print("LASER_ROOM=",index+1," state=",game.state," deaths=",game.deaths," end=",game.player.position," transfers=",game.transfers)
		check(game.state == "won" and game.deaths == 0,"Room %d real-input standard route reaches its exit" % [index+1])
		release()
	await game.drain_audio()
	# Fixed-fps tests advance virtual timers faster than the audio mixer clock.
	OS.delay_msec(350)
	paused = false
	game.queue_free()
	await process_frame
	print("LASER_ROUTE_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
