extends SceneTree
var failed := 0
func check(ok: bool, text: String) -> void:
	print("PASS: " if ok else "FAIL: ", text)
	if not ok: failed += 1
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var portals = load("res://portals/system.gd").new()
	root.add_child(portals)
	var blocks: Array[Rect2] = [Rect2(0, 400, 400, 140), Rect2(600, 400, 360, 140), Rect2(450, 100, 20, 200)]
	var faces: Array[Dictionary] = [{"a":Vector2(100,400),"b":Vector2(300,400),"n":Vector2.UP},{"a":Vector2(650,400),"b":Vector2(850,400),"n":Vector2.UP}]
	portals.configure(blocks, faces)
	check(not portals.shoot(Vector2(100,300), Vector2(20,400), 0), "Invalid material rejected")
	check(portals.shoot(Vector2(100,300), Vector2(110,400), 0) and portals.doors[0].p.is_equal_approx(Vector2(136,400)), "Pale edge hit shifts whole portal inward")
	check(not portals.shoot(Vector2(100,100), Vector2(750,400), 1), "Wall occludes target")
	check(portals.shoot(Vector2(200,300), Vector2(200,400), 0), "Valid red floor placement")
	check(not portals.active(), "Single door stays inactive")
	check(portals.shoot(Vector2(750,300), Vector2(750,400), 1), "Valid blue floor placement")
	check(portals.active(), "Pair activates")
	var player = load("res://actors/player.gd").new()
	player.position = Vector2(200,250)
	player.spawn = player.position
	player.portal_system = portals
	root.add_child(player)
	var crossed := false
	for i in 120:
		await physics_frame
		if player.position.x > 600:
			crossed = true
			check(player.velocity.y < 0, "Floor exit reverses fall upwards")
			break
	check(crossed, "Real floor opening permits physical traversal")
	check(portals.shoot(Vector2(250,300), Vector2(250,400), 0), "Same color replaces existing door")
	check(portals.doors[0].p.x == 250, "Old same color door removed")
	check(not portals.shoot(Vector2(750,300), Vector2(750,400), 0), "Overlapping doors rejected")
	check(portals.doors[0].p.x == 250, "Failed placement retains previous door")
	portals.clear()
	check(not portals.active() and portals.doors[0].is_empty(), "Reset removes both doors")
	print("PORTAL_INTEGRATION_FAILURES=", failed)
	quit(0 if failed == 0 else 1)

