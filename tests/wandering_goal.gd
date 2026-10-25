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
func screenshot(name: String,game=null) -> void:
	if not capture: return
	await process_frame
	if game!=null: game.panel.hide()
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://docs/wandering-goal-preview/"+name+".png")
	if game!=null: game.panel.show()
func route(game,delay: int=0,wall_shift: float=0,slope_shift: float=0,mode: String="normal",stop_after: int=0) -> Dictionary:
	release()
	game.start_level(26)
	await frames(5+delay)
	if mode=="no_red": game.player.materials.clear()
	var n := Vector2(-1,-1).normalized()
	var first_wall := Vector2(124,174+wall_shift)
	if mode=="direct": first_wall = Vector2(885,145)+n*10
	var bottom := Vector2(200,335)
	var right_wall := Vector2(800,324)
	var slope := Vector2(847.5,182.5)+n*10+Vector2(-n.y,n.x)*slope_shift
	var first_exit := {}
	var second_exit := {}
	var landed := false
	var landing := Vector2.ZERO
	var shots: Array = []
	var paths: Array = [[],[],[],[]]
	var minimum_y := 540.0
	var braking := false
	var max_transfers := 0
	var record := capture and delay==0 and wall_shift==0 and slope_shift==0 and mode=="normal" and stop_after==0
	Input.action_press("move_right")
	Input.action_press("jump")
	for frame in 950:
		await physics_frame
		if frame==55: Input.action_release("jump")
		if OS.get_cmdline_user_args().has("--trace") and frame%20==0: print("WANDER_TRACE ",frame," p=",game.player.position," v=",game.player.velocity," transfers=",game.transfers," mover=",game.stage.movers[0].platform.bounds().position)
		minimum_y = minf(minimum_y,game.player.position.y)
		max_transfers = maxi(max_transfers,game.transfers)
		if game.transfers==0:
			if game.player.position.x>145: braking = true
			if braking:
				Input.action_release("move_right")
				if game.player.velocity.x>0: Input.action_press("move_left")
				else: Input.action_release("move_left")
			for shot in [{"target":first_wall,"color":1,"normal":n if mode=="direct" else Vector2.RIGHT},{"target":bottom,"color":0,"normal":Vector2.UP}]:
				var candidate: Dictionary = game.portals.candidate(game.gun_origin(),shot.target,shot.color)
				if game.portals.doors[shot.color].is_empty() and not candidate.is_empty() and candidate.n.is_equal_approx(shot.normal):
					if game.portals.shoot(game.gun_origin(),shot.target,shot.color): shots.append({"phase":0,"color":shot.color,"frame":frame,"p":game.portals.doors[shot.color].p})
		elif game.transfers==1:
			if first_exit.is_empty():
				first_exit = {"p":game.player.position,"v":game.player.velocity,"frame":frame}
				release()
				if mode!="direct": Input.action_press("move_right")
				if record: await screenshot("room27-first-exit")
			if mode=="direct" and game.player.is_on_floor() and absf(game.player.position.y+15-game.stage.movers[0].platform.bounds().position.y)<2:
				landed = true
				Input.action_press("move_right")
			if game.player.position.x>600 and game.player.is_on_floor() and mode not in ["first_only","direct"]:
				for shot in [{"target":slope,"color":1,"normal":n},{"target":right_wall,"color":0,"normal":Vector2.LEFT}]:
					var candidate: Dictionary = game.portals.candidate(game.gun_origin(),shot.target,shot.color)
					if game.portals.doors[shot.color].p.x<500 and not candidate.is_empty() and candidate.n.is_equal_approx(shot.normal):
						if game.portals.shoot(game.gun_origin(),shot.target,shot.color): shots.append({"phase":1,"color":shot.color,"frame":frame,"p":game.portals.doors[shot.color].p})
		else:
			if second_exit.is_empty():
				second_exit = {"p":game.player.position,"v":game.player.velocity,"frame":frame}
				release()
				if record: await screenshot("room27-second-exit")
			if not landed and game.player.is_on_floor() and absf(game.player.position.y+15-game.stage.movers[0].platform.bounds().position.y)<2:
				landed = true
				landing = game.player.position
				Input.action_press("move_right")
				if record:
					await screenshot("room27-landing",game)
		var route_phase := 0 if game.transfers==0 else (3 if game.transfers>=2 else (2 if game.player.is_on_floor() else 1))
		paths[route_phase].append([game.player.position.x,game.player.position.y])
		if game.state=="won" or game.deaths>0 or stop_after>0 and game.transfers>=stop_after or mode=="first_only" and game.player.position.x>788 and game.player.is_on_floor(): break
		if mode=="no_red" and not second_exit.is_empty() and game.player.is_on_floor() and game.player.position.y>200: break
		if mode=="direct" and first_exit.is_empty() and frame>250 and game.player.is_on_floor(): break
	release()
	var result := {"won":game.state=="won","deaths":game.deaths,"transfers":game.transfers,"max_transfers":max_transfers,"first_exit":first_exit,"second_exit":second_exit,"landed":landed,"landing":landing,"end":game.player.position,"minimum_y":minimum_y,"boost_distance":game.player.boost_distance}
	print("WANDER_ROUTE delay=",delay," wall=",wall_shift," slope=",slope_shift," mode=",mode," ",result)
	if record and result.won:
		var file := FileAccess.open("res://docs/wandering-goal-preview/route.json",FileAccess.WRITE)
		var serial_shots: Array = []
		for shot in shots: serial_shots.append({"phase":shot.phase,"color":shot.color,"frame":shot.frame,"p":[shot.p.x,shot.p.y]})
		var serial_result: Dictionary = result.duplicate(true)
		for key in ["landing","end"]: serial_result[key] = [result[key].x,result[key].y]
		for key in ["first_exit","second_exit"]:
			serial_result[key].p = [result[key].p.x,result[key].p.y]
			serial_result[key].v = [result[key].v.x,result[key].v.y]
		file.store_string(JSON.stringify({"source":"Godot real-input GPU recording","paths":paths,"shots":serial_shots,"result":serial_result,"goal":[game.data.goal.position.x,game.data.goal.position.y,game.data.goal.size.x,game.data.goal.size.y],"platform":[game.stage.movers[0].platform.bounds().position.x,90,180,20]},"  "))
	return result
func run() -> void:
	var maps = load("res://levels/maps.gd")
	check(maps.index_for_id(54)==26,"New user sketch is room27 stableID54")
	if maps.index_for_id(54)<0:
		quit(1)
		return
	capture = OS.get_cmdline_user_args().has("--capture")
	if capture: DirAccess.make_dir_recursive_absolute("res://docs/wandering-goal-preview")
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(26)
	await frames(5)
	await screenshot("room27")
	var result := await route(game)
	check(result.won and result.deaths==0 and result.transfers==2 and result.landed and result.boost_distance>100,"Birth inputs, two real portal transfers, red run and actual moving-platform landing reach the moving goal")
	for variant in [[0,-6,0],[0,6,0],[0,0,-3],[0,0,3],[30,0,0],[60,0,0]]:
		result = await route(game,variant[0],variant[1],variant[2])
		check(result.won and result.deaths==0 and result.transfers==2 and result.landed,"Nearby doors or short launch delays preserve the complete moving-target route")
	result = await route(game,0,0,0,"no_red")
	check(not result.won and result.max_transfers==2,"Without red acceleration the same second launch cannot reach the moving goal")
	result = await route(game,0,0,0,"first_only")
	check(not result.won and result.max_transfers==1,"First horizontal fling alone cannot finish the upper moving gate")
	result = await route(game,0,0,0,"direct")
	check(not result.won,"Jumping to pre-place the right slope cannot skip the red relay")
	result = await route(game,330)
	check(not result.won and result.deaths==1 and result.max_transfers==1 and result.second_exit.is_empty() and result.end.x>330 and result.end.x<440,"A later guard phase really collides with the first cross-pit flight")
	result = await route(game,0,0,0,"normal",2)
	check(result.max_transfers==2 and game.portals.active(),"Retry fixture reaches the actual second portal exit")
	var frozen_player: Vector2 = game.player.position
	var frozen_goal: Rect2 = game.data.goal
	var frozen_mover: Rect2 = game.stage.movers[0].platform.bounds()
	game.pause_menu()
	await frames(15)
	check(game.player.position==frozen_player and game.data.goal==frozen_goal and game.stage.movers[0].platform.bounds()==frozen_mover,"Pause freezes the actual route, target gate and platform together")
	game.resume()
	var retry := InputEventKey.new()
	retry.physical_keycode = KEY_R
	retry.pressed = true
	game._unhandled_input(retry)
	check(game.data.goal.position==Vector2(365.5,36) and game.stage.movers[0].platform.bounds().position==Vector2(290,90),"R immediately restores the moving goal and platform origin")
	await frames(50)
	check(game.deaths==1 and game.transfers==0 and not game.portals.active() and game.player.position.distance_to(game.player.spawn)<1 and game.player.boost_distance==0 and game.enemy.alive,"R restores spawn, doors, red count and guard without a spawn death loop")
	check(game.data.goal.position.is_equal_approx(game.stage.movers[0].platform.bounds().position+game.data.goal_offset),"Reset target continues following the restarted platform phase")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("WANDERING_GOAL_FAILURES=",failures)
	quit(0 if failures==0 else 1)
