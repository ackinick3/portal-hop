extends CharacterBody2D

signal died
signal jumped
signal landed
const Materials = preload("res://world/materials.gd")
var portal_system: Node2D
var materials: Array[Dictionary] = []
var bounces := 0
var boost_distance := 0.0
var material_airborne := false
var previous_position := Vector2.ZERO
var previous_velocity := Vector2.ZERO
var spawn := Vector2.ZERO
var coyote := 0.0
var buffer := 0.0
var dead_time := 0.0
var facing := 1.0
var cut_jump := false
var aim_direction := Vector2.RIGHT
var landing_squash := 0.0
var stomp_stretch := 0.0
var portal_flash := 0.0

func _ready() -> void:
	for pair in [["move_left", KEY_A], ["move_right", KEY_D], ["jump", KEY_SPACE]]:
		if not InputMap.has_action(pair[0]):
			InputMap.add_action(pair[0])
			var key := InputEventKey.new()
			key.physical_keycode = pair[1]
			InputMap.action_add_event(pair[0], key)
	var collider := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(22, 30)
	collider.shape = box
	add_child(collider)

func _physics_process(delta: float) -> void:
	if dead_time > 0:
		dead_time -= delta
		if dead_time <= 0:
			position = spawn
			velocity = Vector2.ZERO
			previous_position = position
			previous_velocity = Vector2.ZERO
		queue_redraw()
		return
	var grounded := is_on_floor() and not material_airborne
	material_airborne = false
	var boosting := grounded and Materials.has_patch(materials, position + Vector2(0, 15), Vector2.UP, "boost")
	coyote = 0.1 if grounded else maxf(0.0, coyote - delta)
	buffer = 0.1 if Input.is_action_just_pressed("jump") else maxf(0.0, buffer - delta)
	var axis := Input.get_axis("move_left", "move_right")
	if axis != 0:
		facing = axis
	if grounded:
		var acceleration := 2300.0 if axis == 0 else 1400.0
		var speed := 210.0
		if boosting:
			speed = 650.0
			if axis != 0:
				acceleration = 1800.0
		velocity.x = move_toward(velocity.x, axis * speed, acceleration * delta)
	else:
		# Gently settle released horizontal drift without clamping a fast launch.
		if axis == 0:
			velocity.x = move_toward(velocity.x, 0, 90 * delta)
		elif absf(velocity.x) < 210 or signf(velocity.x) != axis:
			velocity.x += axis * 380 * delta
	velocity.y += 900 * delta
	if buffer > 0 and coyote > 0:
		velocity.y = -330
		buffer = 0
		coyote = 0
		cut_jump = true
		jumped.emit()
	if cut_jump and Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5
		cut_jump = false
	previous_position = position
	previous_velocity = velocity
	move_and_slide()
	if boosting:
		boost_distance += absf(position.x - previous_position.x)
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var normal := collision.get_normal()
		var incoming := previous_velocity.dot(normal)
		if incoming < -0.01 and Materials.has_patch(materials, collision.get_position(), normal, "bounce"):
			var minimum := 580.0 if normal.y < -0.5 else 420.0
			velocity = previous_velocity - normal * incoming + normal * clampf(-incoming, minimum, 900.0)
			cut_jump = false
			coyote = 0
			buffer = 0
			material_airborne = true
			bounces += 1
			break
	if portal_system != null:
		if portal_system.transport(self, previous_position):
			portal_flash = 0.18
			previous_position = position
			previous_velocity = velocity
	if not grounded and is_on_floor():
		landing_squash = 0.12
		landed.emit()
	if position.y > 600:
		die()
	queue_redraw()

func gun_origin() -> Vector2:
	# Aim from the hand inside the collider so an extended barrel cannot shoot through walls.
	return global_position + Vector2(0, 4)

func aim_at(target: Vector2) -> void:
	var direction := target - gun_origin()
	if direction.length_squared() > 0.001:
		aim_direction = direction.normalized()
	queue_redraw()

func _process(delta: float) -> void:
	landing_squash = maxf(0, landing_squash - delta)
	stomp_stretch = maxf(0, stomp_stretch - delta)
	portal_flash = maxf(0, portal_flash - delta)
	aim_at(get_global_mouse_position())

func stomp_feedback() -> void:
	landing_squash = 0
	stomp_stretch = 0.16
	queue_redraw()

func feedback_scale() -> Vector2:
	if stomp_stretch > 0:
		return Vector2(1 - 0.14 * stomp_stretch / 0.16, 1 + 0.18 * stomp_stretch / 0.16)
	if landing_squash > 0:
		return Vector2(1 + 0.18 * landing_squash / 0.12, 1 - 0.16 * landing_squash / 0.12)
	return Vector2.ONE

func die() -> void:
	if dead_time > 0:
		return
	dead_time = 0.3
	velocity = Vector2.ZERO
	cut_jump = false
	buffer = 0
	coyote = 0
	landing_squash = 0
	stomp_stretch = 0
	portal_flash = 0
	bounces = 0
	boost_distance = 0
	material_airborne = false
	died.emit()

func _draw() -> void:
	if dead_time > 0:
		draw_circle(Vector2.ZERO, 30 * (1 - dead_time / 0.3), Color("ff526b"))
		return
	if velocity.length() > 450:
		draw_line(-velocity.normalized() * 16, -velocity.normalized() * 48, Color("4ba9ff"), 3)
	if portal_flash > 0:
		var glow := Color("c6d9e5")
		glow.a = portal_flash / 0.18
		draw_arc(Vector2.ZERO, 20 + 20 * (1 - glow.a), 0, TAU, 30, glow, 2)
	if stomp_stretch > 0:
		var ring := Color("55e0ae")
		ring.a = stomp_stretch / 0.16
		draw_arc(Vector2(0,15), 8 + 22 * (1 - ring.a), PI, TAU, 20, ring, 2)
	var body_scale := feedback_scale()
	draw_set_transform(Vector2(0,15 * (1 - body_scale.y)), 0, body_scale)
	draw_style_box(_body_style(), Rect2(-13, -17, 26, 34))
	draw_rect(Rect2(-10, -10, 20, 11), Color("131b2b"))
	draw_circle(Vector2(-4 + facing, -5), 2, Color("4ba9ff"))
	draw_circle(Vector2(4 + facing, -5), 2, Color("4ba9ff"))
	draw_set_transform(Vector2.ZERO)
	var hand := Vector2(0, 4)
	draw_line(hand + aim_direction * 8, hand + aim_direction * 24, Color("131b2b"), 8)
	draw_line(hand + aim_direction * 8, hand + aim_direction * 24, Color("c6d9e5"), 5)
	draw_circle(hand + aim_direction * 8, 3, Color("f8d66d"))

func _body_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("f8d66d").lerp(Color("edf3f8"), portal_flash / 0.18)
	style.set_corner_radius_all(5)
	return style
