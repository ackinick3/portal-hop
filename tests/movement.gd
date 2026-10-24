extends SceneTree

var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
	else:
		print("PASS: ", message)

func _initialize() -> void:
	call_deferred("run")

func frames(count: int) -> void:
	for i in count:
		await physics_frame

func run() -> void:
	var source = load("res://actors/player.gd")
	if source == null:
		check(false, "Player script must exist")
		quit(1)
		return
	var room := Node2D.new()
	root.add_child(room)
	var floor_body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(960, 40)
	shape.shape = rectangle
	floor_body.add_child(shape)
	floor_body.position = Vector2(480, 400)
	room.add_child(floor_body)
	var wall := StaticBody2D.new()
	var wall_shape := CollisionShape2D.new()
	var wall_rect := RectangleShape2D.new()
	wall_rect.size = Vector2(20, 400)
	wall_shape.shape = wall_rect
	wall.add_child(wall_shape)
	wall.position = Vector2(500, 200)
	room.add_child(wall)
	var player = source.new()
	player.position = Vector2(120, 200)
	player.spawn = Vector2(120, 200)
	room.add_child(player)
	await frames(120)
	check(abs(player.position.y - 365) < 1, "Gravity lands player on solid floor")
	Input.action_press("move_right")
	await frames(45)
	check(player.position.x > 150, "Right input moves player")
	Input.action_release("move_right")
	await frames(30)
	var ground_y: float = player.position.y
	Input.action_press("jump")
	await frames(8)
	check(player.position.y < ground_y - 10, "Jump rises above floor")
	Input.action_release("jump")
	await frames(100)
	check(player.is_on_floor(), "Jump returns to floor")
	Input.action_press("move_right")
	await frames(240)
	check(player.position.x <= 479.1, "Player cannot cross solid wall")
	Input.action_release("move_right")
	player.position = Vector2(100, 180)
	player.velocity = Vector2(800, 0)
	await frames(1)
	check(player.velocity.x > 700, "Air control preserves launch speed above run cap")
	player.die()
	await frames(50)
	check(player.position.distance_to(player.spawn) < 100, "Death restores spawn")
	print("MOVEMENT_TEST_FAILURES=", failures)
	quit(0 if failures == 0 else 1)
