extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var p = load("res://portals/system.gd").new()
	root.add_child(p)
	check(p.has_method("shot_path"),"Gun exposes the shared reflected shot path")
	check(p.has_method("beam_path"),"Laser exposes a portal aperture path")
	if not p.has_method("shot_path") or not p.has_method("beam_path"):
		p.queue_free()
		await process_frame
		print("OPTICS_FAILURES=",failures)
		quit(1)
		return
	# A down-right shot reflects on a real left wall face and reaches the floor.
	var blocks: Array[Rect2] = [Rect2(500,80,30,300),Rect2(80,450,700,90)]
	var faces: Array[Dictionary] = [{"a":Vector2(80,450),"b":Vector2(780,450),"n":Vector2.UP}]
	p.configure(blocks,faces)
	p.mirrors.assign([{"a":Vector2(500,80),"b":Vector2(500,380),"n":Vector2.LEFT}])
	var origin := Vector2(300,100)
	var target := Vector2(500,300)
	var path: Array[Dictionary] = p.shot_path(origin,target)
	check(path.size() == 2,"A visible green first hit reflects into a second segment")
	if path.size() == 2:
		check(path[0].b.is_equal_approx(target) and path[1].b.is_equal_approx(Vector2(350,450)),"Gun uses geometric equal-angle reflection")
	var preview: Dictionary = p.candidate(origin,target,0)
	check(not preview.is_empty() and preview.get("p",Vector2.ZERO).is_equal_approx(Vector2(350,450)),"Reflected final ray places on the pale floor")
	check(p.shoot(origin,target,0),"Actual reflected shot accepts preview")
	check(p.shot_traces.size() == 2,"Actual shot draws every reflected segment with compatible trace records")
	if not preview.is_empty(): check(p.doors[0].p == preview.p,"Reflected preview and actual placement match")
	# Final impact near an edge clamps placement, never the visible ray.
	p.clear()
	var edge_faces: Array[Dictionary] = [{"a":Vector2(340,450),"b":Vector2(440,450),"n":Vector2.UP}]
	p.faces = edge_faces
	preview = p.candidate(origin,target,1)
	check(not preview.is_empty() and preview.get("p",Vector2.ZERO).is_equal_approx(Vector2(376,450)),"Reflected edge impact clamps the full aperture inward")
	# A painted line without backing collision is not a mirror.
	p.clear()
	p.solids.assign([Rect2(80,450,700,90)])
	check(p.shot_path(origin,target).size() == 1,"A floating green line does not invent collision or reflect")
	p.solids = blocks.duplicate()
	p.solids.append(Rect2(400,150,20,200))
	path = p.shot_path(origin,target)
	check(path.size() == 1 and path[0].b.is_equal_approx(Vector2(400,200)),"An opaque first hit hides the green mirror behind it")
	p.solids = blocks.duplicate()
	p.occluders.assign([Rect2(400,150,20,200)])
	check(p.ray_hit(origin,target).p.is_equal_approx(Vector2(400,200)),"External dynamic occluder is a first ray blocker")
	check(p.candidate(origin,target,0).is_empty(),"Gun cannot place through a dynamic occluder")
	p.occluders.assign([])
	p.mirrors.assign([])
	p.faces = faces
	check(p.candidate(Vector2(350,100),Vector2(350,450),0).p.is_equal_approx(Vector2(350,450)),"Default empty optics preserve direct placement")
	p.mirrors.assign([{"a":Vector2(500,80),"b":Vector2(500,380),"n":Vector2.LEFT},{"a":Vector2(100,80),"b":Vector2(100,380),"n":Vector2.RIGHT}])
	p.solids.assign([Rect2(500,0,30,540),Rect2(70,0,30,540)])
	path = p.shot_path(Vector2(300,200),Vector2(500,200))
	check(path.size() == 9 and p.candidate(Vector2(300,200),Vector2(500,200),0).is_empty(),"Facing green mirrors reject after eight reflections")
	# Real wall portals turn a horizontal beam into an upward beam.
	p.clear()
	p.mirrors.assign([])
	p.occluders.assign([])
	blocks = [Rect2(500,0,30,540),Rect2(0,450,960,90),Rect2(0,0,960,20)]
	faces = [{"a":Vector2(500,100),"b":Vector2(500,350),"n":Vector2.LEFT},{"a":Vector2(100,450),"b":Vector2(400,450),"n":Vector2.UP}]
	p.configure(blocks,faces)
	check(p.shoot(Vector2(300,200),Vector2(500,200),0),"Laser fixture red wall door is real")
	path = p.beam_path(Vector2(300,200),Vector2.RIGHT)
	check(path.size() == 1 and path[0].b.is_equal_approx(Vector2(500,200)),"Inactive single portal remains solid to a laser")
	check(p.shoot(Vector2(250,300),Vector2(250,450),1),"Laser fixture blue floor door is real")
	path = p.beam_path(Vector2(300,200),Vector2.RIGHT)
	check(path.size() == 2,"Active portal pair routes a continuous laser")
	if path.size() == 2:
		check(path[1].a.distance_to(Vector2(250,450)) < 0.1 and path[1].b.is_equal_approx(Vector2(250,20)),"Beam leaves output along its outward normal")
	path = p.beam_path(Vector2(250,300),Vector2.DOWN)
	check(path.size() == 2 and path[1].b.x == 0,"Portal routing works in the reverse color direction")
	for y in [164.0,165.0,235.0,236.0]:
		path = p.beam_path(Vector2(300,y),Vector2.RIGHT)
		check(path.size() == 1,"Aperture edge or outside grazing ray stays blocked: " + str(y))
	path = p.beam_path(Vector2(300,210),Vector2.RIGHT)
	check(path.size() == 2 and absf(path[1].a.x - 240) < 0.01,"Safe off-center ray retains its tangential aperture offset")
	check(p.beam_path(Vector2(510,200),Vector2.LEFT).is_empty(),"Laser originating inside collision is rejected")
	p.occluders.assign([Rect2(200,200,100,20)])
	path = p.beam_path(Vector2(300,200),Vector2.RIGHT)
	check(path.size() == 2 and path[1].b.is_equal_approx(Vector2(250,220)),"A dynamic blocker also stops a beam after its portal exit")
	p.occluders.assign([Rect2(300,160,10,80)])
	check(p.beam_path(Vector2(305,200),Vector2.RIGHT).is_empty(),"Inside an external occluder is invalid too")
	p.occluders.assign([])
	# The exit points back at the entry: bounded traversal rather than infinite loop.
	p.solids.assign([Rect2(500,0,30,540),Rect2(70,0,30,540)])
	p.doors.assign([{"p":Vector2(500,200),"n":Vector2.LEFT},{"p":Vector2(100,200),"n":Vector2.RIGHT}])
	path = p.beam_path(Vector2(300,200),Vector2.RIGHT)
	check(path.size() <= 17 and path.size() > 1,"Beam portal cycles stop within the hop and distance bounds")
	p.clear()
	p.mirrors.assign([{"a":Vector2(500,0),"b":Vector2(500,540),"n":Vector2.LEFT}])
	path = p.beam_path(Vector2(300,200),Vector2.RIGHT)
	check(path.size() == 1,"Green gun mirrors never reflect lasers")
	# A moving obstacle can occupy an exit after both portals were placed safely.
	p.clear()
	p.mirrors.clear()
	p.occluders.clear()
	blocks = [Rect2(500,0,30,540),Rect2(0,450,960,90)]
	faces = [{"a":Vector2(500,100),"b":Vector2(500,350),"n":Vector2.LEFT},{"a":Vector2(100,450),"b":Vector2(400,450),"n":Vector2.UP}]
	p.configure(blocks,faces)
	check(p.shoot(Vector2(300,200),Vector2(500,200),0) and p.shoot(Vector2(250,300),Vector2(250,450),1),"Dynamic exit fixture starts with a genuinely clear portal pair")
	p.occluders.assign([Rect2(470,180,30,40)])
	var player := CharacterBody2D.new()
	root.add_child(player)
	player.position = Vector2(250,451)
	player.velocity = Vector2(23,300)
	check(not p.transport(player,Vector2(250,430)),"An exit occupied after placement refuses transport")
	check(not p.occluders[0].intersects(Rect2(player.position-Vector2(11,15),Vector2(22,30))),"Refused transport never places any part of the player inside the dynamic blocker")
	check(player.position.y <= 434 and player.velocity == Vector2(23,0),"Blocked exit keeps the player on the entry side and removes only inward normal velocity")
	# Full-player clearance is necessary even if the intended exit center is outside.
	p.occluders.assign([Rect2(468,190,10,20)])
	player.position = Vector2(250,451)
	player.velocity = Vector2(0,300)
	check(not p.transport(player,Vector2(250,430)),"An obstacle touching only the player's exit edge still blocks transport")
	p.occluders.clear()
	player.position = Vector2(250,451)
	player.velocity = Vector2(0,300)
	check(p.transport(player,Vector2(250,430)) and player.position == Vector2(488,200),"Moving the blocker away restores unchanged ordinary transport")
	player.queue_free()
	# Coincident external collision takes priority over a portal's supporting face.
	p.occluders.assign([Rect2(500,100,10,200)])
	var flush_hit: Dictionary = p.ray_hit(Vector2(300,200),Vector2(500,200))
	check(flush_hit.get("occluder",false),"A flush dynamic blocker wins an equal-distance solid hit")
	path = p.beam_path(Vector2(300,200),Vector2.RIGHT)
	check(path.size() == 1 and path[0].b == Vector2(500,200),"A blocker flush with the aperture stops the laser before routing")
	check(p.candidate(Vector2(300,200),Vector2(500,200),0).is_empty(),"A flush dynamic blocker also prevents gun placement")
	p.queue_free()
	await process_frame
	print("OPTICS_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
