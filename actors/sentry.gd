extends Node2D
var alive := true
var direction := 1.0
var low := 440.0
var high := 580.0

func _ready() -> void:
	position = Vector2(510,413)
func _physics_process(delta: float) -> void:
	if not alive: return
	position.x += direction * 70 * delta
	if position.x >= high:
		position.x = high
		direction = -1
	if position.x <= low:
		position.x = low
		direction = 1
	queue_redraw()
func reset() -> void:
	alive = true
	position = Vector2(510,413)
	direction = 1
	show()
func hit(player: CharacterBody2D, before: Vector2, incoming: Vector2) -> String:
	if not alive: return ""
	var bounds := Rect2(position - Vector2(31,32),Vector2(62,64))
	var intersects := bounds.has_point(player.position) or bounds.has_point(before)
	var corners := [bounds.position, Vector2(bounds.end.x,bounds.position.y), bounds.end, Vector2(bounds.position.x,bounds.end.y)]
	for i in 4:
		if Geometry2D.segment_intersects_segment(before,player.position,corners[i],corners[(i+1)%4]) != null:
			intersects = true
	if not intersects:
		return ""
	if incoming.y > 30 and before.y + 15 <= position.y - 17 + 3:
		alive = false
		hide()
		player.position.y = position.y - 34
		player.velocity.y = -300
		player.stomp_feedback()
		return "stomp"
	player.die()
	return "death"
func _draw() -> void:
	draw_rect(Rect2(-20,-17,40,34), Color("d77470"))
	draw_rect(Rect2(-15,-10,30,10),Color("131b2b"))
	draw_line(Vector2(-10,-5),Vector2(-3,-5),Color("ff526b"),3)
	draw_line(Vector2(3,-5),Vector2(10,-5),Color("ff526b"),3)
	for x in [-12,12]:
		draw_line(Vector2(x,17),Vector2(x + direction * 4,22),Color("c6d9e5"),4)

