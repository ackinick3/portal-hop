extends SceneTree

var failures := 0
var game
var chapter: Script
var reflected := 0
var carried := 0.0
var room_number := 0

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		observe()

func observe() -> void:
	if game == null or game.player == null: return
	if game.player.is_on_floor() and Input.get_axis("move_left","move_right") == 0 and game.player.get_platform_velocity().length() < 500:
		carried += game.player.get_platform_velocity().length() / 120.0

func release() -> void:
	for action in ["move_left", "move_right", "jump"]:
		if InputMap.has_action(action): Input.action_release(action)

func axis(value: int) -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	if value != 0: Input.action_press("move_right" if value > 0 else "move_left")

func wait_until(condition: Callable, count := 2400) -> bool:
	for i in count:
		if condition.call(): return true
		if game.state == "won" or game.deaths > 0: return false
		await frames(1)
	return false

func steer(x: float) -> void:
	var v: float = game.player.velocity.x
	var brake := 2300.0 if game.player.is_on_floor() else 380.0
	var predicted: float = game.player.position.x + v * absf(v) / (2.0 * brake)
	if absf(x-game.player.position.x) < 3 and absf(v) < 30:
		axis(0)
	else:
		axis(1 if predicted < x else -1)

func reach(x: float, count := 600) -> void:
	for i in count:
		if game.state == "won" or game.deaths > 0: break
		steer(x)
		if absf(game.player.position.x-x) < 6 and absf(game.player.velocity.x) < 30: break
		await frames(1)
	axis(0)
	await frames(12)

func shoot(target: Vector2, color: int) -> bool:
	var ok: bool = game.portals.shoot(game.gun_origin(),target,color)
	check(ok,"Room %d actual gun shot color %d toward %s" % [room_number,color,str(target)])
	return ok

func bank(target: Vector2, mirror_y: float, color: int, double_bank := false) -> void:
	var origin: Vector2 = game.gun_origin()
	var virtual := Vector2(1800-target.x if double_bank else target.x,2*mirror_y-target.y)
	var aim := origin + (virtual-origin) * ((mirror_y-origin.y)/(virtual.y-origin.y))
	var path: Array = game.portals.shot_path(origin,aim)
	check(path.size() == (3 if double_bank else 2),"Room %d gun follows %d actual green reflections" % [room_number,2 if double_bank else 1])
	if path.size() > 1: reflected += 1
	shoot(aim,color)
	if not game.portals.doors[color].is_empty():
		check(game.portals.doors[color].p.distance_to(target)<1,"Room %d reflected shot reaches the intended hidden face" % room_number)

func ceiling_pair(target := Vector2(650,400), double_bank := false) -> void:
	check(game.portals.candidate(game.gun_origin(),target,1).is_empty(),"Room %d direct shot to the hidden face is blocked" % room_number)
	bank(target,60,1,double_bank)
	shoot(Vector2(180,400),0)
	axis(1)
	await wait_until(func(): return game.transfers > 0,400)
	check(game.transfers > 0,"Room %d traverses a real portal pair" % room_number)

func power(reverse := false, elevator := false, blue_y := 200.0) -> void:
	await wait_until(func(): return game.player.is_on_floor(),300)
	shoot(Vector2(560 if reverse else 400,220),0)
	bank(Vector2(60 if reverse else 900,blue_y),500 if elevator else 480,1)
	await frames(6)
	check(game.stage.receivers[0].active,"Room %d actual routed laser latches the platform receiver" % room_number)
	check(game.stage.movers[0].platform.enabled,"Room %d receiver enables the real mover" % room_number)

func jump_exit(direction: int) -> void:
	axis(direction)
	Input.action_press("jump")
	await wait_until(func(): return game.state == "won",450)
	Input.action_release("jump")

func board(index: int, low_y: float, horizontal := false) -> void:
	var mover = game.stage.movers[index].platform
	await wait_until(func(): return game.player.is_on_floor(),300)
	if horizontal:
		await wait_until(func(): return mover.bounds().position.x < 545,1600)
	else:
		await wait_until(func(): return mover.bounds().position.y > low_y-14,1800)
	Input.action_press("jump")
	for i in 240:
		steer(mover.bounds().get_center().x)
		await frames(1)
		if game.deaths > 0 or game.state == "won": break
		var r: Rect2 = mover.bounds()
		if i > 10 and game.player.is_on_floor() and absf(game.player.position.y+15-r.position.y)<2:
			break
	Input.action_release("jump")
	axis(0)
	await frames(20)
	check(absf(game.player.position.y+15-mover.bounds().position.y)<2,"Room %d boards the elevator/ferry with a real jump" % room_number)

func route(number: int) -> void:
	match number:
		36:
			await ceiling_pair()
			await wait_until(func(): return game.state == "won",500)
		37:
			await wait_until(func(): return game.stage.movers[0].platform.bounds().position.x>675)
			await jump_exit(1)
		38:
			await power()
			await wait_until(func(): return game.stage.movers[0].platform.bounds().position.x>738)
			await jump_exit(1)
		39:
			await ceiling_pair()
			await reach(745)
			await board(0,400)
			await wait_until(func(): return game.stage.movers[0].platform.bounds().position.y<215)
			await jump_exit(1)
		40:
			axis(1)
			await wait_until(func(): return game.player.position.x>500,400)
			await reach(710)
			await board(0,500)
			await wait_until(func(): return game.stage.movers[0].platform.bounds().position.y<285)
			await jump_exit(1)
		41:
			await wait_until(func(): return game.stage.movers[0].platform.bounds().position.y<232)
			axis(-1)
			Input.action_press("jump")
			await reach(50)
			Input.action_release("jump")
			await frames(90)
			shoot(Vector2(850,220),1)
			shoot(Vector2(50,220),0)
			axis(1)
			await wait_until(func(): return game.state == "won",500)
		42:
			await ceiling_pair()
			await wait_until(func(): return game.state == "won",600)
		43:
			await power(false,true)
			await wait_until(func(): return game.stage.movers[0].platform.bounds().position.y<212)
			await jump_exit(-1)

		44:
			await power(true)
			await wait_until(func(): return game.stage.movers[0].platform.bounds().position.x<115)
			await jump_exit(-1)
		45:
			axis(1)
			await wait_until(func(): return game.player.position.x>350 and game.player.is_on_floor() and game.player.position.y<330,500)
			await reach(475)
			await board(0,320,true)
			await wait_until(func(): return game.stage.movers[0].platform.bounds().position.x>767)
			await jump_exit(1)
		46:
			await ceiling_pair(Vector2(575,400))
			await wait_until(func(): return game.player.position.x>680,400)
			await jump_exit(1)
		47:
			await power()
			shoot(Vector2(845,400),1)
			await frames(6)
			check(game.stage.receivers[1].active and game.stage.gates[0].open,"Second real beam latches the independent exit gate")
			await wait_until(func(): return game.stage.movers[0].platform.bounds().position.x>670)
			await jump_exit(1)
		48:
			await power(false,true,280)
			await wait_until(func(): return game.stage.movers[0].platform.bounds().position.y<212)
			axis(-1)
			Input.action_press("jump")
			await reach(50)
			Input.action_release("jump")
			await frames(90)
			bank(Vector2(850,200),40,1)
			shoot(Vector2(50,200),0)
			axis(1)
			await wait_until(func(): return game.state == "won",500)
		49:
			await ceiling_pair(Vector2(650,400),true)
			await wait_until(func(): return game.state == "won",700)
		50:
			await power()
			shoot(Vector2(900,260),1)
			await frames(6)
			check(game.stage.receivers[1].active and game.stage.gates[0].open,"Final room second laser signal opens the blue landing dock")
			await wait_until(func(): return game.stage.movers[0].platform.bounds().position.x>688)
			axis(1)
			Input.action_press("jump")
			await wait_until(func(): return game.player.position.x>835,180)
			Input.action_release("jump")
			axis(-1)
			await wait_until(func(): return game.player.position.x<725 and game.player.position.y<250 and game.player.is_on_floor(),1800)
			await wait_until(func(): return game.player.position.x<520,300)
			await jump_exit(-1)

func controls() -> void:
	release()
	paused = false
	room_number = 36
	game.start_level(35)
	await frames(5)
	game.portals.mirrors.clear()
	var origin: Vector2 = game.gun_origin()
	var virtual := Vector2(650,-280)
	var aim := origin + (virtual-origin)*((60-origin.y)/(virtual.y-origin.y))
	check(game.portals.candidate(origin,aim,1).is_empty(),"Room36 hidden shot fails with green reflection disabled")
	axis(1)
	Input.action_press("jump")
	await frames(420)
	release()
	check(game.state != "won","Room36 ordinary jumping cannot cross its central barrier without portals")
	paused = false
	game.start_level(36)
	await frames(5)
	var ferry = game.stage.movers[0].platform
	ferry.set_physics_process(false)
	ferry.reset()
	axis(1)
	Input.action_press("jump")
	await frames(200)
	release()
	check(game.state != "won" and ferry.bounds().position.is_equal_approx(Vector2(240,400)),"Room37 ordinary jump cannot cross the ferry gap with the mover parked")
	paused = false
	game.start_level(49)
	room_number = 50
	await frames(5)
	await power()
	shoot(Vector2(900,260),1)
	await frames(160)
	check(game.stage.receivers[0].active and game.stage.receivers[1].active,"Final reset fixture powers both receivers using real routed beams")
	var mover = game.stage.movers[0].platform
	var parked: Rect2 = mover.bounds()
	var rider: Vector2 = game.player.position
	var clock: float = game.stage.time
	game.pause_menu()
	await frames(30)
	check(mover.bounds().is_equal_approx(parked) and game.player.position.is_equal_approx(rider) and game.stage.time==clock,"Pause freezes campaign mover rider and mechanism clock")
	game.resume()
	var retry := InputEventKey.new()
	retry.pressed = true
	retry.physical_keycode = KEY_R
	game._unhandled_input(retry)
	await frames(50)
	check(game.stage.receivers.all(func(receiver): return not receiver.active) and game.stage.gates.all(func(gate): return not gate.open),"R clears latched receivers and closes the final gate")
	check(mover.bounds().position.is_equal_approx(Vector2(100,400)) and is_zero_approx(mover.gear_angle) and not mover.enabled,"R parks the signal-powered mover at its original phase")
	check(game.portals.doors[0].is_empty() and game.portals.doors[1].is_empty(),"R clears both reflected/routed portals")

func run() -> void:
	if not ResourceLoader.exists("res://levels/advanced_rooms.gd"):
		check(false, "Advanced rooms 36-50 must exist")
		quit(1)
		return
	chapter = load("res://levels/advanced_rooms.gd")
	game = load("res://scenes/main.tscn").instantiate()
	game.persistence_enabled = false
	root.add_child(game)
	var first := 36
	var last := 50
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--room="): first = int(arg.get_slice("=",1)); last = first
		if arg.begins_with("--from="): first = int(arg.get_slice("=",1))
		if arg.begins_with("--to="): last = int(arg.get_slice("=",1))
	for room in range(first, last+1):
		room_number = room
		check(not chapter.get_level(room - 1).is_empty(), "Advanced room %d has a concrete map" % room)
		release()
		paused = false
		game.start_level(room-1)
		carried = 0
		reflected = 0
		await frames(5)
		await route(room)
		release()
		print("ADVANCED_ROOM ",room," state=",game.state," pos=",game.player.position," velocity=",game.player.velocity," transfers=",game.transfers," bounces=",game.player.bounces," boost=",game.player.boost_distance," carried=",carried," deaths=",game.deaths)
		check(game.state == "won" and game.deaths == 0,"Room %d authentic standard route reaches the exit without deaths" % room)
		if not game.data.get("mirrors",[]).is_empty(): check(reflected>0,"Room %d standard route actually uses green reflection" % room)
		if not game.data.get("movers",[]).is_empty(): check(carried>80,"Room %d standard route rides the real platform" % room)
		if not game.data.get("materials",[]).is_empty():
			for patch in game.data.materials:
				check(game.player.bounces>0 if patch.kind=="bounce" else game.player.boost_distance>20,"Room %d standard route uses %s coating" % [room,patch.kind])
	if first == 36 and last == 50: await controls()
	paused = false
	await game.drain_audio()
	# The audio mixer uses wall time; fixed-fps physics timers can finish much faster.
	OS.delay_msec(350)
	game.queue_free()
	game = null
	await process_frame
	await frames(3)
	print("ADVANCED_ROUTE_FAILURES=", failures)
	quit(0 if failures == 0 else 1)
