extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ",message)
	if not ok: failures += 1
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await physics_frame
func release() -> void:
	for action in ["move_left","move_right","jump"]: Input.action_release(action)
func marker_at(data: Dictionary, point: Vector2) -> bool:
	return not data.markers.is_empty() and data.markers[0].p.is_equal_approx(point)
func run() -> void:
	var maps = load("res://levels/maps.gd")
	check(maps.get_level(6).get("name","") == "MIDAIR SWITCHBACK","Seventh room exists as a distinct map")
	if maps.get_level(6).get("name","") != "MIDAIR SWITCHBACK":
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for setting in [Vector3(18,280,-8),Vector3(36,280,0),Vector3(54,280,8),Vector3(30,420,0),Vector3(-1,280,0)]:
		var shot_gap := int(setting.x)
		var wall_target := Vector2(780,440 + setting.z)
		var floor_target := Vector2(240 + setting.z,380)
		game.start_level(6)
		await frames(4)
		check(game.portals.candidate(game.gun_origin(),floor_target,1).is_empty(),"New floor exit is occluded from spawn")
		check(game.portals.shoot(game.gun_origin(),Vector2(180,170 + setting.z),1),"Initial wall portal is visible from spawn")
		Input.action_press("move_right")
		var floor_placed := false
		var airborne_red := false
		var airborne_blue := false
		var red_frame := -1
		var first_speed := 0.0
		var up_speed := 0.0
		var landed := false
		for i in 750:
			await physics_frame
			if game.transfers == 0:
				if not floor_placed and game.player.position.x > 474:
					floor_placed = game.portals.shoot(game.gun_origin(),Vector2(530,480),0)
				if game.player.position.x > 475 and game.player.velocity.x > 15:
					Input.action_release("move_right")
					Input.action_press("move_left")
				if game.player.position.x > 475 and absf(game.player.velocity.x) < 15:
					Input.action_release("move_left")
			elif game.transfers == 1:
				if first_speed == 0:
					first_speed = game.player.velocity.length()
					release()
					check(not game.portals.candidate(game.gun_origin(),floor_target,1).is_empty(),"Lower exit can be aimed at immediately after the first launch")
				if shot_gap >= 0 and not airborne_red and game.player.position.x > setting.y:
					airborne_red = not game.player.is_on_floor() and game.portals.shoot(game.gun_origin(),wall_target,0)
					if airborne_red: red_frame = i
				if airborne_red and not airborne_blue and i - red_frame >= shot_gap:
					airborne_blue = not game.player.is_on_floor() and game.portals.shoot(game.gun_origin(),floor_target,1)
					if airborne_blue: print("AIR_PAIR gap=",shot_gap," p=",game.player.position)
			else:
				if up_speed == 0:
					up_speed = -game.player.velocity.y
					print("SWITCHBACK_EXIT ",game.player.position," v=",game.player.velocity)
					check(absf(game.player.velocity.x) < 0.01,"Upward exit has no inherited sideways drift")
					Input.action_press("move_right")
				if game.player.is_on_floor() and absf(game.player.position.y - 45) < 1: landed = true
			if game.state == "won" or game.deaths > 0: break
		release()
		print("ROOM7_ROUTE setting=",setting," first=",first_speed," up=",up_speed," landed=",landed," end=",game.player.position," deaths=",game.deaths)
		if shot_gap < 0:
			check(floor_placed and first_speed > 650 and game.transfers == 1 and game.state != "won","Initial pair alone cannot complete the standard route")
		else:
			check(floor_placed and airborne_red and airborne_blue,"Both replacement shots happen during the first flight")
			check(game.transfers == 2 and up_speed > 650,"Second passage converts horizontal launch into upward speed")
			check(landed and game.state == "won" and game.deaths == 0,"Route lands on final platform and completes without death")
	var retry := InputEventKey.new()
	retry.pressed = true
	retry.physical_keycode = KEY_R
	game._unhandled_input(retry)
	await frames(50)
	check(game.transfers == 0 and game.portals.doors[0].is_empty() and game.portals.doors[1].is_empty(),"R clears both doors and relay stage after a failed first launch")
	check(game.state == "playing" and game.player.position.distance_to(game.player.spawn) < 1,"R directly restores seventh-room spawn")
	var tutorial = load("res://ui/tutorial.gd")
	check(marker_at(tutorial.guidance(6,game.portals.doors,0,game.player.position),Vector2(180,170)),"Seventh guidance starts with its own initial wall")
	game.portals.shoot(game.gun_origin(),Vector2(180,170),1)
	check(marker_at(tutorial.guidance(6,game.portals.doors,0,game.player.position),Vector2(530,480)),"Seventh guidance then suggests the initial floor")
	check(marker_at(tutorial.guidance(6,game.portals.doors,1,game.player.position),Vector2(780,440)),"First launch highlights replacement RED wall")
	# Inspect later marker states using the actual successful placement data already tested above.
	game.portals.doors[0] = {"p":Vector2(780,440),"n":Vector2.LEFT}
	check(marker_at(tutorial.guidance(6,game.portals.doors,1,game.player.position),Vector2(240,380)),"Replacing RED advances to lower BLUE floor")
	game.portals.doors[1] = {"p":Vector2(240,380),"n":Vector2.UP}
	check(marker_at(tutorial.guidance(6,game.portals.doors,1,game.player.position),Vector2(780,440)),"Completed airborne pair highlights entry wall")
	check(tutorial.guidance(6,game.portals.doors,2,game.player.position).markers.is_empty(),"Upward launch clears setup markers")
	for direction in ["move_left","move_right"]:
		game.start_level(6)
		await frames(4)
		Input.action_press(direction)
		var jump_hold := 0
		for i in 240:
			await physics_frame
			if game.player.is_on_floor() and not Input.is_action_pressed("jump"):
				Input.action_press("jump")
				jump_hold = 50
			elif jump_hold > 0: jump_hold -= 1
			else: Input.action_release("jump")
			if game.state == "won": break
		release()
		check(game.state != "won","Ordinary jump chain cannot bypass the relay: " + direction)
	await game.drain_audio()
	paused = false
	game.queue_free()
	await process_frame
	print("LEVEL7_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
