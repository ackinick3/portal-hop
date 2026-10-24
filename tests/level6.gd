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
func first_marker_at(data: Dictionary, point: Vector2) -> bool:
	return not data.markers.is_empty() and data.markers[0].p.is_equal_approx(point)
func run() -> void:
	var maps = load("res://levels/maps.gd")
	check(maps.get_level(5).get("name","") == "AIRBORNE RELAY","Sixth room exists as a new map")
	if maps.get_level(5).get("name","") != "AIRBORNE RELAY":
		quit(1)
		return
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	for switch_delay in [2,16,30,45,-1]:
		game.start_level(5)
		await frames(4)
		var initial_blue := Vector2(120,71) if switch_delay < 0 else Vector2(465,60)
		check(game.portals.shoot(game.gun_origin(),initial_blue,1),"Initial blue portal is visible from spawn")
		Input.action_press("move_left")
		var floor_placed := false
		var changed_in_air := false
		var first_speed := 0.0
		var second_speed := 0.0
		var after_first := 0
		var peak_transfers := 0
		for i in 700:
			await physics_frame
			peak_transfers = maxi(peak_transfers,game.transfers)
			if game.transfers == 0:
				if not floor_placed and game.player.position.x < 586:
					floor_placed = game.portals.shoot(game.gun_origin(),Vector2(465,480),0)
				if game.player.position.x < 520 and game.player.velocity.x < -15:
					Input.action_release("move_left")
					Input.action_press("move_right")
				if game.player.position.x < 520 and absf(game.player.velocity.x) < 15:
					Input.action_release("move_right")
			elif game.transfers == 1:
				if after_first == 0:
					first_speed = game.player.velocity.length()
					release()
					if switch_delay < 0: Input.action_press("move_right")
				after_first += 1
				if after_first == switch_delay:
					changed_in_air = not game.player.is_on_floor() and game.portals.shoot(game.gun_origin(),Vector2(120,100),1)
					print("AIR_SWITCH delay=",switch_delay," p=",game.player.position," success=",changed_in_air)
			else:
				if second_speed == 0:
					second_speed = game.player.velocity.length()
					Input.action_press("move_right")
			if game.state == "won" or game.deaths > 0: break
		release()
		print("ROOM6_ROUTE delay=",switch_delay," first=",first_speed," second=",second_speed," transfers=",game.transfers," end=",game.player.position," deaths=",game.deaths)
		if switch_delay < 0:
			check(floor_placed and peak_transfers == 1 and first_speed > 700,"Comparison route performs a real single launch from a high wall exit")
			check(game.state != "won" and game.deaths > 0,"Standard single launch falls short of the final platform")
		else:
			check(floor_placed and changed_in_air,"Route shoots replacement blue while airborne")
			check(game.transfers == 2 and second_speed > first_speed + 200,"Second fall adds real speed before the second launch")
			check(game.state == "won" and game.deaths == 0,"Two-stage relay reaches exit without death")
	var tutorial = load("res://ui/tutorial.gd")
	game.start_level(5)
	await frames(4)
	check(first_marker_at(tutorial.guidance(5,game.portals.doors,0,game.player.position),Vector2(465,60)),"Sixth guidance begins with the ceiling target")
	game.portals.shoot(game.gun_origin(),Vector2(465,60),1)
	check(first_marker_at(tutorial.guidance(5,game.portals.doors,0,game.player.position),Vector2(465,480)),"Sixth guidance advances to the floor target")
	check(first_marker_at(tutorial.guidance(5,game.portals.doors,1,game.player.position),Vector2(120,100)),"First transfer highlights airborne wall replacement")
	check(tutorial.guidance(5,game.portals.doors,2,game.player.position).markers.is_empty(),"Second transfer clears setup markers")
	game.portals.shoot(game.gun_origin(),Vector2(120,100),1)
	Input.action_press("move_left")
	for i in 120:
		await physics_frame
		if game.player.position.x < 586: break
	release()
	check(game.portals.shoot(game.gun_origin(),Vector2(465,480),0),"Retry fixture places floor portal from a legal airborne position")
	check(first_marker_at(tutorial.guidance(5,game.portals.doors,1,game.player.position),game.portals.doors[0].p),"After airborne replacement the retained red portal is highlighted")
	var retry := InputEventKey.new()
	retry.pressed = true
	retry.physical_keycode = KEY_R
	game._unhandled_input(retry)
	await frames(50)
	check(game.transfers == 0 and game.portals.doors[0].is_empty() and game.portals.doors[1].is_empty(),"Sixth retry clears both portals and transfer stage")
	check(game.player.position.distance_to(game.player.spawn) < 1 and game.state == "playing","R returns to starting ledge directly without a new briefing")
	check(game.has_method("enter_level"),"Sixth room has an entry briefing before gameplay")
	if game.has_method("enter_level"):
		game.enter_level(5)
		var start: Button
		for child in game.panel.get_children():
			if child is Button and child.text == "START ROOM": start = child
		check(game.state == "briefing" and paused and start != null,"Briefing pauses gameplay and offers a clear start button")
		if start != null: start.pressed.emit()
		check(game.index == 5 and game.state == "playing" and not paused,"Briefing start opens the real sixth map")
		game.pause_menu()
		for child in game.panel.get_children():
			if child is Button and child.text == "RESTART ROOM": child.pressed.emit()
		check(game.index == 5 and game.state == "playing" and not paused,"Paused sixth room restarts directly without a briefing")
	await game.drain_audio()
	paused = false
	game.queue_free()
	await process_frame
	print("LEVEL6_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
