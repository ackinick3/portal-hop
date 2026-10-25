extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,text: String) -> void:
	print("PASS: " if ok else "FAIL: ",text)
	if not ok: failures += 1
func frames(count: int) -> void:
	for i in count: await physics_frame
func solid(room: Node2D,r: Rect2) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = r.size
	shape.shape = box
	body.position = r.get_center()
	body.add_child(shape)
	room.add_child(body)
func run() -> void:
	var mover = load("res://world/moving_platform.gd").new()
	check("path_points" in mover,"Platforms support an ordered multi-segment track")
	if not "path_points" in mover:
		mover.free()
		quit(1)
		return
	var room := Node2D.new()
	root.add_child(room)
	mover.configure(Rect2(100,300,110,20),Vector2(300,100),120,PackedVector2Array([Vector2(100,300),Vector2(300,300),Vector2(300,100)]))
	mover.enabled = false
	room.add_child(mover)
	var rider = load("res://actors/player.gd").new()
	rider.position = Vector2(155,285)
	room.add_child(rider)
	await frames(6)
	mover.enabled = true
	await frames(100)
	check(absf(mover.bounds().position.y-300)<0.1 and mover.bounds().position.x>190,"First track leg remains horizontal")
	await frames(150)
	check(absf(mover.bounds().position.x-300)<0.1 and mover.bounds().position.y<260,"Second leg follows the actual right-angle waypoint, not its chord")
	check(rider.is_on_floor() and absf(rider.position.y+15-mover.bounds().position.y)<2,"An ordinary rider survives the horizontal-to-vertical corner")
	await frames(200)
	check(not mover._forward and mover.bounds().position.y>130 and mover.bounds().position.y<170,"Whole track reverses at its far endpoint")
	mover.reset()
	check(mover.bounds().position==Vector2(100,300) and mover._forward and mover.gear_angle==0,"Reset restores full path origin, direction and gear phase")
	room.queue_free()
	await frames(3)
	room = Node2D.new()
	root.add_child(room)
	mover = load("res://world/moving_platform.gd").new()
	mover.configure(Rect2(100,300,40,10),Vector2(300,100),48000,PackedVector2Array([Vector2(100,300),Vector2(300,300),Vector2(300,100)]))
	mover.enabled = false
	room.add_child(mover)
	solid(room,Rect2(200,200,10,50))
	await frames(3)
	mover.enabled = true
	mover._physics_process(1.0/120)
	check(mover.bounds().position.is_equal_approx(Vector2(300,100)),"A high-speed tick sweeps each leg and never cuts across the inside corner")
	mover.enabled = false
	mover.reset()
	solid(room,Rect2(250,290,5,50))
	await frames(3)
	mover.enabled = true
	mover._physics_process(1.0/120)
	check(mover.bounds().end.x<=250.1,"A thin wall on the real leg still blocks high-speed motion")
	room.queue_free()
	await frames(3)
	room = Node2D.new()
	root.add_child(room)
	mover = load("res://world/moving_platform.gd").new()
	mover.configure(Rect2(100,280,40,20),Vector2(300,480),120)
	room.add_child(mover)
	solid(room,Rect2(80,320,500,20))
	await frames(100)
	check(mover.bounds().end.y<=320.1,"Diagonal motion uses collision-normal clearance instead of projecting sideways recovery into forward progress")
	room.queue_free()
	await frames(3)
	var maps = load("res://levels/maps.gd")
	check(maps.index_for_id(55)==27,"The kinetic sketch has its own room28 stableID55")
	if maps.index_for_id(55)<0:
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(27)
	await frames(5)
	check(game.deaths==0,"The first frame never sweeps a phantom player from world origin through the six-guard field")
	check(game.enemies.size()==6 and game.enemy==game.enemies[0],"All six guards exist while the legacy first-enemy alias remains compatible")
	check(game.stage.movers.size()==2 and game.stage.movers[0].platform.path_points.size()==5 and game.stage.movers[1].platform.path_points.size()==3,"Both distinct platform tracks retain all sketch waypoints")
	var previous: Array = []
	for guard in game.enemies: previous.append(guard.position)
	await frames(120)
	var correct_motion := true
	for i in game.enemies.size():
		var guard = game.enemies[i]
		var points: PackedVector2Array = guard.patrol_points
		correct_motion = correct_motion and guard.position.distance_to(previous[i])>68 and guard.position.distance_to(previous[i])<72 and Geometry2D.get_closest_point_to_segment(guard.position,points[0],points[1]).distance_to(guard.position)<0.01
	check(correct_motion,"Six guards actually follow their own diagonal/horizontal segments at existing70px/s")
	var hazards: Array = game.hazard_rects()
	check(hazards.size()==1 and hazards[0].position.is_equal_approx(game.stage.movers[1].platform.bounds().position+Vector2(0,-22)),"Spikes use the second real platform position as their collision anchor")
	var frozen_goal: Rect2 = game.data.goal
	var frozen_hazard: Rect2 = hazards[0]
	var frozen_guards: Array = game.enemies.map(func(g): return g.position)
	game.pause_menu()
	await frames(20)
	check(game.data.goal==frozen_goal and game.hazard_rects()[0]==frozen_hazard and game.enemies.map(func(g): return g.position)==frozen_guards,"Pause freezes target, spikes and the full guard roster")
	game.resume()
	game.player.die()
	check(game.enemies.all(func(g): return g.alive and g.position==g.spawn and g.direction==1),"Death resets every guard, including diagonal patrol direction")
	await frames(50)
	print("KINETIC_RESPAWN deaths=",game.deaths," p=",game.player.position," spawn=",game.player.spawn," dead=",game.player.dead_time," hazard=",game.hazard_rects())
	check(game.deaths==1 and game.player.position.distance_to(game.player.spawn)<1,"The dense stage does not create a spawn death loop")
	game.player.position = game.hazard_rects()[0].get_center()
	game.player.velocity = Vector2.ZERO
	await frames(3)
	print("KINETIC_SPIKE deaths=",game.deaths," p=",game.player.position," dead=",game.player.dead_time)
	check(game.deaths==2,"The rendered moving spike area is actually lethal; fixture placement is separate from route evidence")
	await frames(50)
	game.player.position = game.enemies[5].position+Vector2(25,0)
	game.player.previous_position = game.player.position
	game.player.previous_velocity = Vector2.ZERO
	game.player.velocity = Vector2.ZERO
	await frames(3)
	check(game.deaths==3,"A non-first roster member really detects side contact; mechanism fixture only")
	await frames(50)
	var no_overlap := true
	var reached_next_leg := false
	var worst_overlap := 0.0
	var furthest := 0.0
	var guards_bounded := true
	var reversed: Array = [false,false,false,false,false,false]
	for i in 2500:
		await physics_frame
		var goal_platform: Rect2 = game.stage.movers[0].platform.bounds()
		var spike_platform: Rect2 = game.stage.movers[1].platform.bounds()
		no_overlap = no_overlap and goal_platform.intersection(spike_platform).get_area()<0.5
		worst_overlap = maxf(worst_overlap,goal_platform.intersection(spike_platform).get_area())
		furthest = maxf(furthest,game.stage.movers[0].platform._travel)
		for j in game.enemies.size():
			var guard = game.enemies[j]
			guards_bounded = guards_bounded and Geometry2D.get_closest_point_to_segment(guard.position,guard.patrol_points[0],guard.patrol_points[1]).distance_to(guard.position)<0.02
			reversed[j] = reversed[j] or guard.direction<0
		reached_next_leg = reached_next_leg or absf(goal_platform.position.x-670)<0.1 and goal_platform.position.y<340
	print("KINETIC_CROSSING overlap=",worst_overlap," reached=",reached_next_leg," furthest=",furthest," target=",game.stage.movers[0].platform.bounds()," spikes=",game.stage.movers[1].platform.bounds())
	check(no_overlap and reached_next_leg,"Crossing platform tracks remain solid and recover from blocking into the next leg")
	check(guards_bounded and reversed.all(func(v): return v),"Every new patrol stays on its finite segment and really reverses at an endpoint")
	check(game.deaths==3 and game.player.position.distance_to(game.player.spawn)<1,"Longer patrol/platform phases keep the protected birth location safe")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("KINETIC_STAGE_FAILURES=",failures)
	quit(0 if failures==0 else 1)
