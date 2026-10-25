extends SceneTree
var failures := 0
var capture := false
func _initialize() -> void: call_deferred("run")
func check(ok: bool,text: String) -> void:
	print("PASS: " if ok else "FAIL: ",text)
	if not ok: failures += 1
func frames(count: int) -> void:
	for i in count: await physics_frame
func release() -> void:
	for action in ["move_left","move_right","jump"]:
		if InputMap.has_action(action): Input.action_release(action)
func screenshot(name: String) -> void:
	if not capture: return
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://docs/sloped-preview/"+name+".png")
func prepare(game,dx: float=0,ds: float=0) -> bool:
	release()
	game.start_level(23)
	await frames(5)
	Input.action_press("move_right")
	for frame in 100:
		await physics_frame
		if game.player.position.x>=226: break
	Input.action_release("move_right")
	await frames(25)
	var n := Vector2(-180,-50).normalized()
	var t := Vector2(-n.y,n.x)
	var exit_target := Vector2(640,302)+n*10+t*ds
	var shot: bool = game.portals.shoot(game.gun_origin(),Vector2(420+dx,500),0)
	shot = game.portals.shoot(game.gun_origin(),exit_target,1) and shot
	if capture and dx==0 and ds==0: await screenshot("room24-portals")
	return shot and game.player.is_on_floor() and game.deaths==0
func route(game,dx: float,ds: float,plain: bool=false,wait_frames: int=0) -> Dictionary:
	var shot := await prepare(game,dx,ds)
	if plain: game.player.materials.clear()
	Input.action_press("move_left")
	for frame in 100:
		await physics_frame
		if game.player.position.x<=160: break
	Input.action_release("move_left")
	await frames(20)
	await frames(wait_frames)
	Input.action_press("move_right")
	var released := false
	var landed := false
	var landing := Vector2.ZERO
	var bounced := false
	var max_transfers := 0
	var danger_stage := 0
	var crossed_second := false
	var crossed_third := false
	for frame in 900:
		await physics_frame
		max_transfers = maxi(max_transfers,game.transfers)
		if released and not bounced and game.player.position.x<=573 and not crossed_second:
			crossed_second = true
			print("GUARD_ROUTE2 wait=",wait_frames," player=",game.player.position," guard=",game.enemy.position if game.enemy!=null else Vector2.ZERO)
		if bounced and game.player.position.x>=511 and not crossed_third:
			crossed_third = true
			print("GUARD_ROUTE3 wait=",wait_frames," player=",game.player.position," guard=",game.enemy.position if game.enemy!=null else Vector2.ZERO)
		if game.transfers>0 and not released:
			release()
			released = true
			print("FALL_EXIT dx=",dx," ds=",ds," p=",game.player.position," v=",game.player.velocity)
		if game.player.bounces>0 and not bounced:
			bounced = true
			print("FALL_BLUE dx=",dx," ds=",ds," p=",game.player.position," v=",game.player.velocity)
			if capture and dx==0 and ds==0 and not plain: await screenshot("room24-bounce")
		if bounced and game.player.is_on_floor() and game.player.position.x>640 and not landed:
			landed = true
			landing = game.player.position
			Input.action_press("move_right")
			if capture and dx==0 and ds==0 and not plain: await screenshot("room24-landing")
		if game.deaths>0: danger_stage = 3 if bounced else (2 if released else 1)
		if game.state=="won" or game.deaths>0: break
	release()
	var result := {"won":game.state=="won","deaths":game.deaths,"shot":shot,"transfers":max_transfers,"bounced":bounced,"landed":landed,"landing":landing,"end":game.player.position,"danger_stage":danger_stage}
	print("FALL_ROUTE dx=",dx," ds=",ds," plain=",plain," ",result)
	return result
func run() -> void:
	var maps = load("res://levels/maps.gd")
	check(maps.LEVEL_COUNT==24 and maps.index_for_id(51)==23,"Approved sketch is appended as room24 with stable ID51")
	if maps.index_for_id(51)<0:
		quit(1)
		return
	capture = OS.get_cmdline_user_args().has("--capture")
	if capture: DirAccess.make_dir_recursive_absolute("res://docs/sloped-preview")
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(23)
	await frames(5)
	check(game.portals.candidate(game.gun_origin(),Vector2(420,500),0).is_empty(),"Spawn sightline cannot pass through the starting ledge")
	await screenshot("room24")
	for dx in [-8.0,0.0,8.0]:
		for ds in [-8.0,0.0,8.0]:
			var result := await route(game,dx,ds,false,320)
			check(result.won and result.deaths==0 and result.shot and result.transfers==1 and result.bounced and result.landed,"Room24 safe-phase real input route %.0f/%.0f crosses the slope and blue wall, then actually lands" % [dx,ds])
	var plain := await route(game,0,0,true)
	check(not plain.won,"The same real-input route cannot win without blue reflection")
	for wait_frames in [80,200,290,350]:
		var timed := await route(game,0,0,false,wait_frames)
		print("GUARD_PHASE wait=",wait_frames," result=",timed)
		if wait_frames in [80,200]:
			check(timed.deaths==1 and timed.danger_stage==(2 if wait_frames==80 else 3),"Real-input guard contact threatens route%d" % (2 if wait_frames==80 else 3))
		else:
			check(timed.won and timed.deaths==0 and timed.bounced and timed.landed,"Nearby safe departure phase %d still reaches the platform and goal" % wait_frames)
	check(await prepare(game),"Retry fixture prepares real portals from a legal standing place")
	check(game.portals.candidate(game.gun_origin(),Vector2(444,500),1).is_empty(),"120px floor band cannot hold both full72px portals")
	var position: Vector2 = game.player.position
	var guard_position: Vector2 = game.enemy.position
	game.pause_menu()
	await frames(20)
	check(game.player.position.is_equal_approx(position) and game.enemy.position==guard_position and game.portals.active(),"Pause freezes player/guard and retains the active slope pair")
	game.resume()
	var retry := InputEventKey.new()
	retry.physical_keycode = KEY_R
	retry.pressed = true
	game._unhandled_input(retry)
	check(game.enemy.alive and game.enemy.position==game.enemy.spawn and game.enemy.direction==1,"R restores the guard position and travel direction")
	await frames(50)
	check(game.deaths==1 and game.player.position.distance_to(game.player.spawn)<1 and game.player.bounces==0 and game.transfers==0,"R restores spawn and counters without a death loop")
	check(not game.portals.active() and game.portals.doors.all(func(door): return door.is_empty()),"R closes every real slope opening")
	await game.drain_audio()
	OS.delay_msec(350)
	paused = false
	game.queue_free()
	await process_frame
	print("FALL_BOUNCE_FAILURES=",failures)
	quit(0 if failures==0 else 1)
