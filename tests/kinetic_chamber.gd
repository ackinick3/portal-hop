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
		if InputMap.has_action(action) and Input.is_action_pressed(action): Input.action_release(action)
func screenshot(game,name: String) -> void:
	if not capture: return
	await process_frame
	game.panel.hide()
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://docs/kinetic-chamber-preview/"+name+".png")
	game.panel.show()
func route(game,ceiling_x: float=225,delay: int=0,floor_shift: float=0,mode: String="normal",stop_after: bool=false) -> Dictionary:
	release()
	game.start_level(27)
	await frames(5+delay)
	var floor_point := Vector2(488+floor_shift,510)
	var ceiling_point := Vector2(ceiling_x,40)
	var floor_shot := false
	var ceiling_shot := false
	if mode!="no_portals":
		floor_shot = game.portals.shoot(game.gun_origin(),floor_point,0)
		ceiling_shot = game.portals.shoot(game.gun_origin(),ceiling_point,1)
	var landed := false
	var landing := Vector2.ZERO
	var exit := {}
	var paths: Array = [[],[]]
	var max_transfers := 0
	var minimum_y := 540.0
	var previous_hazard: Rect2 = game.hazard_rects()[0]
	var hazard_contact := false
	var record := capture and ceiling_x==225 and delay==0 and floor_shift==0 and mode=="normal" and not stop_after
	Input.action_press("jump")
	for frame in 500:
		await physics_frame
		if frame==55 and Input.is_action_pressed("jump"): Input.action_release("jump")
		if OS.get_cmdline_user_args().has("--trace") and frame%20==0: print("KINETIC_TRACE ",frame," p=",game.player.position," v=",game.player.velocity," transfers=",game.transfers," goal=",game.data.goal)
		minimum_y = minf(minimum_y,game.player.position.y)
		max_transfers = maxi(max_transfers,game.transfers)
		paths[1 if max_transfers>0 else 0].append([game.player.position.x,game.player.position.y])
		if max_transfers>0 and exit.is_empty():
			exit = {"p":game.player.position,"v":game.player.velocity,"frame":frame}
			if record: await screenshot(game,"room28-ceiling-exit")
		var platform: Rect2 = game.stage.movers[0].platform.bounds()
		if max_transfers>0 and game.player.is_on_floor() and absf(game.player.position.y+15-platform.position.y)<2:
			if not landed:
				landed = true
				landing = game.player.position
				if record: await screenshot(game,"room28-landing")
			var offset: float = game.data.goal.get_center().x-game.player.position.x
			if absf(offset)>4:
				Input.action_release("move_left" if offset>0 else "move_right")
				Input.action_press("move_right" if offset>0 else "move_left")
			else:
				for action in ["move_left","move_right"]:
					if Input.is_action_pressed(action): Input.action_release(action)
		if game.deaths>0:
			hazard_contact = previous_hazard.grow(2).intersects(Rect2(game.player.position-Vector2(11,15),Vector2(22,30)))
			break
		previous_hazard = game.hazard_rects()[0]
		if game.state=="won" or stop_after and max_transfers>0: break
		if frame>180 and game.player.is_on_floor() and not landed: break
	release()
	var result := {"won":game.state=="won","deaths":game.deaths,"transfers":game.transfers,"max_transfers":max_transfers,"floor_shot":floor_shot,"ceiling_shot":ceiling_shot,"exit":exit,"landed":landed,"landing":landing,"end":game.player.position,"minimum_y":minimum_y,"hazard_contact":hazard_contact}
	print("KINETIC_ROUTE target=",ceiling_x," delay=",delay," floor=",floor_shift," mode=",mode," ",result)
	if record and result.won:
		var serial: Dictionary = result.duplicate(true)
		for key in ["landing","end"]: serial[key] = [result[key].x,result[key].y]
		serial.exit.p = [exit.p.x,exit.p.y]
		serial.exit.v = [exit.v.x,exit.v.y]
		var platforms: Array = []
		for mover in game.stage.movers:
			var r: Rect2 = mover.platform.bounds()
			platforms.append([r.position.x,r.position.y,r.size.x,r.size.y])
		var h: Rect2 = game.hazard_rects()[0]
		var guards: Array = []
		for guard in game.enemies: guards.append({"p":[guard.position.x,guard.position.y],"alive":guard.alive})
		var file := FileAccess.open("res://docs/kinetic-chamber-preview/route.json",FileAccess.WRITE)
		file.store_string(JSON.stringify({"source":"Godot real-input GPU reference, one permitted free solution","paths":paths,"result":serial,"goal":[game.data.goal.position.x,game.data.goal.position.y,42,54],"platforms":platforms,"guards":guards,"hazard":[h.position.x,h.position.y,h.size.x,h.size.y],"shots":[{"p":[floor_point.x,floor_point.y],"n":[0,-1],"color":0},{"p":[ceiling_point.x,ceiling_point.y],"n":[0,1],"color":1}]},"  "))
	return result
func run() -> void:
	var maps = load("res://levels/maps.gd")
	check(maps.index_for_id(55)==27,"User sketch is room28 stableID55")
	if maps.index_for_id(55)<0:
		quit(1)
		return
	capture = OS.get_cmdline_user_args().has("--capture")
	if capture: DirAccess.make_dir_recursive_absolute("res://docs/kinetic-chamber-preview")
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(27)
	await frames(5)
	await screenshot(game,"room28")
	var result := await route(game)
	check(result.won and result.deaths==0 and result.transfers>=1 and result.landed and result.floor_shot and result.ceiling_shot,"Birth jump and real floor/ceiling doors land on the independently moving target")
	for variant in [[213,0,0],[237,0,0],[225,0,-8],[225,0,8],[225,24,0],[225,48,0]]:
		result = await route(game,variant[0],variant[1],variant[2])
		check(result.won and result.deaths==0 and result.landed,"Nearby ceiling/floor doors and short departure delays retain an actual target landing")
	result = await route(game,225,0,0,"no_portals")
	check(not result.won and result.max_transfers==0,"An ordinary birth jump without portals does not reach the upper moving target")
	result = await route(game,800)
	check(not result.won and not result.landed,"A distant ceiling exit cannot count as landing on the moving goal")
	result = await route(game,350)
	check(not result.won and result.deaths==1 and result.hazard_contact,"A different free ceiling aim actually falls into the moving spike platform")
	result = await route(game,225,0,0,"normal",true)
	check(result.max_transfers>0 and game.portals.active(),"Retry fixture reaches the real ceiling exit")
	var player_at: Vector2 = game.player.position
	var goal_at: Rect2 = game.data.goal
	var spike_at: Rect2 = game.hazard_rects()[0]
	var guards_at: Array = game.enemies.map(func(g): return g.position)
	game.pause_menu()
	await frames(20)
	check(game.player.position==player_at and game.data.goal==goal_at and game.hazard_rects()[0]==spike_at and game.enemies.map(func(g): return g.position)==guards_at,"Pause freezes the actual reference route and every moving hazard")
	game.resume()
	var retry := InputEventKey.new()
	retry.physical_keycode = KEY_R
	retry.pressed = true
	game._unhandled_input(retry)
	check(game.stage.movers[0].platform.bounds().position==Vector2(120,170) and game.stage.movers[1].platform.bounds().position==Vector2(151,367) and game.data.goal.position==Vector2(152,116) and game.hazard_rects()[0].position==Vector2(151,345),"R immediately restores both paths, target and attached spikes")
	await frames(50)
	check(game.deaths==1 and game.transfers==0 and not game.portals.active() and game.player.position.distance_to(game.player.spawn)<1 and game.enemies.all(func(g): return g.alive),"R restores the real birth state and all six guards without a retry loop")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("KINETIC_CHAMBER_FAILURES=",failures)
	quit(0 if failures==0 else 1)
