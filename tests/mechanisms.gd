extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await physics_frame
func run() -> void:
	check(ResourceLoader.exists("res://world/mechanisms.gd"),"Scene mechanisms exist to receive real portal beams")
	if not ResourceLoader.exists("res://world/mechanisms.gd"):
		quit(1)
		return
	var portal = load("res://portals/system.gd").new()
	root.add_child(portal)
	var blocks: Array[Rect2] = [Rect2(300,100,20,250),Rect2(500,100,20,250),Rect2(0,450,960,90)]
	var faces: Array[Dictionary] = [{"a":Vector2(300,100),"b":Vector2(300,350),"n":Vector2.LEFT},{"a":Vector2(520,100),"b":Vector2(520,350),"n":Vector2.RIGHT}]
	portal.configure(blocks,faces)
	var stage = load("res://world/mechanisms.gd").new()
	root.add_child(stage)
	stage.configure({"emitters":[{"p":Vector2(100,200),"d":Vector2.RIGHT}],"receivers":[{"p":Vector2(800,200),"id":"power"}],"gates":[{"rect":Rect2(700,300,20,150),"requires":["power"]}],"movers":[]},portal)
	await frames(3)
	check(not stage.receivers[0].active,"Opaque wall blocks initial beam and leaves receiver off")
	check(not stage.gates[0].open,"Unpowered gate has real collision")
	check(portal.shoot(Vector2(100,200),Vector2(300,200),0),"Laser entry portal placed from real visible side")
	check(portal.shoot(Vector2(800,200),Vector2(520,200),1),"Laser exit portal placed from real visible side")
	await frames(4)
	check(stage.receivers[0].active,"Beam traverses active pair and lights receiver")
	check(stage.gates[0].open,"Real receiver opens linked gate")
	check(portal.ray_hit(Vector2(750,380),Vector2(650,380)).is_empty(),"Opened gate is removed from gun occlusion")
	portal.clear()
	await frames(3)
	check(stage.receivers[0].active and stage.gates[0].open,"Receiver latches without holding player in a timing trap")
	stage.reset()
	await frames(2)
	check(not stage.receivers[0].active and not stage.gates[0].open,"Retry resets power and real gate collision")
	check(absf(portal.ray_hit(Vector2(750,380),Vector2(650,380)).p.x - 720) < 1,"Reset gate blocks shots again")
	stage.queue_free()
	await process_frame
	portal.clear()
	var thin_wall: Array[Rect2] = [Rect2(300,100,5,250)]
	var no_faces: Array[Dictionary] = []
	portal.configure(thin_wall,no_faces)
	stage = load("res://world/mechanisms.gd").new()
	root.add_child(stage)
	stage.configure({"emitters":[{"p":Vector2(100,200),"d":Vector2.RIGHT}],"receivers":[{"p":Vector2(310,200),"id":"hidden"}],"gates":[{"rect":Rect2(700,300,20,150),"requires":["hidden"]}]},portal)
	await frames(3)
	check(not stage.receivers[0].active and not stage.gates[0].open,"A receiver close behind a thin wall cannot be stimulated through the wall")
	stage.queue_free()
	portal.queue_free()
	await process_frame
	print("MECHANISMS_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
