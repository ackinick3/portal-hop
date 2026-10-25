extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,text: String) -> void:
	print("PASS: " if ok else "FAIL: ",text)
	if not ok: failures += 1
func run() -> void:
	var portals = load("res://portals/system.gd").new()
	root.add_child(portals)
	var a := Vector2(340,440)
	var b := Vector2(440,410)
	var n := Vector2(-30,-100).normalized()
	var blocks: Array[Rect2] = [Rect2(40,430,300,20)]
	var faces: Array[Dictionary] = []
	portals.configure(blocks,faces,[load("res://levels/designed_rooms.gd").strip(a,b)])
	var actor = load("res://actors/player.gd").new()
	actor.spawn = Vector2(90,415)
	actor.position = actor.spawn
	actor.materials.assign([{"a":Vector2(140,430),"b":Vector2(340,430),"n":Vector2.UP,"kind":"boost"},{"a":a+n*10,"b":b+n*10,"n":n,"kind":"boost"}])
	root.add_child(actor)
	for i in 5: await physics_frame
	Input.action_press("move_right")
	var measured := false
	var braked := false
	for i in 250:
		await physics_frame
		if not braked and actor.position.x>360 and actor.is_on_floor():
			braked = true
			var before: float = actor.velocity.length()
			Input.action_release("move_right")
			for frame in 6: await physics_frame
			check(actor.velocity.length()<before-80,"Released red-ramp input uses the existing deliberate braking")
			Input.action_press("move_right")
		if actor.position.x>455:
			measured = true
			print("SLOPE_BOOST_EXIT p=",actor.position," v=",actor.velocity," distance=",actor.boost_distance)
			check(actor.velocity.x>580 and actor.velocity.y< -100,"Red ramp keeps existing boost speed and naturally launches upward")
			check(actor.boost_distance>260,"Boost contact continues across the slope instead of stopping at the flat seam")
			break
	check(measured,"Real character traverses flat-to-ramp boost geometry")
	Input.action_release("move_right")
	actor.queue_free()
	portals.queue_free()
	await process_frame
	print("SLOPE_BOOST_FAILURES=",failures)
	quit(0 if failures==0 else 1)
