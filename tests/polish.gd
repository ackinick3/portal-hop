extends SceneTree

var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var room := Node2D.new()
	root.add_child(room)
	var floor_body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(960,40)
	shape.shape = box
	floor_body.position = Vector2(480,450)
	floor_body.add_child(shape)
	room.add_child(floor_body)
	var player = load("res://actors/player.gd").new()
	player.position = Vector2(100,300)
	room.add_child(player)
	var supports_feedback: bool = player.has_method("feedback_scale")
	check(supports_feedback,"Player has visual-only action feedback")
	var landing_seen := [false]
	player.landed.connect(func():
		if supports_feedback: landing_seen[0] = player.feedback_scale().y < 1
	)
	for i in 100: await physics_frame
	check(landing_seen[0],"Real landing triggers compression")
	if supports_feedback:
		check(player.feedback_scale().is_equal_approx(Vector2.ONE),"Landing compression settles back to normal")
		var collision_size: Vector2 = player.get_child(0).shape.size
		check(collision_size == Vector2(22,30),"Visual feedback leaves collision size unchanged")
		var guard = load("res://actors/sentry.gd").new()
		room.add_child(guard)
		guard.set_physics_process(false)
		player.position = guard.position - Vector2(0,31)
		var outcome: String = guard.hit(player,guard.position-Vector2(0,60),Vector2(0,200))
		check(outcome == "stomp" and player.velocity.y == -300,"Stomp retains original bounce velocity")
		check(player.feedback_scale().y > 1,"Stomp triggers upward stretch")
		player.portal_flash = 0.18
		player.die()
		check(player.portal_flash == 0 and player.feedback_scale().is_equal_approx(Vector2.ONE),"Death clears old action effects")
	room.queue_free()
	await process_frame
	# Test a real transfer, rather than setting the flash timer directly.
	var portals = load("res://portals/system.gd").new()
	root.add_child(portals)
	var blocks: Array[Rect2] = [Rect2(0,400,400,140),Rect2(600,400,360,140)]
	var faces: Array[Dictionary] = []
	portals.configure(blocks,faces)
	portals.doors[0] = {"p":Vector2(200,400),"n":Vector2.UP}
	portals.doors[1] = {"p":Vector2(750,400),"n":Vector2.UP}
	portals.rebuild()
	var pip = load("res://actors/player.gd").new()
	pip.position = Vector2(200,300)
	pip.portal_system = portals
	root.add_child(pip)
	var flashed := false
	for i in 100:
		await physics_frame
		if pip.position.x > 600:
			flashed = pip.get("portal_flash") != null and pip.get("portal_flash") > 0
			break
	check(flashed,"Real teleport triggers player flash")
	pip.queue_free()
	portals.queue_free()
	await process_frame
	print("POLISH_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
