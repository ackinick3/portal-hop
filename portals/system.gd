extends Node2D

signal feedback(kind: String)
var solids: Array[Rect2] = []
var polygons: Array[PackedVector2Array] = []
var polygon_pieces: Array[PackedVector2Array] = []
# Surface: endpoints a,b and outward normal n. Adjacent collinear faces merge.
var faces: Array[Dictionary] = []
# Green faces share real solid geometry; dynamic blockers never cut terrain.
var mirrors: Array[Dictionary] = []
var occluders: Array[Rect2] = []
var gun_screens: Array[Dictionary] = []
var doors: Array[Dictionary] = [{}, {}]
var collision_root: Node2D
var exit_lock := -1
var pulse := 0.0
var hint := ""
var hint_time := 0.0
var shot_traces: Array[Dictionary] = []

static func tangent(n: Vector2) -> Vector2:
	return Vector2(-n.y, n.x)

static func transform_velocity(v: Vector2, _n_in: Vector2, n_out: Vector2) -> Vector2:
	return n_out * v.length()

func configure(blocks: Array[Rect2], surfaces: Array[Dictionary], slopes: Array = []) -> void:
	solids = blocks
	polygons.assign(slopes)
	faces = surfaces
	# Merge connected valid faces; internal seams never constrain placement.
	var merged := true
	while merged:
		merged = false
		for i in range(faces.size()):
			for j in range(i + 1, faces.size()):
				var a: Dictionary = faces[i]
				var b: Dictionary = faces[j]
				var t := tangent(a.n)
				if a.n == b.n and absf((a.a - b.a).dot(a.n)) < 0.1:
					var lo_a := minf(a.a.dot(t), a.b.dot(t))
					var hi_a := maxf(a.a.dot(t), a.b.dot(t))
					var lo_b := minf(b.a.dot(t), b.b.dot(t))
					var hi_b := maxf(b.a.dot(t), b.b.dot(t))
					if lo_b <= hi_a + 0.1 and lo_a <= hi_b + 0.1:
						faces[i] = {"a": a.n * a.a.dot(a.n) + t * minf(lo_a, lo_b), "b": a.n * a.a.dot(a.n) + t * maxf(hi_a, hi_b), "n": a.n}
						faces.remove_at(j)
						merged = true
						break
			if merged:
				break
	rebuild()

func active() -> bool:
	return not doors[0].is_empty() and not doors[1].is_empty()

func clear() -> void:
	doors = [{}, {}]
	shot_traces.clear()
	exit_lock = -1
	rebuild()

func subtract_rect(source: Rect2, cut: Rect2) -> Array[Rect2]:
	var out: Array[Rect2] = []
	if not source.intersects(cut):
		out.append(source)
		return out
	var overlap := source.intersection(cut)
	for rect in [Rect2(source.position, Vector2(source.size.x, overlap.position.y - source.position.y)), Rect2(Vector2(source.position.x, overlap.end.y), Vector2(source.size.x, source.end.y - overlap.end.y)), Rect2(Vector2(source.position.x, overlap.position.y), Vector2(overlap.position.x - source.position.x, overlap.size.y)), Rect2(Vector2(overlap.end.x, overlap.position.y), Vector2(source.end.x - overlap.end.x, overlap.size.y))]:
		if rect.size.x > 0.01 and rect.size.y > 0.01:
			out.append(rect)
	return out

static func _area(poly: PackedVector2Array) -> float:
	var area := 0.0
	for i in poly.size(): area += poly[i].cross(poly[(i+1)%poly.size()])
	return area*0.5

# Clip a convex slope against one side of the aperture's tangent boundary.
static func _clip(poly: PackedVector2Array, axis: Vector2, boundary: float, low: bool) -> PackedVector2Array:
	var result := PackedVector2Array()
	for i in poly.size():
		var a := poly[i]
		var b := poly[(i+1)%poly.size()]
		var da := a.dot(axis)-boundary
		var db := b.dot(axis)-boundary
		var inside_a := da<=0.0001 if low else da>=-0.0001
		var inside_b := db<=0.0001 if low else db>=-0.0001
		if inside_a: result.append(a)
		if inside_a != inside_b: result.append(a+(b-a)*(da/(da-db)))
	return result

static func _box_polygon(box: Rect2) -> PackedVector2Array:
	return PackedVector2Array([box.position,Vector2(box.end.x,box.position.y),box.end,Vector2(box.position.x,box.end.y)])

static func _overlap(a: PackedVector2Array, b: PackedVector2Array) -> bool:
	for piece in Geometry2D.intersect_polygons(a,b):
		if piece.size()>=3 and absf(_area(piece))>0.001: return true
	return false

static func _half_extent(axis: Vector2) -> float:
	return absf(axis.x)*11+absf(axis.y)*15

func _slope_clear(p: Vector2, n: Vector2) -> bool:
	var t := tangent(n)
	var center := p+n*(_half_extent(n)+2)
	var reach := 36-_half_extent(t)
	var corners := PackedVector2Array()
	for side in [-1,1]:
		corners.append_array(_box_polygon(Rect2(center+t*reach*side-Vector2(11,15),Vector2(22,30))))
	var clearance := Geometry2D.convex_hull(corners)
	for box in solids+occluders:
		if _overlap(clearance,_box_polygon(box)): return false
	for poly in polygons:
		if _overlap(clearance,poly): return false
	return true

func rebuild() -> void:
	if collision_root != null:
		remove_child(collision_root)
		collision_root.queue_free()
	collision_root = Node2D.new()
	add_child(collision_root)
	for solid in solids:
		var pieces: Array[Rect2] = [solid]
		if active():
			for door in doors:
				var p: Vector2 = door.p
				var n: Vector2 = door.n
				# Cut only the supporting solid, leaving every other wall intact.
				if not solid.grow(0.1).has_point(p - n * 0.05):
					continue
				var cut: Rect2
				if n.y != 0:
					cut = Rect2(p.x - 36, solid.position.y - 1, 72, solid.size.y + 2)
				else:
					cut = Rect2(solid.position.x - 1, p.y - 36, solid.size.x + 2, 72)
				var next: Array[Rect2] = []
				for piece in pieces:
					next.append_array(subtract_rect(piece, cut))
				pieces = next
		for piece in pieces:
			var body := StaticBody2D.new()
			var shape := CollisionShape2D.new()
			var box := RectangleShape2D.new()
			box.size = piece.size
			shape.shape = box
			body.position = piece.get_center()
			body.add_child(shape)
			collision_root.add_child(body)
	polygon_pieces.clear()
	for poly in polygons:
		var pieces: Array[PackedVector2Array] = [poly]
		if active():
			for door in doors:
				if not Geometry2D.is_point_in_polygon(door.p-door.n*0.05,poly): continue
				var t := tangent(door.n)
				var next: Array[PackedVector2Array] = []
				for piece in pieces:
					for side in [true,false]:
						var part := _clip(piece,t,door.p.dot(t)+(-36 if side else 36),side)
						if part.size()>=3 and absf(_area(part))>0.001: next.append(part)
				pieces = next
		for piece in pieces:
			var body := StaticBody2D.new()
			var shape := CollisionPolygon2D.new()
			shape.polygon = piece
			body.add_child(shape)
			collision_root.add_child(body)
			polygon_pieces.append(piece)
	queue_redraw()

# Slab intersection returns the first solid face along the finite aim ray.
func ray_hit(origin: Vector2, target: Vector2, include_gun_screens: bool = false) -> Dictionary:
	var direction := (target - origin).normalized()
	if direction == Vector2.ZERO:
		return {}
	var best := 2000.0
	var result := {}
	# A gate flush with terrain still covers its aperture at an equal hit distance.
	for rect in occluders + solids:
		var near := -INF
		var far := INF
		var normal := Vector2.ZERO
		var valid := true
		for axis in 2:
			if absf(direction[axis]) < 0.00001:
				if origin[axis] < rect.position[axis] or origin[axis] > rect.end[axis]:
					valid = false
					break
			else:
				var d1: float = (rect.position[axis] - origin[axis]) / direction[axis]
				var d2: float = (rect.end[axis] - origin[axis]) / direction[axis]
				var entry := minf(d1, d2)
				if entry > near:
					near = entry
					normal = Vector2.ZERO
					normal[axis] = -signf(direction[axis])
				far = minf(far, maxf(d1, d2))
		if valid and near >= 0 and near <= far and near < best:
			best = near
			result = {"p": origin + direction * near, "n": normal}
			if occluders.has(rect):
				result["occluder"] = true
	for poly in polygons:
		var near := -INF
		var far := INF
		var normal := Vector2.ZERO
		var valid := true
		for i in poly.size():
			var a := poly[i]
			var edge := poly[(i+1)%poly.size()]-a
			var n := Vector2(edge.y,-edge.x).normalized()
			if _area(poly)<0: n = -n
			var distance := (origin-a).dot(n)
			var speed := direction.dot(n)
			if absf(speed)<0.00001:
				if distance>0.0001: valid = false
			else:
				var at := -distance/speed
				if speed<0:
					if at>near: near = at; normal = n
				else: far = minf(far,at)
		if valid and near>=0 and near<=far+0.0001 and near<best:
			best = near
			result = {"p":origin+direction*near,"n":normal}
	if include_gun_screens:
		for screen in gun_screens:
			var contact = Geometry2D.segment_intersects_segment(origin,origin+direction*2000,screen.a,screen.b)
			if contact == null and absf(direction.cross(screen.b-screen.a))<0.000001 and absf(direction.cross(screen.a-origin))<0.000001:
				var first: float = (screen.a-origin).dot(direction)
				var last: float = (screen.b-origin).dot(direction)
				if maxf(first,last)>=0: contact = origin+direction*maxf(0,minf(first,last))
			if contact != null and origin.distance_to(contact)<=best:
				best = origin.distance_to(contact)
				result = {"p":contact,"n":tangent((screen.b-screen.a).normalized()),"occluder":true}
	return result

# Use the original visible screen endpoint for every displayed gun segment.
func _screen_distance(origin: Vector2, direction: Vector2) -> float:
	var distance := 2000.0
	for axis in 2:
		if direction[axis] > 0:
			distance = minf(distance, (Vector2(960, 540)[axis] - origin[axis]) / direction[axis])
		elif direction[axis] < 0:
			distance = minf(distance, -origin[axis] / direction[axis])
	return maxf(0, distance)

func _mirror_at(hit: Dictionary, direction: Vector2) -> bool:
	if hit.is_empty() or hit.get("occluder", false):
		return false
	for face in mirrors:
		if hit.n != face.n or direction.dot(face.n) >= 0 or absf((hit.p - face.a).dot(face.n)) > 0.1:
			continue
		var t := tangent(face.n)
		var at: float = hit.p.dot(t)
		if at >= minf(face.a.dot(t), face.b.dot(t)) - 0.01 and at <= maxf(face.a.dot(t), face.b.dot(t)) + 0.01:
			return true
	return false

# Shared by preview, placement and the visible shot so none can skip an obstacle.
func _shot_ray(origin: Vector2, target: Vector2) -> Dictionary:
	var segments: Array[Dictionary] = []
	var direction := (target - origin).normalized()
	var cursor := origin
	var start := origin
	for bounce in 9:
		var hit := ray_hit(cursor, target if bounce == 0 else cursor + direction * 2000,true)
		var distance := _screen_distance(cursor, direction)
		if not hit.is_empty() and cursor.distance_to(hit.p) <= distance + 0.01:
			distance = minf(distance, cursor.distance_to(hit.p))
		else:
			hit = {}
		segments.append({"a":start, "b":hit.p if not hit.is_empty() else cursor + direction * distance})
		if not _mirror_at(hit, direction):
			return {"segments":segments, "hit":hit, "direction":direction}
		if bounce == 8:
			break
		direction = direction - 2 * direction.dot(hit.n) * hit.n
		start = hit.p
		cursor = start + direction * 0.01
	return {"segments":segments, "hit":{}, "direction":direction}

func shot_path(origin: Vector2, target: Vector2) -> Array[Dictionary]:
	return _shot_ray(origin, target).segments

func _inside_blocker(point: Vector2) -> bool:
	for rect in solids + occluders:
		if rect.grow(-0.001).has_point(point):
			return true
	for poly in polygons:
		if Geometry2D.is_point_in_polygon(point,poly): return true
	return false

# Continuous lasers pass through active real apertures, never through green paint.
func beam_path(origin: Vector2, direction: Vector2) -> Array[Dictionary]:
	var segments: Array[Dictionary] = []
	if direction.is_zero_approx() or _inside_blocker(origin):
		return segments
	direction = direction.normalized()
	var cursor := origin
	var start := origin
	var remaining := 4000.0
	for hop in 17:
		var hit := ray_hit(cursor, cursor + direction * 2000)
		var distance := minf(remaining, _screen_distance(cursor, direction))
		if not hit.is_empty() and cursor.distance_to(hit.p) <= distance + 0.01:
			distance = minf(distance, cursor.distance_to(hit.p))
		else:
			hit = {}
		segments.append({"a":start, "b":hit.p if not hit.is_empty() else cursor + direction * distance})
		remaining -= distance
		if hit.is_empty() or hit.get("occluder", false) or not active() or hop == 16 or remaining <= 0.01:
			break
		var entry := -1
		var offset := 0.0
		for i in 2:
			var door: Dictionary = doors[i]
			if not hit.n.is_equal_approx(door.n) or direction.dot(door.n) >= -0.0001 or absf((hit.p - door.p).dot(door.n)) > 0.1:
				continue
			offset = (hit.p - door.p).dot(tangent(door.n))
			# Leave a two-pixel safety margin; grazing the frame stays blocked.
			if absf(offset) <= 34:
				entry = i
				break
		if entry < 0:
			break
		var output: Dictionary = doors[1 - entry]
		direction = output.n
		start = output.p + tangent(direction) * offset
		cursor = start + direction * 0.01
		if _inside_blocker(cursor):
			break
	return segments

func candidate(origin: Vector2, target: Vector2, color: int) -> Dictionary:
	var shot := _shot_ray(origin, target)
	var hit: Dictionary = shot.hit
	var direction: Vector2 = shot.direction
	if hit.is_empty() or hit.get("occluder", false) or not Rect2(0, 0, 960, 540).has_point(hit.p):
		return {}
	for face in faces:
		# A corner can tie two ray normals; accept a front-facing valid face at that impact.
		if direction.dot(face.n) >= 0 or absf((hit.p - face.a).dot(face.n)) > 0.2:
			continue
		var t := tangent(face.n)
		var low := minf(face.a.dot(t), face.b.dot(t))
		var high := maxf(face.a.dot(t), face.b.dot(t))
		var at: float = hit.p.dot(t)
		if high - low < 72 or at < low - 0.01 or at > high + 0.01:
			continue
		# An edge hit slides the full aperture inward along the same valid face.
		var placement := {"p":hit.p + t * (clampf(at, low + 36, high - 36) - at), "n":face.n}
		var other: Dictionary = doors[1 - color]
		if not other.is_empty() and (other.p - placement.p).length() < 76:
			return {}
		if absf(face.n.x)>0.0001 and absf(face.n.y)>0.0001:
			if not polygons.any(func(poly): return Geometry2D.is_point_in_polygon(placement.p-face.n*0.05,poly)): return {}
			return placement if _slope_clear(placement.p,face.n) else {}
		# Full upright player plus margin must fit immediately outside the door.
		var normal_half := 15.0 if face.n.y != 0 else 11.0
		var center: Vector2 = placement.p + face.n * (normal_half + 2)
		var space := Vector2(72, 32) if face.n.y != 0 else Vector2(24, 72)
		var clearance := Rect2(center - space / 2, space)
		for solid in solids + occluders:
			if solid.intersects(clearance):
				return {}
		for poly in polygons:
			if _overlap(_box_polygon(clearance),poly): return {}
		return placement
	return {}

func shoot(origin: Vector2, target: Vector2, color: int) -> bool:
	var hit := candidate(origin, target, color)
	var segments := shot_path(origin, target)
	for i in segments.size():
		var segment: Dictionary = segments[i]
		var direction: Vector2 = (segment.b - segment.a).normalized()
		var start: Vector2 = segment.a
		if i == 0:
			start += direction * minf(24, start.distance_to(segment.b))
		shot_traces.append({"start":start, "end":segment.b, "color":color, "valid":not hit.is_empty(), "time":0.18})
	queue_redraw()
	if hit.is_empty():
		hint = "INVALID SURFACE / OBSTRUCTED / NOT ENOUGH ROOM"
		hint_time = 1.0
		feedback.emit("invalid")
		return false
	doors[color] = hit
	exit_lock = -1
	rebuild()
	feedback.emit("red" if color == 0 else "blue")
	return true

func transport(player: CharacterBody2D, before: Vector2) -> bool:
	if not active():
		return false
	if exit_lock >= 0:
		var locked: Dictionary = doors[exit_lock]
		var n: Vector2 = locked.n
		var extent := _half_extent(n)
		if (player.position - locked.p).dot(n) > extent + 0.5 or absf((player.position - locked.p).dot(tangent(n))) > 36 + extent:
			exit_lock = -1
	for i in 2:
		if i == exit_lock:
			continue
		var entry: Dictionary = doors[i]
		var n: Vector2 = entry.n
		var t := tangent(n)
		var d0: float = (before - entry.p).dot(n)
		var d1: float = (player.position - entry.p).dot(n)
		if d0 >= 0 and d1 <= 0 and d1 < d0 and player.velocity.dot(n) < 0:
			var crossing := before.lerp(player.position, d0 / (d0 - d1))
			var offset: float = (crossing - entry.p).dot(t)
			var half_t := _half_extent(t)
			if absf(offset) + half_t > 36:
				continue
			var output: Dictionary = doors[1 - i]
			var out_n: Vector2 = output.n
			var out_half_t := _half_extent(tangent(out_n))
			var out_half_n := _half_extent(out_n)
			var safe_offset := clampf(offset, -36 + out_half_t, 36 - out_half_t)
			var destination: Vector2 = output.p + tangent(out_n) * safe_offset + out_n * (out_half_n + 1)
			var exit_box := Rect2(destination - Vector2(11,15),Vector2(22,30))
			for blocker in occluders:
				if blocker.intersects(exit_box):
					# Dynamic geometry may have moved here since placement. Keep the
					# player safely outside the entry rather than inside either solid.
					var in_half_n := _half_extent(n)
					player.position = entry.p + t * offset + n * (in_half_n + 1)
					player.velocity -= n * player.velocity.dot(n)
					return false
			player.position = destination
			player.velocity = transform_velocity(player.velocity, n, out_n)
			exit_lock = 1 - i
			pulse = 0.2
			feedback.emit("teleport")
			return true
	return false

func _process(delta: float) -> void:
	pulse = maxf(0, pulse - delta)
	hint_time = maxf(0, hint_time - delta)
	for i in range(shot_traces.size() - 1, -1, -1):
		shot_traces[i].time -= delta
		if shot_traces[i].time <= 0:
			shot_traces.remove_at(i)
	queue_redraw()

func _draw() -> void:
	for solid in solids:
		draw_rect(solid, Color("566579"))
	for poly in polygon_pieces:
		draw_colored_polygon(poly,Color("566579"))
	for face in faces:
		draw_line(face.a, face.b, Color("c6d9e5"), 5)
	for face in mirrors:
		draw_line(face.a, face.b, Color("65d58a"), 6)
	for i in 2:
		if doors[i].is_empty():
			continue
		var door: Dictionary = doors[i]
		var t := tangent(door.n)
		var color := Color("ff685e") if i == 0 else Color("4ba9ff")
		color.a = 1.0 if active() else 0.45
		draw_line(door.p - t * 34, door.p + t * 34, Color("131b2b"), 11)
		draw_line(door.p - t * 34, door.p + t * 34, color, 5 + pulse * 25)
		draw_circle(door.p - t * 34, 5, color)
		draw_circle(door.p + t * 34, 5, color)
	for trace in shot_traces:
		var strength: float = trace.time / 0.18
		var color := Color("ff685e") if trace.color == 0 else Color("4ba9ff")
		color.a = strength * 0.2
		draw_line(trace.start, trace.end, color, 8)
		color.a = strength
		draw_line(trace.start, trace.end, color, 2)
		var impact_color := color if trace.valid else Color(0.93, 0.95, 0.97, strength)
		draw_arc(trace.end, 3 + 6 * (1 - strength), 0, TAU, 20, impact_color, 2)
