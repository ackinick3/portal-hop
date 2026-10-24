extends SceneTree

var failures := 0
var mover_source: Script
var player_source := preload("res://actors/player.gd")

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	if ok:
		print("PASS: ", message)
	else:
		failures += 1
		push_error(message)

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func fixture(start: Vector2, finish: Vector2, speed: float) -> Array:
	var room := Node2D.new()
	root.add_child(room)
	var mover = mover_source.new()
	mover.configure(Rect2(start, Vector2(110, 20)), finish, speed)
	mover.enabled = false
	room.add_child(mover)
	var player = player_source.new()
	player.position = start + Vector2(55, -15)
	player.spawn = player.position
	room.add_child(player)
	await frames(8)
	return [room, mover, player]

func solid(room: Node2D, rect: Rect2) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	body.position = rect.get_center()
	body.add_child(shape)
	room.add_child(body)

func run() -> void:
	if not ResourceLoader.exists("res://world/moving_platform.gd"):
		check(false, "Moving platform implementation must exist")
		quit(1)
		return
	mover_source = load("res://world/moving_platform.gd")
	var setup := await fixture(Vector2(100, 300), Vector2(400, 300), 120)
	var room = setup[0]
	var mover = setup[1]
	var rider = setup[2]
	check(rider.is_on_floor(), "Ordinary player settles on parked platform")
	await frames(30)
	check(mover.bounds().position.is_equal_approx(Vector2(100, 300)), "Disabled platform stays at origin")
	mover.enabled = true
	await frames(180)
	check(mover.bounds().position.x > 270, "Horizontal mover crosses the unsupported gap at configured speed")
	check(absf(rider.position.x - mover.bounds().get_center().x) < 2 and rider.is_on_floor(), "Grounded ordinary player rides horizontally without input")
	var frozen: Rect2 = mover.bounds()
	var frozen_rider: Vector2 = rider.position
	var frozen_gear: float = mover.gear_angle
	paused = true
	await frames(20)
	check(mover.bounds().is_equal_approx(frozen) and rider.position.is_equal_approx(frozen_rider) and mover.gear_angle == frozen_gear, "Pause freezes platform rider and rotating gears")
	paused = false
	await frames(200)
	check(mover.bounds().position.x < 335 and rider.is_on_floor(), "Platform reverses at endpoint and carries rider back")
	mover.reset()
	check(mover.bounds().position.is_equal_approx(Vector2(100, 300)) and is_zero_approx(mover.gear_angle), "Reset restores phase origin and finite zero gear angle")
	mover.enabled = false
	await frames(30)
	check(mover.bounds().position.is_equal_approx(Vector2(100, 300)), "Disabled mover returns to and remains at origin")
	room.queue_free()
	await frames(2)
	setup = await fixture(Vector2(200, 420), Vector2(200, 160), 100)
	room = setup[0]
	mover = setup[1]
	rider = setup[2]
	mover.enabled = true
	await frames(180)
	check(mover.bounds().position.y < 275 and absf(rider.position.y + 15 - mover.bounds().position.y) < 2 and rider.is_on_floor(), "Elevator carries an ordinary player upward")
	await frames(240)
	check(mover.bounds().position.y > 240 and absf(rider.position.y + 15 - mover.bounds().position.y) < 2 and rider.is_on_floor(), "Elevator carries an ordinary player downward after reversal")
	check(is_finite(mover.gear_angle) and absf(mover.gear_angle) > 0.1, "Actual motion rotates finite undercarriage gears")
	room.queue_free()
	await frames(2)
	setup = await fixture(Vector2(200, 300), Vector2(200, 100), 120)
	room = setup[0]
	mover = setup[1]
	rider = setup[2]
	solid(room, Rect2(180, 200, 150, 20))
	mover.enabled = true
	await frames(180)
	check(mover.bounds().position.y >= 249 and rider.position.y >= 234, "Elevator stops before squeezing a rider through the ceiling")
	check(rider.is_on_floor() and rider.dead_time <= 0, "Blocked elevator leaves its rider alive and supported")
	room.queue_free()
	await frames(3)
	room = Node2D.new()
	root.add_child(room)
	mover = mover_source.new()
	mover.configure(Rect2(100, 300, 100, 20), Vector2(103.5, 300), 120)
	room.add_child(mover)
	await frames(3)
	mover.reset()
	await frames(8)
	var replay: Rect2 = mover.bounds()
	var replay_angle: float = mover.gear_angle
	check(absf(replay.position.x - 101.0) < 0.01, "Ping-pong preserves travel distance when a tick crosses the endpoint")
	mover.reset()
	await frames(8)
	check(mover.bounds().is_equal_approx(replay) and is_equal_approx(mover.gear_angle, replay_angle), "Reset produces the same motion and gear phase for the same elapsed ticks")
	room.queue_free()
	await frames(2)
	room = Node2D.new()
	root.add_child(room)
	mover = mover_source.new()
	mover.configure(Rect2(100, 300, 100, 20), Vector2(700, 300), 24000)
	room.add_child(mover)
	solid(room, Rect2(300, 200, 5, 200))
	await frames(5)
	check(mover.bounds().end.x <= 300.1, "Platform sweep cannot tunnel through a thin solid at extreme speed")
	room.queue_free()
	await frames(3)
	print("MOVING_PLATFORM_TEST_FAILURES=", failures)
	quit(0 if failures == 0 else 1)
