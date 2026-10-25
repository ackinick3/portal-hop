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
	root.get_texture().get_image().save_png("res://docs/boost-bounce-preview/"+name+".png")
func route(game,entrance_shift: float=0,exit_shift: float=0,mode: String="normal",checkpoint: bool=false) -> Dictionary:
	release()
	game.start_level(25)
	await frames(5)
	if mode!="normal":
		var patches: Array = game.player.materials.filter(func(p): return p.kind!=("boost" if mode=="no_red" else "bounce"))
		game.player.materials.assign(patches)
	var in_n := Vector2(-60,-130).normalized()
	var out_n := Vector2(61,-94).normalized()
	var in_p := Vector2(745,410)+in_n*10+Vector2(-in_n.y,in_n.x)*(entrance_shift-8)
	var out_p := Vector2(90,201+(90-40)*61.0/94)+out_n*10+Vector2(-out_n.y,out_n.x)*exit_shift
	var in_shot := false
	var out_shot := false
	var transferred := false
	var bounced := false
	var launched := false
	var landed := false
	var landing := Vector2.ZERO
	var minimum_y := 540.0
	var launch := {}
	var exit := {}
	var bounce := {}
	var paths: Array = [[],[],[],[]]
	var shots: Array = []
	var record := capture and entrance_shift==0 and exit_shift==0 and mode=="normal" and not checkpoint
	Input.action_press("move_right")
	for frame in 1300:
		await physics_frame
		if OS.get_cmdline_user_args().has("--trace") and frame%20==0: print("BOOST_ARC_TRACE ",frame," p=",game.player.position," v=",game.player.velocity," transfers=",game.transfers)
		minimum_y = minf(minimum_y,game.player.position.y)
		if not out_shot:
			var candidate: Dictionary = game.portals.candidate(game.gun_origin(),out_p,1)
			if not candidate.is_empty() and candidate.n.is_equal_approx(out_n):
				out_shot = game.portals.shoot(game.gun_origin(),out_p,1)
				if out_shot: shots.append({"kind":"exit","frame":frame,"from":[game.gun_origin().x,game.gun_origin().y],"p":[game.portals.doors[1].p.x,game.portals.doors[1].p.y]})
		if not in_shot:
			var candidate: Dictionary = game.portals.candidate(game.gun_origin(),in_p,0)
			if not candidate.is_empty() and candidate.n.is_equal_approx(in_n):
				in_shot = game.portals.shoot(game.gun_origin(),in_p,0)
				if in_shot: shots.append({"kind":"entrance","frame":frame,"from":[game.gun_origin().x,game.gun_origin().y],"p":[game.portals.doors[0].p.x,game.portals.doors[0].p.y]})
		if not launched and game.player.position.x>455:
			launched = true
			launch = {"p":game.player.position,"v":game.player.velocity}
			print("BOOST_ARC_LAUNCH ",launch)
			if record: await screenshot("room26-launch")
		if not transferred and game.transfers>0:
			transferred = true
			exit = {"p":game.player.position,"v":game.player.velocity}
			print("BOOST_ARC_EXIT ",exit)
			release()
			if record: await screenshot("room26-exit")
		if not bounced and game.player.bounces>0:
			bounced = true
			bounce = {"p":game.player.position,"v":game.player.velocity}
			print("BOOST_ARC_BOUNCE p=",game.player.position," v=",game.player.velocity)
			if record: await screenshot("room26-bounce")
		if not landed: paths[3 if bounced else (2 if transferred else (1 if launched else 0))].append([game.player.position.x,game.player.position.y])
		if bounced and game.player.is_on_floor() and game.player.position.x>600 and not landed:
			landed = true
			landing = game.player.position
			Input.action_press("move_right")
			if record: await screenshot("room26-landing")
		if game.state=="won" or game.deaths>0: break
		if checkpoint and transferred: break
	release()
	var result := {"won":game.state=="won","deaths":game.deaths,"in_shot":in_shot,"out_shot":out_shot,"transferred":transferred,"transfers":game.transfers,"bounced":bounced,"bounces":game.player.bounces,"landed":landed,"landing":landing,"minimum_y":minimum_y,"launch":launch,"exit":exit,"boost_distance":game.player.boost_distance,"end":game.player.position}
	print("BOOST_ARC_ROUTE ",entrance_shift,"/",exit_shift," mode=",mode," ",result)
	if record and result.won:
		var events: Array = []
		for event in [launch,exit,bounce]: events.append({"p":[event.p.x,event.p.y],"v":[event.v.x,event.v.y]})
		var file := FileAccess.open("res://docs/boost-bounce-preview/route.json",FileAccess.WRITE)
		file.store_string(JSON.stringify({"source":"Godot real-input GPU recording","paths":paths,"shots":shots,"events":events,"landing":[landing.x,landing.y],"minimum_center_y":minimum_y,"boost_distance":game.player.boost_distance,"transfers":game.transfers,"bounces":game.player.bounces,"deaths":game.deaths},"  "))
	return result
func run() -> void:
	var maps = load("res://levels/maps.gd")
	check(maps.LEVEL_COUNT==26 and maps.index_for_id(53)==25,"New sketch is room26 stableID53")
	if maps.index_for_id(53)<0:
		quit(1)
		return
	capture = OS.get_cmdline_user_args().has("--capture")
	if capture: DirAccess.make_dir_recursive_absolute("res://docs/boost-bounce-preview")
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(25)
	await frames(5)
	await screenshot("room26")
	var result := await route(game)
	check(result.won and result.deaths==0 and result.transfers==1 and result.bounces==1 and result.landed,"Red ramp, spike crossing, sloped portal, blue bounce and actual goal landing all occur")
	for variant in [Vector2(-6,0),Vector2(6,0),Vector2(0,-4),Vector2(0,4)]:
		result = await route(game,variant.x,variant.y)
		check(result.won and result.deaths==0 and result.transfers==1 and result.bounces==1 and result.landed and result.minimum_y>16,"Nearby sloped door targets keep the full boost/portal/bounce route and headroom")
	result = await route(game,0,0,"no_red")
	check(not result.won and result.deaths==1 and not result.transferred,"Without red acceleration the same input cannot clear the spike pit")
	result = await route(game,0,0,"no_blue")
	check(not result.won and result.transferred and not result.bounced,"Without blue rebound the same input cannot reach the upper goal")
	result = await route(game,0,0,"normal",true)
	check(result.transfers==1 and game.portals.active(),"Retry fixture reaches the actual post-spike slope exit")
	var frozen: Vector2 = game.player.position
	game.pause_menu()
	await frames(15)
	check(game.player.position==frozen and game.portals.active(),"Pause freezes the full boost relay and retains doors")
	game.resume()
	var retry := InputEventKey.new()
	retry.physical_keycode = KEY_R
	retry.pressed = true
	game._unhandled_input(retry)
	await frames(50)
	check(game.deaths==1 and game.transfers==0 and game.player.position.distance_to(game.player.spawn)<1 and game.player.boost_distance==0 and game.player.bounces==0 and not game.portals.active(),"R restores spawn, boost/bounce evidence and closed doors without a spike death loop")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("BOOST_ARC_FAILURES=",failures)
	quit(0 if failures==0 else 1)
