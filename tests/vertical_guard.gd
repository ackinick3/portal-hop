extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,text: String) -> void:
	print("PASS: " if ok else "FAIL: ",text)
	if not ok: failures += 1
func frames(count: int) -> void:
	for i in count: await physics_frame
func run() -> void:
	var game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	game.start_level(23)
	await frames(5)
	check(game.enemy!=null,"Room24 contains the requested moving guard")
	if game.enemy==null:
		await game.drain_audio()
		game.queue_free()
		await process_frame
		quit(1)
		return
	var guard = game.enemy
	check(guard.vertical and guard.spawn==Vector2(542,208.5) and guard.low==54 and guard.high==363,"Guard follows the straightened user patrol, with existing speed")
	var previous: Vector2 = guard.position
	var down := false
	var up := false
	var bounded := true
	for i in 900:
		await physics_frame
		bounded = bounded and absf(guard.position.x-542)<0.01 and guard.position.y>=54 and guard.position.y<=363
		down = down or guard.position.y>previous.y
		up = up or guard.position.y<previous.y
		previous = guard.position
	check(down and up and bounded,"Guard really reverses vertically and remains within the patrol")
	game.pause_menu()
	var frozen: Vector2 = guard.position
	await frames(20)
	check(guard.position==frozen,"Pause freezes the vertical guard")
	game.resume()
	game.player.die()
	check(guard.alive and guard.position==guard.spawn and guard.direction==1,"Death resets the vertical guard immediately")
	await frames(50)
	check(game.deaths==1 and game.player.position.distance_to(game.player.spawn)<1,"Guard does not cause a spawn death loop")
	game.start_level(2)
	await frames(5)
	guard = game.enemy
	previous = guard.position
	await frames(40)
	check(not guard.vertical and guard.position.y==previous.y and guard.position.x!=previous.x,"Original third-room guard still patrols horizontally")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("VERTICAL_GUARD_FAILURES=",failures)
	quit(0 if failures==0 else 1)
