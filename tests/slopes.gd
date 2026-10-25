extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, text: String) -> void:
	print("PASS: " if ok else "FAIL: ",text)
	if not ok: failures += 1
func run() -> void:
	var portals = load("res://portals/system.gd").new()
	root.add_child(portals)
	var available := false
	for property in portals.get_property_list():
		if property.name == "polygons": available = true
	check(available,"Convex slope geometry is available")
	if not available:
		portals.queue_free()
		await process_frame
		quit(1)
		return
	for degrees in [15,45,75,135,195,225,255,315]:
		var n := Vector2.from_angle(deg_to_rad(float(degrees)))
		var t := Vector2(-n.y,n.x)
		var center := Vector2(620,270)
		var a := center-t*100
		var b := center+t*100
		var polygon := PackedVector2Array([a,b,b-n*40,a-n*40])
		var blocks: Array[Rect2] = [Rect2(100,400,200,140)]
		var faces: Array[Dictionary] = [{"a":Vector2(110,400),"b":Vector2(290,400),"n":Vector2.UP},{"a":a,"b":b,"n":n}]
		portals.clear()
		portals.configure(blocks,faces,[polygon])
		var ray: Dictionary = portals.ray_hit(center+n*100,center)
		check(not ray.is_empty() and ray.n.dot(n)>0.9999 and ray.p.distance_to(center)<0.1,"Slope%d returns its true first surface and normal" % degrees)
		for offset in [-100.0,0.0,100.0]:
			var target: Vector2 = center+t*offset
			var preview: Dictionary = portals.candidate(target+n*100,target,1)
			check(not preview.is_empty(),"Slope%d accepts legal edge/center shot %.0f" % [degrees,offset])
			if not preview.is_empty():
				check(preview.p.distance_to(center+t*clampf(offset,-64,64))<0.1,"Whole72px slope aperture remains within pale edge")
		var blocker := center+n*50
		portals.occluders.assign([Rect2(blocker-Vector2(8,8),Vector2(16,16))])
		check(portals.candidate(center+n*100,center,1).is_empty(),"Slope%d cannot be shot through an intervening solid" % degrees)
		portals.occluders.clear()
		var flank := center+t*25+n*25
		portals.occluders.assign([Rect2(flank-Vector2(6,6),Vector2(12,12))])
		check(portals.candidate(center+n*100,center,1).is_empty(),"Slope%d checks clearance across the full aperture, not only its center ray" % degrees)
		portals.occluders.clear()
		check(portals.shoot(Vector2(200,280),Vector2(200,400),0) and portals.shoot(center+n*100,center,1),"Slope%d pair activates using actual ray placement" % degrees)
		var beams: Array = portals.beam_path(center+n*80,-n)
		check(beams.size()>=2 and beams[1].a.distance_to(Vector2(200,400))<0.1,"Slope%d laser traverses the real paired face" % degrees)
		check(portals.beam_path(center-n*10,n).is_empty(),"A laser cannot originate inside slope material")
		# These are collision probes, not campaign route fixtures.
		var body := CharacterBody2D.new()
		var shape := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = Vector2(22,30)
		shape.shape = box
		body.add_child(shape)
		root.add_child(body)
		body.position = center+n*70
		for frame in 50:
			await physics_frame
			body.velocity = -n*360
			body.move_and_slide()
		check((body.position-center).dot(n)<-40,"Slope%d active center is a real physical opening" % degrees)
		body.position = center+n*70+t*35
		var frame_hit := false
		for frame in 35:
			await physics_frame
			body.velocity = -n*360
			body.move_and_slide()
			if body.get_slide_collision_count()>0 and (body.position-center).dot(n)>0: frame_hit = true
		print("SLOPE_FRAME ",degrees," collided=",frame_hit," normal=",(body.position-center).dot(n)," tangent=",(body.position-center).dot(t))
		check(frame_hit,"Slope%d aperture frame physically collides before any corner sliding into the hole" % degrees)
		portals.clear()
		body.position = center+n*70
		for frame in 35:
			await physics_frame
			body.velocity = -n*360
			body.move_and_slide()
		check((body.position-center).dot(n)>0,"Slope%d clearing doors restores the closed slope" % degrees)
		body.queue_free()
		await process_frame
		for inverse in [false,true]:
			portals.clear()
			portals.shoot(Vector2(200,280),Vector2(200,400),0)
			portals.shoot(center+n*100,center,1)
			var actor = load("res://actors/player.gd").new()
			actor.position = Vector2(200,250) if inverse else center+n*60
			actor.spawn = actor.position
			actor.velocity = Vector2.ZERO if inverse else -n*400
			actor.portal_system = portals
			root.add_child(actor)
			var crossed := false
			for frame in 100:
				await physics_frame
				if (actor.position.x>400 if inverse else actor.position.x<350):
					crossed = true
					break
			check(crossed,"Slope%d real character traverses %s" % [degrees,"floor to slope" if inverse else "slope to floor"])
			if crossed and inverse:
				var extent: float = absf(n.x)*11+absf(n.y)*15
				check((actor.position-center).dot(n)>=extent-0.1,"Diagonal output projects the full upright character safely outside")
				check(actor.velocity.dot(n)>0 and absf(actor.velocity.dot(t))<8,"Diagonal output keeps total speed along the face normal")
			actor.queue_free()
			await process_frame
	portals.queue_free()
	await process_frame
	print("SLOPE_FAILURES=",failures)
	quit(0 if failures==0 else 1)
