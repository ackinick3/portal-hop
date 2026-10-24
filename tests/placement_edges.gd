extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var p = load("res://portals/system.gd").new()
	root.add_child(p)
	for normal in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
		var t: Vector2 = p.tangent(normal)
		var center := Vector2(480,270)
		var half := Vector2(100,20) if normal.y != 0 else Vector2(20,100)
		var blocks: Array[Rect2] = [Rect2(center - normal * 20 - half,half * 2)]
		var faces: Array[Dictionary] = [{"a":center - t * 100,"b":center + t * 100,"n":normal}]
		p.clear()
		p.configure(blocks,faces)
		for offset in [-100.0,-95.0,0.0,95.0,100.0]:
			var target: Vector2 = center + t * offset
			var origin: Vector2 = target + normal * 100
			var preview: Dictionary = p.candidate(origin,target,0)
			var expected: Vector2 = center + t * clampf(offset,-64,64)
			check(not preview.is_empty(),"Edge shot accepted: " + str(normal) + " / " + str(offset))
			if not preview.is_empty():
				check(preview.p.is_equal_approx(expected),"Whole portal shifts inward and stays on the hit face")
				check(p.shoot(origin,target,0) and p.doors[0].p.is_equal_approx(preview.p),"Preview matches actual edge placement")
				check(p.shot_traces.back().end.is_equal_approx(target),"Beam still stops at actual wall impact")
		for offset in [-100.0,100.0]:
			var target: Vector2 = center + t * offset
			var origin: Vector2 = target + normal * 100 + t * signf(offset) * 50
			var corner: Dictionary = p.candidate(origin,target,0)
			check(not corner.is_empty(),"Diagonal physical corner accepts the visible pale face: " + str(normal) + " / " + str(offset))
			if not corner.is_empty():
				check(corner.n == normal and corner.p.is_equal_approx(center + t * clampf(offset,-64,64)),"Mirrored corner uses the correct inward center and surface normal")
		# Keep enough solid beyond the pale patch to distinguish material from its edge.
		faces = [{"a":center - t * 60,"b":center + t * 60,"n":normal}]
		p.clear()
		p.configure(blocks,faces)
		check(p.candidate(center + t * 61 + normal * 100,center + t * 61,0).is_empty(),"Non-pale region beside the edge stays invalid")
		faces = [{"a":center - t * 35,"b":center + t * 35,"n":normal}]
		p.configure(blocks,faces)
		check(p.candidate(center + normal * 100,center,0).is_empty(),"Surface shorter than 72px stays invalid")
		faces = [{"a":center - t * 36,"b":center + t * 36,"n":normal}]
		p.configure(blocks,faces)
		check(not p.candidate(center + t * 35 + normal * 100,center + t * 35,0).is_empty(),"Exactly 72px surface fits by centering the portal")
	# At an exact physical corner, the slab ray can choose the other tied normal.
	var corner_blocks: Array[Rect2] = [Rect2(100,400,300,140)]
	var corner_faces: Array[Dictionary] = [{"a":Vector2(100,400),"b":Vector2(400,400),"n":Vector2.UP}]
	p.clear()
	p.configure(corner_blocks,corner_faces)
	check(p.shoot(Vector2(50,300),Vector2(100,400),0),"Diagonal corner hit can use the visible valid floor face")
	if not p.doors[0].is_empty():
		check(p.doors[0].p.is_equal_approx(Vector2(136,400)) and p.doors[0].n == Vector2.UP,"Corner placement keeps floor normal and whole inward aperture")
	var blocks: Array[Rect2] = [Rect2(300,100,30,350)]
	var faces: Array[Dictionary] = [{"a":Vector2(300,150),"b":Vector2(300,400),"n":Vector2.LEFT}]
	p.clear()
	p.configure(blocks,faces)
	check(p.shoot(Vector2(200,155),Vector2(300,155),1),"Blue portal can snap near wall edge")
	check(not p.shoot(Vector2(200,160),Vector2(300,160),0),"Overlap uses shifted center and still rejects the second color")
	blocks.append(Rect2(275,170,10,20))
	p.clear()
	p.configure(blocks,faces)
	check(not p.shoot(Vector2(200,150),Vector2(300,150),0),"Shifted portal still requires clearance for the full aperture")
	check(p.doors[0].is_empty(),"Blocked edge placement never opens a collision gap")
	p.queue_free()
	await process_frame
	print("PLACEMENT_EDGE_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
