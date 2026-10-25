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
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://docs/double-return-preview/"+name+".png")
func route(game,first_x: float=365,second_x: float=635,exit_shift: float=0,mode: String="relay",initial_jump: bool=false) -> Dictionary:
	release()
	game.start_level(24)
	await frames(5)
	var n := Vector2(108,-103).normalized()
	var t := Vector2(-n.y,n.x)
	var exit_target := Vector2(242,150+(242-175)*108.0/103)+n*10+t*exit_shift
	if mode=="floor_pair": exit_target = Vector2(600,400)
	var slope_shot := false
	var first_shot := false
	var second_shot := false
	var transfers := 0
	var landed := false
	var landing := Vector2.ZERO
	var minimum_y := 540.0
	var events: Array = []
	var paths: Array = [[],[],[]]
	var shots: Array = []
	var jumped := false
	Input.action_press("move_right")
	for frame in 1100:
		await physics_frame
		if OS.get_cmdline_user_args().has("--trace") and frame%20==0: print("ASCENT_TRACE ",frame," p=",game.player.position," v=",game.player.velocity," floor=",game.player.is_on_floor()," doors=",game.portals.doors)
		if OS.get_cmdline_user_args().has("--trace") and frame>80 and frame<120 and game.player.get_slide_collision_count()>0: print("ASCENT_COLLISION ",frame," p=",game.player.position," v=",game.player.velocity," hit=",game.player.get_slide_collision(0).get_position()," normal=",game.player.get_slide_collision(0).get_normal())
		minimum_y = minf(minimum_y,game.player.position.y)
		if initial_jump and not jumped and game.player.position.x>=158 and game.player.is_on_floor():
			Input.action_press("jump")
			jumped = true
		if jumped and game.player.position.x>200: Input.action_release("jump")
		if not slope_shot:
			var candidate: Dictionary = game.portals.candidate(game.gun_origin(),exit_target,1)
			if not candidate.is_empty() and candidate.n.is_equal_approx(Vector2.UP if mode=="floor_pair" else n):
				slope_shot = game.portals.shoot(game.gun_origin(),exit_target,1)
				if slope_shot: shots.append({"kind":"exit","frame":frame,"from":[game.gun_origin().x,game.gun_origin().y],"p":[game.portals.doors[1].p.x,game.portals.doors[1].p.y]})
		if not first_shot:
			var candidate: Dictionary = game.portals.candidate(game.gun_origin(),Vector2(first_x,400),0)
			if not candidate.is_empty() and candidate.n==Vector2.UP:
				first_shot = game.portals.shoot(game.gun_origin(),Vector2(first_x,400),0)
				if first_shot: shots.append({"kind":"first_floor","frame":frame,"from":[game.gun_origin().x,game.gun_origin().y],"p":[game.portals.doors[0].p.x,game.portals.doors[0].p.y]})
		if game.transfers>transfers:
			transfers = game.transfers
			events.append({"p":game.player.position,"v":game.player.velocity})
			print("SECOND_ASCENT_EXIT ",transfers," ",events[-1])
			release()
			if transfers==1: Input.action_press("move_right" if mode in ["one_pass","floor_pair"] else "move_left")
			if first_x==365 and second_x==635 and exit_shift==0 and mode=="relay": await screenshot("room25-exit%d" % transfers)
		if mode=="relay" and transfers==1 and not second_shot and game.player.velocity.y>0 and game.player.position.x>400:
			second_shot = game.portals.shoot(game.gun_origin(),Vector2(second_x,400),0)
			if second_shot: shots.append({"kind":"second_floor","frame":frame,"from":[game.gun_origin().x,game.gun_origin().y],"p":[game.portals.doors[0].p.x,game.portals.doors[0].p.y]})
		if mode=="no_replace" and transfers==1 and game.player.is_on_floor(): release()
		if not landed: paths[mini(transfers,2)].append([game.player.position.x,game.player.position.y])
		if transfers>=2 and game.player.is_on_floor() and game.player.position.x>650 and not landed:
			landed = true
			landing = game.player.position
			Input.action_press("move_right")
			if first_x==365 and second_x==635 and exit_shift==0 and mode=="relay": await screenshot("room25-landing")
		if game.state=="won" or game.deaths>0: break
		if mode=="checkpoint" and transfers==1: break
	release()
	var result := {"won":game.state=="won","deaths":game.deaths,"transfers":transfers,"slope_shot":slope_shot,"first_shot":first_shot,"second_shot":second_shot,"landed":landed,"landing":landing,"minimum_y":minimum_y,"events":events,"end":game.player.position}
	print("SECOND_ASCENT_ROUTE ",first_x,"/",second_x,"/",exit_shift," mode=",mode," jump=",initial_jump," ",result)
	if capture and result.won and first_x==365 and second_x==635 and exit_shift==0 and mode=="relay":
		var file := FileAccess.open("res://docs/double-return-preview/route.json",FileAccess.WRITE)
		file.store_string(JSON.stringify({"source":"Godot real-input GPU route recording","paths":paths,"shots":shots,"events":events.map(func(e): return {"p":[e.p.x,e.p.y],"v":[e.v.x,e.v.y]}),"landing":[landing.x,landing.y],"minimum_center_y":minimum_y,"deaths":game.deaths,"transfers":transfers},"  "))
	return result
func run() -> void:
	var maps = load("res://levels/maps.gd")
	check(maps.LEVEL_COUNT>=25 and maps.index_for_id(52)==24,"New sketch is room25 stableID52")
	if maps.index_for_id(52)<0:
		quit(1)
		return
	capture = OS.get_cmdline_user_args().has("--capture")
	if capture: DirAccess.make_dir_recursive_absolute("res://docs/double-return-preview")
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(24)
	await frames(5)
	await screenshot("room25")
	var result := await route(game)
	check(result.won and result.deaths==0 and result.transfers==2 and result.landed,"Real-input two-stage relay reaches the final platform and goal")
	for variant in [Vector3(359,641,0),Vector3(371,629,0),Vector3(365,635,-4),Vector3(365,635,4)]:
		result = await route(game,variant.x,variant.y,variant.z)
		check(result.won and result.deaths==0 and result.transfers==2 and result.landed and result.minimum_y>16,"Nearby gate targets preserve two real transfers, headroom and landing")
	for mode in ["no_replace","one_pass","floor_pair"]:
		result = await route(game,365,635,0,mode,mode=="floor_pair")
		check(result.first_shot and result.slope_shot and not result.won,"Real-input bypass/control fails: "+mode)
	result = await route(game,365,635,0,"one_pass",true)
	check(result.transfers==1 and not result.won,"Starting jump cannot skip the second relay through the low roof")
	result = await route(game,365,635,0,"checkpoint")
	check(result.transfers==1 and game.portals.active(),"Retry fixture reaches the first actual slope exit")
	var frozen: Vector2 = game.player.position
	game.pause_menu()
	await frames(15)
	check(game.player.position==frozen and game.portals.active(),"Pause freezes the relay with both actual doors retained")
	game.resume()
	var retry := InputEventKey.new()
	retry.physical_keycode = KEY_R
	retry.pressed = true
	game._unhandled_input(retry)
	await frames(50)
	check(game.deaths==1 and game.transfers==0 and game.player.position.distance_to(game.player.spawn)<1 and not game.portals.active(),"R restores the starting tunnel and closes doors without a death loop")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("SECOND_ASCENT_FAILURES=",failures)
	quit(0 if failures==0 else 1)
