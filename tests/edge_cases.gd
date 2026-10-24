extends SceneTree
var failures := 0
func check(ok: bool, description: String) -> void:
	print("PASS: " if ok else "FAIL: ",description)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var p = load("res://portals/system.gd").new()
	root.add_child(p)
	var blocks: Array[Rect2] = [Rect2(100,400,50,140),Rect2(150,400,50,140),Rect2(600,400,300,140)]
	var faces: Array[Dictionary] = [{"a":Vector2(100,400),"b":Vector2(150,400),"n":Vector2.UP},{"a":Vector2(150,400),"b":Vector2(200,400),"n":Vector2.UP},{"a":Vector2(600,400),"b":Vector2(900,400),"n":Vector2.UP}]
	p.configure(blocks,faces)
	check(p.shoot(Vector2(150,300),Vector2(150,400),0),"Adjacent 50px faces merge into valid 100px portal surface")
	check(p.shoot(Vector2(750,300),Vector2(750,400),1),"Second continuous surface accepts portal")
	var player = load("res://actors/player.gd").new()
	root.add_child(player)
	player.set_physics_process(false)
	player.position = Vector2(150,399)
	player.velocity = Vector2(17,1)
	check(p.transport(player,Vector2(150,401)) == false,"Moving outwards cannot enter portal")
	player.position = Vector2(150,401)
	player.velocity = Vector2(17,1)
	check(p.transport(player,Vector2(150,399)),"Low normal speed permits traversal")
	check(absf(player.velocity.length()-Vector2(17,1).length()) < 0.01,"Low speed traversal preserves total speed")
	var spot: Vector2 = player.position
	check(not p.transport(player,spot),"Stationary overlap cannot repeatedly trigger")
	player.position = Vector2(750,401)
	player.velocity = Vector2(0,500)
	check(p.transport(player,Vector2(750,380)),"Reverse blue-to-red entry works after full exit separation")
	p.clear()
	player.position = Vector2(150,401)
	player.velocity = Vector2(0,500)
	check(not p.transport(player,Vector2(150,380)),"No portals means no traversal")
	# Whole aperture clearance, not only center clearance.
	blocks.append(Rect2(166,365,12,20))
	p.configure(blocks,faces)
	check(not p.shoot(Vector2(150,300),Vector2(150,400),0),"Obstructed aperture edge rejects placement")
	p.queue_free()
	player.queue_free()
	await process_frame
	# Swept movement must stop even at a very thin wall.
	var wall := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(2,540)
	shape.shape = box
	wall.position = Vector2(400,270)
	wall.add_child(shape)
	root.add_child(wall)
	var fast = load("res://actors/player.gd").new()
	fast.position = Vector2(100,200)
	fast.velocity = Vector2(30000,0)
	root.add_child(fast)
	for i in 4: await physics_frame
	check(fast.position.x <= 388.1,"30000px/s movement cannot tunnel through 2px solid wall")
	wall.queue_free()
	fast.queue_free()
	await process_frame
	print("EDGE_CASE_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
