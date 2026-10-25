extends SceneTree

var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await physics_frame
func release() -> void:
	for action in ["move_left", "move_right", "jump"]:
		if InputMap.has_action(action): Input.action_release(action)

func route(game, index: int, plain := false) -> Dictionary:
	release()
	game.start_level(load("res://levels/maps.gd").index_for_id(index+1))
	await frames(4)
	if plain: game.player.materials.clear()
	var shot := true
	if index == 10:
		shot = game.portals.shoot(game.gun_origin(),Vector2(40,60),1) and game.portals.shoot(game.gun_origin(),Vector2(450,364),0)
	elif index == 13:
		shot = game.portals.shoot(game.gun_origin(),Vector2(100,60),1)
	elif index == 16:
		shot = game.portals.shoot(game.gun_origin(),Vector2(650,450),1)
	Input.action_press("move_right")
	var action_done := false
	var jump_frame := -1
	var bounces := 0
	var distance := 0.0
	var transfers := 0
	var speed := 0.0
	for frame in 1100:
		await physics_frame
		var p: Vector2 = game.player.position
		if index in [13,16] and (game.player.bounces > bounces or game.transfers > transfers):
			print("COATING_EVENT room=",index+1," p=",p," v=",game.player.velocity," incoming=",game.player.previous_velocity)
		bounces = maxi(bounces,game.player.bounces)
		distance = maxf(distance,game.player.boost_distance)
		transfers = maxi(transfers,game.transfers)
		speed = maxf(speed,absf(game.player.velocity.x))
		if index == 13 and p.x > 350 and not action_done:
			shot = game.portals.shoot(game.gun_origin(),Vector2(500,480),0) and shot
			action_done = true
		elif index == 18 and not action_done:
			var threshold := 520.0
			if p.x >= threshold and game.player.is_on_floor():
				Input.action_press("jump")
				jump_frame = frame
				action_done = true
		elif index == 16 and p.x > 310 and not action_done:
			shot = game.portals.shoot(game.gun_origin(),Vector2(470,480),0) and shot
			action_done = true
		if jump_frame >= 0 and frame - jump_frame == 80: Input.action_release("jump")
		if game.state == "won" or game.deaths > 0: break
	release()
	var result := {"won":game.state == "won","deaths":game.deaths,"bounces":bounces,"distance":distance,"transfers":transfers,"speed":speed,"shot":shot,"end":game.player.position}
	print("COATING_ROUTE room=",index+1," plain=",plain," ",result)
	return result

func run() -> void:
	var exists := ResourceLoader.exists("res://levels/coating_rooms.gd")
	check(exists,"Curated coating chapter exists")
	if not exists:
		print("COATING_ROUTE_FAILURES=",failures)
		quit(1)
		return
	var maps = load("res://levels/maps.gd")
	check(not maps.get_level(9).is_empty(),"Coating chapter is connected to the live game")
	if maps.get_level(9).is_empty():
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for index in [9,10,13,16,18]:
		var result := await route(game,index)
		check(result.won and result.deaths == 0 and result.shot,"Room%d completes through real movement and visible portal shots" % (index+1))
		if index in [9,13,18]:
			check(result.bounces > 0,"Room%d route physically uses blue coating" % (index+1))
		if index in [10,16,18]:
			check(result.distance > 40 and result.speed > 300,"Room%d route physically uses red coating" % (index+1))
		if index in [10,13,16]:
			check(result.transfers > 0,"Room%d route physically crosses prepared portals" % (index+1))
	for index in [9,10]:
		var control := await route(game,index,true)
		check(not control.won,"Room%d same-input control fails without coatings" % (index+1))
	for index in [9,10]:
		game.start_level(load("res://levels/maps.gd").index_for_id(index+1))
		await frames(4)
		if index == 10:
			game.portals.shoot(game.gun_origin(),Vector2(40,60),1)
			game.portals.shoot(game.gun_origin(),Vector2(450,364),0)
		Input.action_press("move_right")
		await frames(90 if index == 9 else 40)
		release()
		check(game.player.bounces > 0 if index == 9 else game.player.boost_distance > 40,"Room%d retry fixture physically uses coating first" % (index+1))
		var retry := InputEventKey.new()
		retry.pressed = true
		retry.physical_keycode = KEY_R
		game._unhandled_input(retry)
		await frames(50)
		check(game.player.bounces == 0 and game.player.boost_distance == 0 and game.player.position.distance_to(game.player.spawn) < 1,"Room%d R resets coating evidence and spawn" % (index+1))
		check(game.portals.doors[0].is_empty() and game.portals.doors[1].is_empty() and not game.player.materials.is_empty(),"Room%d R clears portals and retains the map coating" % (index+1))
	await game.drain_audio()
	OS.delay_msec(350)
	paused = false
	game.queue_free()
	await process_frame
	print("COATING_ROUTE_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
