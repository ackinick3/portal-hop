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
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	# Use an edge of the legal exit patch, not only the exact suggested center.
	game.start_level(6)
	await frames(4)
	game.portals.shoot(game.gun_origin(),Vector2(180,170),1)
	Input.action_press("move_right")
	var first_speed := 0.0
	var second_speed := 0.0
	var placed := false
	var red := false
	var blue := false
	var ceiling_hit := false
	for i in 650:
		await physics_frame
		if game.transfers == 0:
			if not placed and game.player.position.x > 524:
				placed = game.portals.shoot(game.gun_origin(),Vector2(590,510),0)
			if game.player.position.x > 535 and game.player.velocity.x > 15:
				Input.action_release("move_right")
				Input.action_press("move_left")
			if game.player.position.x > 535 and absf(game.player.velocity.x) < 15: Input.action_release("move_left")
		elif game.transfers == 1:
			if first_speed == 0:
				first_speed = game.player.velocity.length()
				release()
			if not red and game.player.position.x > 280:
				red = game.portals.shoot(game.gun_origin(),Vector2(820,390),0)
			if red and not blue and game.player.position.x > 410:
				blue = game.portals.shoot(game.gun_origin(),Vector2(620,420),1)
		else:
			if second_speed == 0:
				second_speed = game.player.velocity.length()
				print("ENERGY_EXIT p=",game.player.position," v=",game.player.velocity)
				Input.action_press("move_right")
			if game.player.is_on_ceiling() and game.player.position.y > 25:
				ceiling_hit = true
				print("ENERGY_CEILING_HIT p=",game.player.position," v=",game.player.velocity)
		if game.state == "won" or game.deaths > 0: break
	release()
	print("ENERGY_ROUTE first=",first_speed," second=",second_speed," ceiling=",ceiling_hit," end=",game.player.position)
	check(first_speed > 850,"Initial energy has a generous natural-fall margin")
	check(red and blue and second_speed > 750,"A less-centered entry still provides enough real upward speed")
	check(not ceiling_hit,"Upward launch does not lose speed against the underside of a platform")
	check(game.state == "won" and game.deaths == 0,"A wider legal exit placement still completes the room")
	await game.drain_audio()
	paused = false
	game.queue_free()
	await process_frame
	print("LEVEL7_ENERGY_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
