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
	root.get_texture().get_image().save_png("res://docs/borrowed-exit-preview/"+name+".png")
func shoot(game,target: Vector2,color: int) -> bool:
	game.player.aim_at(target)
	var accepted: bool = game.portals.shoot(game.gun_origin(),target,color)
	print("BORROWED_SHOT p=",game.player.position," target=",target," color=",color," accepted=",accepted," door=",game.portals.doors[color])
	await frames(5)
	return accepted
func walk(game,x: float,limit: int=400) -> void:
	var right: bool = x>game.player.position.x
	var action := "move_right" if right else "move_left"
	Input.action_press(action)
	for i in limit:
		await physics_frame
		if (game.player.position.x>=x if right else game.player.position.x<=x) or game.state!="playing" or game.deaths>0: break
	Input.action_release(action)
	await frames(16)
	print("BORROWED_WALK target=",x," p=",game.player.position," state=",game.state)
func prepare(game,variant: int=0,phase: int=3) -> void:
	release()
	game.start_level(28)
	await frames(5)
	# The virtual image computes an on-screen mirror aim, not an off-window mouse shot.
	var virtual := Vector2(260,-8+(-6 if variant==1 else 6 if variant==2 else 0))
	var origin: Vector2 = game.gun_origin()
	var aim: Vector2 = origin+(virtual-origin)*((60-origin.y)/(virtual.y-origin.y))
	check(Rect2(0,0,960,540).has_point(aim),"Mirror aim remains inside the playable window")
	check(game.portals.shot_path(origin,aim).size()==2,"Initial real gun path reflects once from the green ceiling")
	check(await shoot(game,aim,0),"Reflected input portal is reachable from birth")
	check(await shoot(game,Vector2(100,60),1),"First ceiling exit receives the actual laser")
	check(game.stage.receivers[0].active and game.stage.gates[0].open and not game.stage.gates[1].open,"First actual beam unlocks only the first passage")
	if phase==1: return
	await walk(game,420)
	check(await shoot(game,Vector2(450+(-8 if variant==3 else 8 if variant==4 else 0),60),1),"Second output is placed from the middle chamber")
	check(game.stage.receivers[1].active and game.stage.gates[1].open and not game.stage.gates[2].open,"Second beam opens the well without opening the terminal gate")
	if phase==2: return
	await walk(game,548)
	check(await shoot(game,Vector2(840+(-8 if variant==5 else 8 if variant==6 else 0),500),1),"Third output is visible through the well")
	check(game.stage.receivers.all(func(r): return r.active) and game.stage.gates.all(func(g): return g.open),"All three receivers latch by real unobstructed light")
func finish(game,variant: int=0,leave_exit: bool=true) -> Dictionary:
	if leave_exit:
		check(await shoot(game,Vector2(920,200+(-5 if variant==7 else 4 if variant==8 else 0)),0),"Laser input is reused as the high return exit")
	var visited_lower := false
	var landed := false
	var departure: Vector2 = game.player.position
	Input.action_press("move_right")
	for i in 340:
		await physics_frame
		if game.player.position.y>300: visited_lower = true
		if game.transfers>0:
			# A transfer reverses the runner's horizontal direction. Brake with real input.
			if absf(game.player.velocity.x)<15: Input.action_release("move_right")
			if game.player.is_on_floor() and game.player.position.y<260 and game.player.position.x>=780:
				landed = true
				break
		if game.deaths>0 or game.state!="playing": break
	release()
	if capture and leave_exit and variant==0: await screenshot("room29-return")
	await frames(12)
	if landed: await walk(game,810)
	var result := {"won":game.state=="won","deaths":game.deaths,"transfers":game.transfers,"visited_lower":visited_lower,"landed":landed,"end":game.player.position,"departure":departure}
	print("BORROWED_ROUTE variant=",variant," retained_exit=",leave_exit," ",result)
	return result
func reset_key(game) -> void:
	var retry := InputEventKey.new()
	retry.physical_keycode = KEY_R
	retry.pressed = true
	game._unhandled_input(retry)
	await frames(55)
func run() -> void:
	var maps = load("res://levels/maps.gd")
	check(maps.index_for_id(56)==28,"Hard puzzle is appended as room29 stableID56")
	if maps.index_for_id(56)!=28:
		quit(1)
		return
	capture = OS.get_cmdline_user_args().has("--capture")
	if capture: DirAccess.make_dir_recursive_absolute("res://docs/borrowed-exit-preview")
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(28)
	await frames(5)
	await screenshot("room29")
	check(game.stage.receivers.all(func(r): return not r.active),"All circuits start dark")
	var direct := 0
	for y in range(84,165,2):
		if not game.portals.candidate(game.gun_origin(),Vector2(260,y),0).is_empty(): direct+=1
	check(direct==0,"Curtain and locked gate block the entire initial direct face, including endpoint clamping")
	var mirrors: Array = game.portals.mirrors.duplicate(true)
	game.portals.mirrors.clear()
	var without_mirror := 0
	for x in range(40,261,2):
		if not game.portals.candidate(game.gun_origin(),Vector2(x,60),0).is_empty():
			var c: Dictionary = game.portals.candidate(game.gun_origin(),Vector2(x,60),0)
			if c.n==Vector2.LEFT: without_mirror+=1
	check(without_mirror==0,"Removing green reflection gives no input portal through the upper window")
	game.portals.mirrors.assign(mirrors)
	Input.action_press("move_right")
	await frames(70)
	Input.action_press("jump")
	await frames(100)
	release()
	check(game.player.position.x<200 and game.stage.receivers.all(func(r): return not r.active),"Running and a full ordinary jump cannot cross the first closed gate")
	for variant in range(9):
		await prepare(game,variant)
		if capture and variant==0: await screenshot("room29-powered")
		var result := await finish(game,variant)
		check(result.won and result.deaths==0 and result.transfers>=1 and result.visited_lower and result.landed,"Real-input route and nearby optical/return positions physically land upstairs before the goal")
		if OS.get_cmdline_user_args().has("--core-only"): break
	if not OS.get_cmdline_user_args().has("--core-only"):
		await prepare(game)
		var failed := await finish(game,0,false)
		check(not failed.won and not failed.landed,"Dropping without repurposing the high exit fails to reach the terminal")
		await reset_key(game)
		check(game.deaths==1 and game.transfers==0 and game.player.position.distance_to(game.player.spawn)<1 and game.stage.receivers.all(func(r): return not r.active) and game.stage.gates.all(func(g): return not g.open) and game.portals.doors.all(func(d): return d.is_empty()),"R recovers from a wrong lower route and resets all circuits and portals")
		for phase in [1,2,3]:
			await prepare(game,0,phase)
			var at: Vector2 = game.player.position
			var time: float = game.stage.time
			game.pause_menu()
			await frames(20)
			check(game.player.position==at and game.stage.time==time,"Pause freezes the real intermediate puzzle state")
			game.resume()
			await reset_key(game)
			check(game.deaths==1 and game.player.position.distance_to(game.player.spawn)<1 and game.stage.receivers.all(func(r): return not r.active) and game.stage.gates.all(func(g): return not g.open),"Each powered phase resets without retaining a latch or trapping birth")
		await prepare(game)
		game.portals.clear()
		await frames(3)
		check(game.stage.receivers.all(func(r): return r.active),"All gates remain powered after dismantling the optical route")
		Input.action_press("move_right")
		Input.action_press("jump")
		for i in 180:
			await physics_frame
			if i==70: Input.action_release("jump")
			if game.player.position.y>300: break
		release()
		check(game.state!="won" and game.player.position.x<780 and game.player.position.y>300,"Ordinary full-speed jumping cannot bridge the upper well after opening every gate")
		await frames(80)
		check(game.portals.candidate(game.gun_origin(),Vector2(920,200),0).is_empty(),"The upper terminal exit cannot be recovered by shooting through its floor from below")
		game.player.die()
		await frames(55)
		check(game.deaths==1 and game.player.position.distance_to(game.player.spawn)<1 and game.stage.receivers.all(func(r): return not r.active),"Actual death restores the puzzle's safe initial state")
	release()
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("BORROWED_EXIT_FAILURES=",failures)
	quit(0 if failures==0 else 1)
