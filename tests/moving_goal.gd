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
	game.start_level(0)
	check(game.has_method("update_moving_goal"),"A moving goal follows an explicit platform anchor")
	if not game.has_method("update_moving_goal"):
		await game.drain_audio()
		game.queue_free()
		await process_frame
		quit(1)
		return
	# Isolated mechanism fixture, not a completion route: place an anchor in room1.
	game.stage.configure({"movers":[{"rect":Rect2(300,200,120,20),"to":Vector2(600,200),"speed":85}]},game.portals)
	game.data.goal_mover = 0
	game.data.goal_offset = Vector2(39,-54)
	var mover = game.stage.movers[0].platform
	await frames(70)
	check(game.data.goal.position.is_equal_approx(mover.bounds().position+Vector2(39,-54)) and mover.bounds().position.x>340,"Gate position follows the real collider, not a separate clock")
	var frozen: Rect2 = game.data.goal
	game.pause_menu()
	await frames(15)
	check(game.data.goal==frozen,"Pause freezes the platform and its goal together")
	game.resume()
	game.player.die()
	check(game.data.goal.position==Vector2(339,146),"Death resets the goal immediately with its platform")
	await frames(10)
	check(game.player.dead_time>0 and game.data.goal.position.is_equal_approx(mover.bounds().position+Vector2(39,-54)),"Goal keeps following its platform during the death animation")
	await frames(35)
	game.player.position = game.data.goal.get_center()
	game.player.velocity = Vector2.ZERO
	await frames(2)
	check(game.state=="playing","Entering the moving gate in midair cannot skip actually landing on its platform")
	game.player.position = mover.bounds().position+Vector2(60,-15)
	game.player.velocity = Vector2.ZERO
	await frames(8)
	check(game.state=="won" and game.player.is_on_floor(),"Ordinary floor contact on the anchored platform completes its gate")
	game.start_level(0)
	await frames(3)
	check(not game.data.has("goal_mover") and game.data.goal==Rect2(860,326,42,54),"Old static goals retain their geometry")
	await game.drain_audio()
	game.queue_free()
	await process_frame
	print("MOVING_GOAL_FAILURES=",failures)
	quit(0 if failures==0 else 1)
