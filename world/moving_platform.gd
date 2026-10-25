extends Node2D

var enabled := true
var gear_angle := 0.0
var path_points := PackedVector2Array()
var _distances := PackedFloat64Array()
var _path_length := 0.0
var _start := Vector2.ZERO
var _end := Vector2.ZERO
var _size := Vector2(110, 20)
var _speed := 100.0
var _travel := 0.0
var _forward := true
var _body: AnimatableBody2D

func configure(rect: Rect2, to: Vector2, speed: float, path: PackedVector2Array = PackedVector2Array()) -> void:
	_start = rect.position
	_end = to
	_size = rect.size
	_speed = maxf(0.0, speed)
	# Runtime track points are platform top-left positions, including the origin.
	path_points = path.duplicate() if not path.is_empty() else PackedVector2Array([_start,_end])
	_distances = PackedFloat64Array([0.0])
	_path_length = 0.0
	for i in range(1,path_points.size()):
		_path_length += path_points[i-1].distance_to(path_points[i])
		_distances.append(_path_length)
	if is_inside_tree():
		_body.get_child(0).shape.size = _size
		_body.get_child(0).position = _size * 0.5
		reset()

func _ready() -> void:
	process_physics_priority = -10
	_body = AnimatableBody2D.new()
	_body.name = "PlatformBody"
	_body.sync_to_physics = false
	_body.position = _start
	var collider := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = _size
	collider.shape = box
	collider.position = _size * 0.5
	_body.add_child(collider)
	add_child(_body)
	queue_redraw()

func bounds() -> Rect2:
	return Rect2(to_global(_body.position if _body != null else _start), _size)

func reset() -> void:
	_travel = 0.0
	_forward = true
	gear_angle = 0.0
	if _body != null:
		_body.position = _start
		_body.force_update_transform()
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not enabled:
		if _travel != 0:
			reset()
		return
	if _path_length < 0.001 or _speed <= 0:
		return
	var remaining := _speed*delta
	while remaining>0.000001:
		var corner := _path_length if _forward else 0.0
		if _forward:
			for mark in _distances:
				if mark>_travel+0.000001:
					corner = mark
					break
		else:
			for i in range(_distances.size()-1,-1,-1):
				if _distances[i]<_travel-0.000001:
					corner = _distances[i]
					break
		var advance := minf(remaining,absf(corner-_travel))
		if advance<0.000001:
			_forward = not _forward
			continue
		var next := _travel+advance*(1 if _forward else -1)
		var movement := _point_at(next)-_body.position
		var fraction := _safe_fraction(movement)
		_travel = lerpf(_travel,next,fraction)
		_body.position = _point_at(_travel)
		gear_angle = fposmod(gear_angle+movement.length()*fraction/9.0,TAU)
		remaining -= advance
		if fraction<1: break
		if _travel>=_path_length-0.000001: _forward = false
		elif _travel<=0.000001: _forward = true
	queue_redraw()

func _point_at(distance: float) -> Vector2:
	for i in range(1,path_points.size()):
		var length := _distances[i]-_distances[i-1]
		if length>0 and distance<=_distances[i]: return path_points[i-1].lerp(path_points[i],clampf((distance-_distances[i-1])/length,0,1))
	return path_points[-1]

func _safe_fraction(movement: Vector2) -> float:
	if movement.length_squared() < 0.000001:
		return 1.0
	# Sweep the platform and supported characters together. A blocked rider stops
	# the platform rather than being pushed into a ceiling or side wall.
	var query := PhysicsShapeQueryParameters2D.new()
	var strip := RectangleShape2D.new()
	strip.size = Vector2(_size.x - 0.2, 6)
	query.shape = strip
	query.transform = Transform2D(0.0, bounds().position + Vector2(_size.x * 0.5, -1))
	query.exclude = [_body.get_rid()]
	var riders: Array[CharacterBody2D] = []
	for result in get_world_2d().direct_space_state.intersect_shape(query):
		var character = result.collider
		if character is CharacterBody2D:
			riders.append(character)
			_body.add_collision_exception_with(character)
			character.add_collision_exception_with(_body)
	var fraction := 1.0
	var collision := KinematicCollision2D.new()
	if _body.test_move(_body.global_transform, movement, collision):
		# Recovery may include sideways travel; only the opposing normal limits
		# progress along this track, otherwise a diagonal mover creeps into a floor.
		var into := movement.dot(collision.get_normal())
		fraction = minf(fraction,collision.get_travel().dot(collision.get_normal())/into if into < -0.000001 else 0.0)
	for rider in riders:
		# CharacterBody applies the platform's velocity on its following tick.
		# Leave one tick of clearance so its pending carry cannot squeeze it.
		if rider.test_move(rider.global_transform, movement * 2.0, collision):
			var available := collision.get_travel().dot(movement.normalized()) - movement.length() - 0.1
			fraction = minf(fraction, available / movement.length())
	for rider in riders:
		_body.remove_collision_exception_with(rider)
		rider.remove_collision_exception_with(_body)
	return clampf(fraction, 0.0, 1.0)

func _draw() -> void:
	for wheel in [19.0, _size.x - 19.0]:
		var under := Vector2(wheel, _size.y + 5)
		var rail := PackedVector2Array()
		for p in path_points if not path_points.is_empty() else PackedVector2Array([_start,_end]): rail.append(p+under)
		if rail.size()>1:
			draw_polyline(rail,Color("070f1b"),21,true)
			draw_polyline(rail,Color("273b50"),13,true)
			draw_polyline(rail,Color("111f30"),5,true)
		for endpoint in [rail[0],rail[-1]]:
			draw_circle(endpoint, 11, Color("070f1b"))
			draw_circle(endpoint, 6, Color("526779"))
			draw_circle(endpoint, 2, Color("111f30"))
	var point := _body.position if _body != null else _start
	for x in [19.0, _size.x - 19.0]:
		var center := point + Vector2(x, _size.y + 5)
		var teeth := PackedVector2Array()
		for i in 32:
			var angle := gear_angle + TAU * i / 32.0
			var radius := 10.0 if i % 4 in [1, 2] else 7.5
			teeth.append(center + Vector2.from_angle(angle) * radius)
		draw_colored_polygon(teeth, Color("90a6b4"))
		draw_circle(center, 5.0, Color("24364a"))
		draw_line(center, center + Vector2.from_angle(gear_angle) * 6, Color("d4e6ec"), 2, true)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("344b61")
	style.border_color = Color("afc7d3")
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	draw_style_box(style, Rect2(point, _size))
	draw_line(point + Vector2(7, 4), point + Vector2(_size.x - 7, 4), Color("65e6c4") if enabled else Color("7896a0"), 3, true)
	for x in [9.0, _size.x - 9.0]:
		draw_circle(point + Vector2(x, _size.y - 6), 2, Color("122234"))
