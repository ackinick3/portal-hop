extends Node2D
const Materials = preload("res://world/materials.gd")

var portal_system: Node2D
var receivers: Array[Dictionary] = []
var gates: Array[Dictionary] = []
var movers: Array = []
var beams: Array[Dictionary] = []
var emitters: Array = []
var patches: Array = []
var time := 0.0

func configure(data: Dictionary, portals: Node2D) -> void:
	portal_system = portals
	process_physics_priority = -5
	patches = data.get("materials",[])
	emitters = data.get("emitters",[])
	portal_system.mirrors.assign(data.get("mirrors",[]))
	portal_system.gun_screens.assign(data.get("gun_screens",[]))
	for spec in data.get("receivers",[]):
		receivers.append({"p":spec.p,"id":spec.id,"active":false})
	for spec in data.get("gates",[]):
		var body := StaticBody2D.new()
		var shape := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = spec.rect.size
		shape.shape = box
		body.position = spec.rect.get_center()
		body.add_child(shape)
		add_child(body)
		gates.append({"rect":spec.rect,"requires":spec.get("requires",[]),"body":body,"open":false})
	for spec in data.get("movers",[]):
		var platform = load("res://world/moving_platform.gd").new()
		add_child(platform)
		platform.process_physics_priority = -10
		platform.configure(spec.rect,spec.to,spec.get("speed",85.0))
		platform.enabled = spec.get("requires",[]).is_empty()
		movers.append({"platform":platform,"requires":spec.get("requires",[])})
	publish_occluders()
	queue_redraw()

func powered(required: Array) -> bool:
	for id in required:
		var found := false
		for receiver in receivers:
			if receiver.id == id and receiver.active: found = true
		if not found: return false
	return true

func reset() -> void:
	time = 0
	beams.clear()
	for receiver in receivers: receiver.active = false
	for gate in gates:
		gate.open = false
		gate.body.collision_layer = 1
	for mover in movers:
		mover.platform.reset()
		mover.platform.enabled = mover.requires.is_empty()
	publish_occluders()
	queue_redraw()

func publish_occluders() -> void:
	var blockers: Array[Rect2] = []
	for gate in gates:
		if not gate.open: blockers.append(gate.rect)
	for mover in movers: blockers.append(mover.platform.bounds())
	portal_system.occluders = blockers

func _physics_process(delta: float) -> void:
	time += delta
	publish_occluders()
	beams.clear()
	for emitter in emitters:
		beams.append_array(portal_system.beam_path(emitter.p,emitter.d))
	for receiver in receivers:
		if receiver.active: continue
		for beam in beams:
			var contact := Geometry2D.get_closest_point_to_segment(receiver.p,beam.a,beam.b)
			if contact.distance_to(receiver.p) <= 14:
				var obstruction: Dictionary = portal_system.ray_hit(contact,receiver.p)
				if not obstruction.is_empty() and contact.distance_to(obstruction.p) < contact.distance_to(receiver.p)-0.1:
					continue
				receiver.active = true
				break
	for gate in gates:
		gate.open = powered(gate.requires)
		gate.body.collision_layer = 0 if gate.open else 1
	for mover in movers:
		mover.platform.enabled = powered(mover.requires)
	publish_occluders()
	queue_redraw()

func _draw() -> void:
	Materials.draw(self,patches,time)
	if portal_system != null:
		for screen in portal_system.gun_screens:
			var a: Vector2 = screen.a
			var b: Vector2 = screen.b
			var direction := (b-a).normalized()
			for distance in range(0,ceili(a.distance_to(b)),17):
				var end := minf(distance+10,a.distance_to(b))
				draw_line(a+direction*distance,a+direction*end,Color("63ed9e"),4,true)
	for receiver in receivers:
		var tint := Color("63edbd") if receiver.active else Color("8b6b42")
		for gate in gates:
			if receiver.id in gate.requires:
				var end: Vector2 = gate.rect.get_center()
				draw_polyline(PackedVector2Array([receiver.p,Vector2(end.x,receiver.p.y),end]),Color(tint,0.28),2)
		for mover in movers:
			if receiver.id in mover.requires:
				var end: Vector2 = mover.platform.bounds().get_center()
				draw_polyline(PackedVector2Array([receiver.p,Vector2(receiver.p.x,end.y),end]),Color(tint,0.28),2)
	for gate in gates:
		var r: Rect2 = gate.rect
		draw_rect(r.grow(3),Color("25374b"),false,3)
		if not gate.open:
			draw_rect(r,Color("325c67"))
			for y in range(int(r.position.y+8),int(r.end.y),16):
				draw_line(Vector2(r.position.x+3,y),Vector2(r.end.x-3,y),Color("ffb45e"),3)
		else:
			draw_rect(Rect2(r.position,Vector2(r.size.x,5)),Color("63edbd"))
			draw_rect(Rect2(Vector2(r.position.x,r.end.y-5),Vector2(r.size.x,5)),Color("63edbd"))
	for emitter in emitters:
		draw_style_box(device_style(),Rect2(emitter.p-Vector2(14,14),Vector2(28,28)))
		draw_circle(emitter.p,7,Color("ffce71"))
		draw_line(emitter.p,emitter.p+emitter.d*20,Color("fff0ae"),5)
	for beam in beams:
		draw_line(beam.a,beam.b,Color(1,0.7,0.2,0.15),9)
		draw_line(beam.a,beam.b,Color("ffd570"),3)
		draw_line(beam.a,beam.b,Color("fff3cb"),1)
	for receiver in receivers:
		draw_style_box(device_style(),Rect2(receiver.p-Vector2(17,17),Vector2(34,34)))
		var tint := Color("63edbd") if receiver.active else Color("9b7951")
		draw_arc(receiver.p,12,0,TAU,24,tint,3)
		draw_circle(receiver.p,6,tint)

func device_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("152435")
	style.border_color = Color("9fb6c8")
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	return style
