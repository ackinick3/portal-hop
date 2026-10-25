extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,text: String) -> void:
	print("PASS: " if ok else "FAIL: ",text)
	if not ok: failures += 1
func run() -> void:
	var p = load("res://portals/system.gd").new()
	root.add_child(p)
	check("gun_screens" in p,"Gun-only screens are represented separately from physical and laser blockers")
	if not "gun_screens" in p:
		p.queue_free()
		await process_frame
		quit(1)
		return
	var blocks: Array[Rect2] = [Rect2(700,0,20,540)]
	var faces: Array[Dictionary] = [{"a":Vector2(700,40),"b":Vector2(700,480),"n":Vector2.LEFT}]
	p.configure(blocks,faces)
	p.gun_screens.assign([{"a":Vector2(400,100),"b":Vector2(400,400)}])
	var start := Vector2(200,250)
	var target := Vector2(700,250)
	check(p.candidate(start,target,0).is_empty() and not p.shoot(start,target,0),"Screen blocks actual portal placement and preview")
	check(p.shot_path(start,target)[0].b.is_equal_approx(Vector2(400,250)),"Visible gun path stops at green screen")
	check(p.beam_path(start,Vector2.RIGHT)[0].b.is_equal_approx(target),"Gun-only screen does not invent laser blocking")
	check(not p.candidate(Vector2(500,250),target,0).is_empty(),"After crossing the screen the same white face is shootable")
	check(not p.candidate(Vector2(200,50),Vector2(700,50),0).is_empty(),"Shots really pass around a finite screen endpoint")
	check(p.shot_path(Vector2(400,50),Vector2(400,450))[0].b.is_equal_approx(Vector2(400,100)),"A collinear gun ray also stops at the screen endpoint")
	p.solids.append(Rect2(300,200,10,100))
	check(p.shot_path(start,target)[0].b.is_equal_approx(Vector2(300,250)),"Nearer solid still wins over a screen")
	p.solids.assign(blocks)
	p.mirrors.assign([{"a":Vector2(700,40),"b":Vector2(700,480),"n":Vector2.LEFT}])
	var reflected: Array = p.shot_path(Vector2(500,250),target)
	check(reflected.size()==2 and reflected[1].b.is_equal_approx(Vector2(400,250)),"Reflected gun ray is blocked on its return path")
	var player = load("res://actors/player.gd").new()
	player.position = Vector2(380,200)
	root.add_child(player)
	Input.action_press("move_right")
	for i in 60: await physics_frame
	Input.action_release("move_right")
	check(player.position.x>420 and player.dead_time<=0,"Ordinary character passes through the gun screen without a physical collider")
	player.queue_free()
	p.queue_free()
	await process_frame
	print("GUN_SCREEN_FAILURES=",failures)
	quit(0 if failures==0 else 1)
