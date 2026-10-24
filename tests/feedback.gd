extends SceneTree

var failures := 0

func check(ok: bool, description: String) -> void:
	print("PASS: " if ok else "FAIL: ", description)
	if not ok: failures += 1

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count: await physics_frame

func run() -> void:
	var room := Node2D.new()
	root.add_child(room)
	var floor_body := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(960, 40)
	collider.shape = rectangle
	floor_body.add_child(collider)
	floor_body.position = Vector2(480, 450)
	room.add_child(floor_body)
	var player = load("res://actors/player.gd").new()
	player.position = Vector2(120, 350)
	room.add_child(player)
	await frames(80)
	Input.action_press("move_right")
	await frames(40)
	Input.action_release("move_right")
	var stop_start: float = player.position.x
	await frames(20)
	check(player.position.x - stop_start < 11, "Ground release stops within 11px at full run speed")
	player.position = Vector2(200, 150)
	player.velocity = Vector2.ZERO
	await frames(2)
	player.velocity = Vector2(210, 0)
	await frames(20)
	check(absf(player.velocity.x - 210) < 0.01, "Ground braking adjustment leaves airborne drift unchanged")
	player.position = Vector2(200, 150)
	player.velocity = Vector2(210, 0)
	Input.action_press("move_left")
	await frames(15)
	Input.action_release("move_left")
	check(player.velocity.x > 155 and player.velocity.x < 175, "Ground braking adjustment leaves airborne reverse control unchanged")
	player.position = Vector2(200, 150)
	player.velocity = Vector2(800, 0)
	await frames(20)
	check(absf(player.velocity.x - 800) < 0.01, "No-input launch above run speed retains momentum")
	player.set_process(false)
	check(player.has_method("aim_at"), "Gun supports mouse-target aiming")
	if player.has_method("aim_at"):
		var pivot: Vector2 = player.gun_origin()
		for direction in [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2(1, -1).normalized()]:
			player.aim_at(pivot + direction * 100)
			check(player.aim_direction.is_equal_approx(direction), "Gun aims toward " + str(direction))
		player.aim_at(pivot)
		check(player.aim_direction.is_finite(), "Cursor on hand keeps a finite aim direction")
	room.queue_free()
	await process_frame
	var portals = load("res://portals/system.gd").new()
	root.add_child(portals)
	var blocks: Array[Rect2] = [Rect2(300, 100, 20, 300), Rect2(600, 100, 20, 300)]
	var faces: Array[Dictionary] = [{"a":Vector2(300, 100), "b":Vector2(300, 400), "n":Vector2.LEFT}]
	portals.configure(blocks, faces)
	check(portals.shoot(Vector2(100, 200), Vector2(700, 200), 0), "Shot opens portal on first valid wall")
	check(portals.get("shot_traces") != null, "Shot creates visible trajectory data")
	if portals.get("shot_traces") != null:
		check(portals.shot_traces.size() == 1, "One shot creates one trace")
		var trace: Dictionary = portals.shot_traces[0]
		check(trace.end.is_equal_approx(Vector2(300, 200)), "Trace stops at nearest wall, not a wall behind it")
		check(trace.start.is_equal_approx(Vector2(124, 200)), "Trace begins at visible muzzle")
		check(trace.color == 0 and trace.valid, "Successful red shot keeps its color and impact state")
		portals._process(0.2)
		check(portals.shot_traces.is_empty(), "Shot trace fades out after 0.18 seconds")
		faces.clear()
		portals.configure(blocks, faces)
		check(not portals.shoot(Vector2(100, 200), Vector2(700, 200), 1), "Invalid material rejects portal")
		check(portals.shot_traces[0].end.is_equal_approx(Vector2(300, 200)) and not portals.shot_traces[0].valid, "Invalid shot still stops at the obstruction")
		portals.clear()
		check(portals.shot_traces.is_empty(), "Death/reset clears shot feedback")
	portals.queue_free()
	await process_frame
	print("FEEDBACK_TEST_FAILURES=", failures)
	quit(0 if failures == 0 else 1)
