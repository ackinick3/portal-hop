extends RefCounted

static func rounded_box(color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	return style

static func draw_flag(canvas: CanvasItem, foot: Vector2, time: float) -> void:
	var mint := Color("55e0ae")
	var white := Color("dfeaf1")
	var sway := sin(time * 3) * 1.4
	canvas.draw_style_box(rounded_box(Color("8da3b5"), 7), Rect2(foot + Vector2(-10,-8), Vector2(20,9)))
	canvas.draw_style_box(rounded_box(white, 7), Rect2(foot + Vector2(-10,-9), Vector2(20,7)))
	canvas.draw_line(foot + Vector2(0,-38), foot + Vector2(0,-7), Color("8da3b5"), 5)
	canvas.draw_line(foot + Vector2(-0.5,-38), foot + Vector2(-0.5,-7), white, 3)
	var flag := PackedVector2Array([foot+Vector2(2,-38),foot+Vector2(10,-37),foot+Vector2(23,-32+sway),foot+Vector2(14,-27+sway),foot+Vector2(2,-24)])
	canvas.draw_colored_polygon(flag, mint)
	canvas.draw_polyline(PackedVector2Array([foot+Vector2(3,-37),foot+Vector2(10,-35),foot+Vector2(20,-32+sway)]),Color("a8f8d8"),1)
	canvas.draw_colored_polygon(PackedVector2Array([foot+Vector2(2,-38),foot+Vector2(6,-36),foot+Vector2(6,-26),foot+Vector2(2,-24)]),Color("2da98b"))
	canvas.draw_circle(foot + Vector2(0,-41), 6, Color(0.33,0.88,0.68,0.13))
	canvas.draw_circle(foot + Vector2(0,-41), 3.5, mint)
	canvas.draw_circle(foot + Vector2(-0.5,-42), 1.5, Color("d7fff0"))
	canvas.draw_circle(foot + Vector2(0,-5), 2, mint)

static func draw_gate(canvas: CanvasItem, goal: Rect2, time: float) -> void:
	var frame := Rect2(goal.position - Vector2(0,6), goal.size + Vector2(0,6))
	var shell := rounded_box(Color("dfeaf1"), 17)
	shell.corner_radius_bottom_left = 1
	shell.corner_radius_bottom_right = 1
	shell.border_color = Color("a7bccb")
	shell.set_border_width_all(1)
	canvas.draw_style_box(shell, frame)
	var inset := rounded_box(Color("131b2b"), 11)
	inset.corner_radius_bottom_left = 0
	inset.corner_radius_bottom_right = 0
	canvas.draw_style_box(inset, Rect2(goal.position + Vector2(6,6), goal.size - Vector2(12,6)))
	var mint := Color("55e0ae")
	var light := mint.lerp(Color("a8f8d8"), 0.12 + 0.08 * sin(time * 2))
	canvas.draw_style_box(rounded_box(Color("2da98b"), 3), Rect2(Vector2(goal.get_center().x-8,goal.position.y-2),Vector2(16,6)))
	canvas.draw_style_box(rounded_box(light, 2), Rect2(Vector2(goal.get_center().x-6,goal.position.y-1),Vector2(12,3)))
	for x in [goal.position.x + 1.5, goal.end.x - 4.5]:
		canvas.draw_style_box(rounded_box(Color("2da98b"), 2), Rect2(Vector2(x,goal.position.y+18),Vector2(3,17)))
		canvas.draw_line(Vector2(x+1.5,goal.position.y+20),Vector2(x+1.5,goal.position.y+32),light,1.5)
	canvas.draw_line(Vector2(goal.position.x+7,goal.end.y-1),Vector2(goal.end.x-7,goal.end.y-1),Color(0.33,0.88,0.68,0.15),7)
	canvas.draw_style_box(rounded_box(light, 1),Rect2(Vector2(goal.position.x+7,goal.end.y-3),Vector2(goal.size.x-14,3)))
