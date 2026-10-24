extends RefCounted

static func has_patch(patches: Array, point: Vector2, normal: Vector2, kind: String) -> bool:
	for patch in patches:
		if patch.kind != kind or patch.n.dot(normal) < 0.99:
			continue
		var segment: Vector2 = patch.b - patch.a
		var length := segment.length()
		if length < 0.01:
			continue
		var offset: Vector2 = point - patch.a
		var along := offset.dot(segment / length)
		if along >= -0.5 and along <= length + 0.5 and absf(offset.dot(patch.n)) <= 2:
			return true
	return false

static func draw(canvas: Node2D, patches: Array, time: float) -> void:
	for patch in patches:
		var normal: Vector2 = patch.n
		var a: Vector2 = patch.a + normal * 2
		var b: Vector2 = patch.b + normal * 2
		var blue: bool = patch.kind == "bounce"
		var color := Color("4ba9ff") if blue else Color("ff6377")
		canvas.draw_line(a - normal * 2, b - normal * 2, Color("131b2b"), 10)
		canvas.draw_line(a, b, color, 6)
		canvas.draw_line(a + normal * 2, b + normal * 2, color.lightened(0.45), 1)
		var tangent := (b - a).normalized()
		var length := a.distance_to(b)
		var offset := 12.0 + (sin(time * 3) * 2 if blue else fmod(time * 24, 24))
		while offset < length - 6:
			var center := a + tangent * offset
			if blue:
				canvas.draw_arc(center + normal * 1, 4, 0, TAU, 12, Color("d8efff"), 1.5)
			else:
				canvas.draw_polyline(PackedVector2Array([center - tangent * 4 - normal * 3, center + tangent * 1, center - tangent * 4 + normal * 3]), Color("ffe4cc"), 2)
			offset += 24
