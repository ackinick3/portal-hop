extends SceneTree
var failures := 0
var game: Node2D
func check(ok: bool, text: String) -> void:
	print("PASS: " if ok else "FAIL: ", text)
	if not ok: failures += 1
func _initialize() -> void:
	call_deferred("run")
func step(count: int) -> void:
	for i in count: await physics_frame
func jump() -> void:
	Input.action_press("jump")
func release() -> void:
	for action in ["move_left","move_right","jump"]: Input.action_release(action)
func run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(0)
	await step(10)
	check(game.state == "playing", "Menu starts room")
	# Portal targets are shot from an actual legal standing location.
	check(game.portals.shoot(game.gun_origin(),Vector2(300,380),0), "Room 1 red visible from spawn")
	check(game.portals.shoot(game.gun_origin(),Vector2(720,380),1), "Room 1 blue visible from spawn")
	Input.action_press("move_right")
	jump()
	var crossed := false
	for i in 260:
		await physics_frame
		if i == 50: Input.action_release("jump")
		# A second jump on the 40px first step reaches the upper step.
		if false:
			Input.action_release("jump")
			await step(1)
			jump()
		if game.player.position.x > 610: crossed = true
		if game.state == "won": break
	release()
	check(crossed, "Room 1 physically crosses via floor portals")
	check(game.state == "won", "Room 1 reaches goal using movement input")
	game.start_level(1)
	await step(3)
	# A shot to the lower wall is blocked by the high platform; fire at upper wall instead.
	check(game.portals.shoot(game.gun_origin(),Vector2(180,90),1), "Room 2 wall target has line of sight")
	var floor_shot := false
	Input.action_press("move_right")
	var launched := false
	var max_speed := 0.0
	for i in 500:
		await physics_frame
		# Leave high platform, then brake over the floor portal.
		if not floor_shot and game.player.position.x > 409:
			floor_shot = game.portals.shoot(game.gun_origin(),Vector2(465,470),0)
		if not launched and game.player.position.x > 410 and game.player.velocity.x > 15:
			Input.action_release("move_right")
			Input.action_press("move_left")
		if not launched and game.player.position.x >= 410 and absf(game.player.velocity.x) < 15:
			Input.action_release("move_left")
		if false:
			Input.action_release("move_right")
			Input.action_press("move_left")
		if not launched and game.player.velocity.x > 400:
			launched = true
			release()
			Input.action_press("move_right")
		if launched and game.player.position.x > 850:
			Input.action_release("move_right")
			Input.action_press("move_left")
		max_speed = maxf(max_speed,game.player.velocity.x)
		if game.state == "won" or game.deaths > 0: break
	release()
	print("ROOM2_END ",game.player.position," speed=",max_speed," deaths=",game.deaths)
	check(launched,"Room 2 produces real horizontal launch")
	check(game.state == "won","Room 2 launch lands and reaches goal")
	game.start_level(2)
	await step(3)
	Input.action_press("move_right")
	for i in 600:
		await physics_frame
		if game.player.is_on_floor() and (game.player.position.x > 380 and game.player.position.x < 580 or game.player.position.x > 615):
			jump()
		else:
			Input.action_release("jump")
		if game.state == "won" or game.deaths > 0: break
	release()
	print("ROOM3_END ",game.player.position," deaths=",game.deaths)
	check(game.state == "won", "Room 3 ordinary action route reaches goal")
	game.start_level(2)
	await step(3)
	var guard = game.enemy
	game.player.position = guard.position + Vector2(0,-60)
	game.player.velocity = Vector2(0,200)
	for i in 40:
		await physics_frame
		if not guard.alive: break
	check(not guard.alive and game.deaths == 0,"Downward contact stomps guard")
	game.player.die()
	await step(45)
	check(guard.alive and game.portals.doors[0].is_empty(),"Death resets guard and portals")
	guard.hit(game.player,guard.position-Vector2(60,0),Vector2(700,0))
	# Direct swept-contact fixture crosses the enemy in one physics step.
	game.player.position = guard.position+Vector2(60,0)
	var result: String = guard.hit(game.player,guard.position-Vector2(60,0),Vector2(2000,0))
	check(result == "death", "Fast side contact is fatal")
	print("GAME_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)




