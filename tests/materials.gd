extends SceneTree

var failures := 0
var source = load("res://actors/player.gd")
var room: Node2D
var player

func check(ok: bool, message: String) -> void:
	if ok:
		print("PASS: ", message)
	else:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func fixture(rect: Rect2, start: Vector2) -> void:
	for action in ["move_right", "move_left", "jump"]:
		if InputMap.has_action(action):
			Input.action_release(action)
	if room != null:
		room.queue_free()
		await frames(2)
	room = Node2D.new()
	root.add_child(room)
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.add_child(shape)
	body.position = rect.get_center()
	room.add_child(body)
	player = source.new()
	player.position = start
	player.spawn = start
	room.add_child(player)
	await frames(2)

func patch(a: Vector2, b: Vector2, n: Vector2, kind: String) -> Dictionary:
	return {"a": a, "b": b, "n": n, "kind": kind}

func run() -> void:
	var probe = source.new()
	var supported := false
	for property in probe.get_property_list():
		if property.name == "materials":
			supported = true
	probe.free()
	check(supported, "Player supports optional material patches")
	if not supported:
		print("MATERIAL_TEST_FAILURES=", failures)
		quit(1)
		return
	await fixture(Rect2(0, 380, 2000, 40), Vector2(100, 280))
	player.materials.append(patch(Vector2(0, 380), Vector2(2000, 380), Vector2.UP, "bounce"))
	player.velocity = Vector2(140, 400)
	player.cut_jump = true
	Input.action_press("jump")
	for i in 100:
		await frames(1)
		if player.bounces > 0:
			break
	print("FLOOR_REBOUND=", player.velocity, " INCOMING=", player.previous_velocity)
	check(player.bounces == 1 and player.velocity.y < -570, "Blue floor automatically rebounds from a real landing")
	check(absf(player.velocity.x - player.previous_velocity.x) < 1, "Blue floor preserves incoming horizontal velocity")
	check(not player.cut_jump, "Automatic bounce cannot be shortened by jump release")
	Input.action_release("jump")
	await frames(12)
	check(player.bounces == 1 and player.velocity.y < -470, "Separating floor contact and released jump do not alter automatic rebound")
	player.die()
	check(player.bounces == 0 and player.boost_distance == 0, "Death immediately resets material route evidence")
	await fixture(Rect2(500, 0, 40, 540), Vector2(400, 200))
	player.materials.append(patch(Vector2(500, 0), Vector2(500, 540), Vector2.LEFT, "bounce"))
	player.velocity = Vector2(800, 0)
	Input.action_press("move_right")
	for i in 50:
		await frames(1)
		if player.bounces > 0:
			break
	print("WALL_REBOUND=", player.velocity, " INCOMING=", player.previous_velocity)
	check(player.bounces == 1 and player.velocity.x < -790, "Blue wall reflects pre-slide normal speed rather than zeroed slide velocity")
	check(absf(player.velocity.y - player.previous_velocity.y) < 1, "Blue wall preserves vertical velocity")
	await frames(12)
	check(player.bounces == 1 and player.velocity.x < 0, "Separating wall contact does not rebound twice")
	await fixture(Rect2(0, 380, 2000, 40), Vector2(100, 350))
	player.materials.append(patch(Vector2(0, 380), Vector2(2000, 380), Vector2.UP, "bounce"))
	player.velocity = Vector2(0, 1400)
	for i in 20:
		await frames(1)
		if player.bounces > 0:
			break
	check(player.velocity.y < -800 and player.velocity.y >= -900, "Blue rebound caps excessive incoming normal speed")
	await fixture(Rect2(500, 0, 40, 540), Vector2(475, 200))
	player.materials.append(patch(Vector2(500, 0), Vector2(500, 540), Vector2.LEFT, "bounce"))
	player.velocity = Vector2(100, 0)
	Input.action_press("move_right")
	for i in 50:
		await frames(1)
		if player.bounces > 0:
			break
	check(player.bounces == 1 and player.velocity.x <= -420, "Slow wall impact receives a useful automatic rebound")
	await fixture(Rect2(500, 0, 40, 540), Vector2(400, 200))
	player.materials.append(patch(Vector2(500, 300), Vector2(500, 500), Vector2.LEFT, "bounce"))
	player.velocity = Vector2(800, 0)
	Input.action_press("move_right")
	await frames(20)
	check(player.bounces == 0 and player.position.x < 490, "A remote blue patch does not coat the rest of a wall")
	await fixture(Rect2(0, 380, 650, 40), Vector2(100, 365))
	player.materials.append(patch(Vector2(0, 380), Vector2(650, 380), Vector2.UP, "boost"))
	Input.action_press("move_right")
	await frames(65)
	print("RED_SPEED=", player.velocity.x, " RED_DISTANCE=", player.boost_distance)
	check(player.velocity.x > 600 and player.velocity.x <= 650.01, "Held red runway accelerates beyond ordinary running with a bounded speed")
	check(player.boost_distance > 100, "Red runway records actual traveled distance")
	Input.action_release("move_right")
	var red_speed: float = player.velocity.x
	await frames(10)
	check(player.velocity.x < red_speed - 100, "Released red runway movement deliberately brakes")
	Input.action_press("move_right")
	for i in 150:
		await frames(1)
		if player.position.x > 670 and not player.is_on_floor():
			break
	var air_speed: float = player.velocity.x
	await frames(24)
	print("RED_AIR_SPEED=", player.velocity.x)
	check(air_speed > 600 and absf(player.velocity.x - air_speed) < 1, "Leaving red runway retains high speed under existing held air control")
	await fixture(Rect2(0, 380, 2000, 40), Vector2(100, 365))
	await frames(10)
	Input.action_press("move_right")
	await frames(60)
	check(absf(player.velocity.x - 210) < 0.01, "Empty material list preserves ordinary ground speed")
	Input.action_release("move_right")
	var brake_start: float = player.position.x
	await frames(30)
	var slide: float = player.position.x - brake_start
	print("ORDINARY_SLIDE=", slide)
	check(player.velocity.x == 0 and slide > 7 and slide < 10, "Empty material list preserves ordinary release braking distance")
	player.materials.append(patch(Vector2(700, 380), Vector2(900, 380), Vector2.UP, "boost"))
	Input.action_press("move_right")
	await frames(60)
	check(absf(player.velocity.x - 210) < 0.01 and player.boost_distance == 0, "A remote red patch cannot leak acceleration onto normal floor")
	await fixture(Rect2(0, 380, 2000, 40), Vector2(100, 365))
	player.materials.append(patch(Vector2(0, 380), Vector2(300, 380), Vector2.UP, "boost"))
	Input.action_press("move_right")
	for i in 160:
		await frames(1)
		if player.position.x > 320:
			break
	await frames(50)
	check(absf(player.velocity.x - 210) < 0.01 and player.boost_distance > 100, "Leaving red coating onto ordinary floor restores ordinary ground running")
	Input.action_release("move_right")
	room.queue_free()
	await frames(2)
	print("MATERIAL_TEST_FAILURES=", failures)
	quit(0 if failures == 0 else 1)
