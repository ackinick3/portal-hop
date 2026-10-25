extends Node2D

const Maps = preload("res://levels/maps.gd")
const Tutorial = preload("res://ui/tutorial.gd")
const Landmarks = preload("res://ui/landmarks.gd")
var world: Node2D
var portals: Node2D
var player: CharacterBody2D
var enemy: Node2D
var stage: Node2D
var audio: Node
var panel: CanvasLayer
var index := 0
var unlocked := 1
var persistence_enabled := true
var elapsed := 0.0
var deaths := 0
var state := "menu"
var data := {}
var volume := 0.6
var preview := {}
var teleported_this_frame := false
var transfers := 0
var guidance := {"text":"", "markers":[]}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit = false
	audio = load("res://assets/sounds.gd").new()
	add_child(audio)
	var save := ConfigFile.new()
	if persistence_enabled and save.load("user://progress.cfg") == OK:
		restore_progress(save)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume,0.0001)))
	menu()
	print("PORTAL_HOP_READY")

func restore_progress(save: ConfigFile) -> void:
	unlocked = clampi(save.get_value("progress", "unlocked", 1), 1, Maps.LEVEL_COUNT)
	volume = clampf(save.get_value("settings", "volume", 0.6), 0, 1)

func save_progress() -> void:
	if not persistence_enabled: return
	var save := ConfigFile.new()
	save.set_value("progress", "unlocked", unlocked)
	save.set_value("settings", "volume", volume)
	save.save("user://progress.cfg")

func clear_panel() -> void:
	if panel != null:
		remove_child(panel)
		panel.queue_free()
	panel = CanvasLayer.new()
	add_child(panel)

func label_at(text: String, at: Vector2, size: int = 20) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("edf3f8"))
	panel.add_child(label)
	return label

func button(text: String, at: Vector2, action: Callable, disabled: bool = false) -> Button:
	var b := Button.new()
	b.text = text
	b.position = at
	b.size = Vector2(280,42)
	b.disabled = disabled
	b.pressed.connect(action)
	panel.add_child(b)
	return b

func backdrop() -> void:
	var dark := ColorRect.new()
	dark.color = Color(0.04,0.07,0.12,0.94)
	dark.size = Vector2(960,540)
	panel.add_child(dark)

func menu() -> void:
	state = "menu"
	get_tree().paused = true
	clear_panel()
	backdrop()
	label_at("PORTAL HOP",Vector2(310,58),46)
	label_at("THINK IN PORTALS. MOVE WITH MOMENTUM.",Vector2(252,120),18)
	button("START GAME",Vector2(340,170),func(): start_level(0))
	button("LEVEL SELECT",Vector2(340,222),level_select)
	button("HOW TO PLAY",Vector2(340,274),instructions)
	button("SETTINGS",Vector2(340,326),settings)
	button("QUIT",Vector2(340,378),quit_game)
	label_at("ORIGINAL GEOMETRIC PROTOTYPE  /  %d ROOMS" % Maps.LEVEL_COUNT,Vector2(260,474),15)
	queue_redraw()

func level_select(page: int = 0) -> void:
	clear_panel()
	backdrop()
	page = clampi(page,0,(Maps.LEVEL_COUNT-1)/10)
	label_at("SELECT A ROOM  /  %d" % (page+1),Vector2(290,62),32)
	for i in range(page*10,mini(page*10+10,Maps.LEVEL_COUNT)):
		var level_index := i
		var slot := i-page*10
		var item := button("%02d  %s%s" % [i+1, Maps.get_level(i).name, "  [LOCKED]" if i >= unlocked else ""],Vector2(100 if slot < 5 else 520,125+(slot%5)*55),func(): enter_level(level_index), i >= unlocked)
		item.size.x = 340
		item.add_theme_font_size_override("font_size",16)
	button("PREVIOUS PAGE",Vector2(100,425),func(): level_select(page-1),page==0)
	button("NEXT PAGE",Vector2(580,425),func(): level_select(page+1),page*10+10>=Maps.LEVEL_COUNT)
	button("BACK",Vector2(340,480),menu)

func enter_level(number: int) -> void:
	if number not in [5,6,7] and number < 8:
		start_level(number)
		return
	state = "briefing"
	get_tree().paused = true
	clear_panel()
	backdrop()
	if number == 5:
		label_at("AIRBORNE RELAY",Vector2(310,74),34)
		label_at("YOU CAN SHOOT IN MIDAIR",Vector2(290,130),24)
		label_at("1. BLUE on the ceiling; walk LEFT and shoot RED on the floor.\n2. Tap D to brake above RED, release movement, and fall in.\n3. In midair, move BLUE to the left wall. Fall through RED again.\n\nHold D toward the exit after the second launch.\nPortals redirect speed; gravity adds speed during the next fall.\nR retries immediately once you start.",Vector2(150,184),20)
	elif number == 6:
		label_at("MIDAIR SWITCHBACK",Vector2(280,74),34)
		label_at("TWO SHOTS, ONE FLIGHT",Vector2(300,130),24)
		label_at("1. BLUE on the left wall; walk RIGHT and shoot RED below.\n2. Tap A to brake over RED, release movement, and take the long fall.\n3. While flying: RED on the far wall, then BLUE on the lower RIGHT floor.\n\nThe next exit points straight UP beside the goal ledge.\nHold D immediately to land on it, then walk to the exit.\nR retries immediately. The lower floor is safe.",Vector2(150,184),20)
	elif number == 7:
		label_at("THE HIGH ROAD",Vector2(340,74),34)
		label_at("PLAN FIRST. THEN WALK.",Vector2(310,130),24)
		label_at("1. Before moving, place BLUE high on the left wall.\n2. Place RED on the pale floor below, also from the starting ledge.\n3. Hold D to walk off, fall through RED and fly to the exit.\n\nA high exit clears the wall. A low exit will fall short.\nNo jumping or midair shots are needed.\nMissed the landing? R resets both portals for another try.",Vector2(150,184),20)
	else:
		var room := Maps.get_level(number)
		if room.is_empty(): return
		var heading := label_at("%02d  /  %s" % [number+1,room.name],Vector2(50,66),30)
		heading.size.x = 860
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var body := Label.new()
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.position = Vector2(130,155)
		body.size = Vector2(700,235)
		body.add_theme_font_size_override("font_size",18)
		body.add_theme_color_override("font_color",Color("edf3f8"))
		body.text = "\n".join(room.get("briefing",[room.hint]))
		panel.add_child(body)
	button("START ROOM",Vector2(340,410),func(): start_level(number))
	button("BACK",Vector2(340,462),level_select)

func instructions() -> void:
	clear_panel()
	backdrop()
	label_at("HOW TO PLAY",Vector2(330,70),34)
	label_at("A / D    Run and steer in the air (release to gently slow)\nSPACE    Jump (hold for a higher jump)\nLMB / RMB    Shoot red / blue portals, even in midair\nR    Retry from checkpoint\nESC    Pause     |     F11    Fullscreen\n\nPale surfaces accept portals. Walls block shots.\nPortals keep speed; the exit sets its direction.\nFalling farther gives a faster launch.\nLand on a guard from above; side contact is fatal.",Vector2(170,135),21)
	button("BACK",Vector2(100,458),menu)
	button("MATERIALS & MACHINES",Vector2(580,458),machines_instructions)

func machines_instructions() -> void:
	clear_panel()
	backdrop()
	label_at("MATERIALS & MACHINES",Vector2(245,60),32)
	label_at("BLUE coating rebounds you automatically. Steer with A / D.\nRED coating builds running speed while you hold A / D.\nKeep that speed when you leave the runway.\n\nAMBER beams travel through active portal pairs.\nA lit receiver stays powered until R or RESTART.\nFollow its cable to the door or platform it controls.\n\nGREEN surfaces reflect your portal shots at equal angles.\nPale surfaces still accept portals; colored coatings do not.\nMoving platforms carry you. Gears and grooves show their route.",Vector2(130,125),18)
	button("CONTROLS",Vector2(100,458),instructions)
	button("BACK",Vector2(580,458),menu)

func settings() -> void:
	clear_panel()
	backdrop()
	label_at("SETTINGS",Vector2(365,90),34)
	label_at("MASTER VOLUME",Vector2(340,170))
	var slider := HSlider.new()
	slider.position = Vector2(340,210)
	slider.size = Vector2(280,32)
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.01
	slider.value = volume
	slider.value_changed.connect(func(v): volume = v; AudioServer.set_bus_volume_db(0, linear_to_db(maxf(v,0.0001))); save_progress())
	panel.add_child(slider)
	button("TOGGLE WINDOW / FULLSCREEN",Vector2(340,280),toggle_fullscreen)
	button("BACK",Vector2(340,400),menu)

func toggle_fullscreen() -> void:
	var full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)

func drain_audio() -> void:
	audio.shutdown()
	# Audio stop commands are consumed by the mixer, including while the game is paused.
	await get_tree().create_timer(0.3).timeout

func quit_game() -> void:
	if state == "closing": return
	state = "closing"
	await drain_audio()
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()

func start_level(number: int) -> void:
	var next_data := Maps.get_level(number)
	if next_data.is_empty(): return
	get_tree().paused = false
	if world != null:
		remove_child(world)
		world.queue_free()
	world = Node2D.new()
	add_child(world)
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	index = number
	elapsed = 0
	deaths = 0
	state = "playing"
	transfers = 0
	data = next_data
	portals = load("res://portals/system.gd").new()
	world.add_child(portals)
	var blocks: Array[Rect2] = []
	blocks.assign(data.blocks)
	blocks.append(Rect2(-20,-20,20,600))
	blocks.append(Rect2(960,-20,20,600))
	blocks.append(Rect2(0,-20,960,20))
	var surfaces: Array[Dictionary] = []
	surfaces.assign(data.faces)
	portals.configure(blocks,surfaces)
	portals.feedback.connect(on_portal_feedback)
	stage = load("res://world/mechanisms.gd").new()
	world.add_child(stage)
	stage.configure(data,portals)
	player = load("res://actors/player.gd").new()
	player.spawn = data.spawn
	player.position = data.spawn
	player.portal_system = portals
	player.materials.assign(data.get("materials",[]))
	player.died.connect(on_death)
	player.jumped.connect(func(): audio.play("jump"))
	player.landed.connect(func(): audio.play("land"))
	world.add_child(player)
	enemy = null
	if data.enemy:
		enemy = load("res://actors/sentry.gd").new()
		if data.has("guard"):
			enemy.spawn = data.guard.spawn
			enemy.low = data.guard.low
			enemy.high = data.guard.high
		world.add_child(enemy)
	clear_panel()
	audio.play("checkpoint")
	queue_redraw()

func on_death() -> void:
	deaths += 1
	transfers = 0
	portals.clear()
	stage.reset()
	if enemy != null: enemy.reset()
	audio.play("death")

func on_portal_feedback(kind: String) -> void:
	audio.play(kind)
	if kind == "teleport": transfers += 1

func pause_menu() -> void:
	state = "paused"
	get_tree().paused = true
	clear_panel()
	backdrop()
	label_at("PAUSED",Vector2(390,110),36)
	button("CONTINUE",Vector2(340,200),resume)
	button("RESTART ROOM",Vector2(340,260),func(): start_level(index))
	button("MAIN MENU",Vector2(340,320),menu)

func resume() -> void:
	get_tree().paused = false
	state = "playing"
	clear_panel()

func complete() -> void:
	state = "won"
	get_tree().paused = true
	unlocked = maxi(unlocked, mini(Maps.LEVEL_COUNT,index+2))
	save_progress()
	audio.play("win")
	clear_panel()
	backdrop()
	label_at("ROOM COMPLETE" if index < Maps.LEVEL_COUNT - 1 else "PROTOTYPE COMPLETE!",Vector2(265,85),36)
	label_at("%02d / %s\n\nTIME  %.2f s     DEATHS  %d" % [index+1,data.name,elapsed,deaths],Vector2(260,160),23)
	if index < Maps.LEVEL_COUNT - 1:
		button("NEXT ROOM",Vector2(340,280),func(): enter_level(index+1))
	button("REPLAY ROOM",Vector2(340,340),func(): start_level(index))
	button("MAIN MENU",Vector2(340,400),menu)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F11: toggle_fullscreen()
		if event.physical_keycode == KEY_ESCAPE:
			if state == "playing": pause_menu()
			elif state == "paused": resume()
		if event.physical_keycode == KEY_R and state == "playing": player.die()
	if event is InputEventMouseButton and event.pressed and state == "playing" and player.dead_time <= 0:
		if event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
			portals.shoot(gun_origin(),get_global_mouse_position(),0 if event.button_index == MOUSE_BUTTON_LEFT else 1)

func gun_origin() -> Vector2:
	return player.gun_origin()

func _process(delta: float) -> void:
	if state == "playing":
		elapsed += delta
		guidance = Tutorial.guidance(index, portals.doors, transfers, player.position)
		if index >= 8:
			guidance = {"text":"","markers":[]}
			for mark in data.get("guide",[]):
				if transfers >= mark.get("after",0) and transfers <= mark.get("before",99):
					guidance.markers.append(mark)
		preview = portals.candidate(gun_origin(),get_global_mouse_position(),0)
		queue_redraw()

func _physics_process(_delta: float) -> void:
	if state != "playing" or player.dead_time > 0: return
	if enemy != null:
		var kind: String = enemy.hit(player,player.previous_position,player.previous_velocity)
		if kind == "stomp": audio.play("stomp")
	if player.position.y + 15 >= 530: player.die()
	for hazard in data.get("hazards",[]):
		if hazard.intersects(Rect2(player.position-Vector2(11,15),Vector2(22,30))): player.die()
	if data.goal.grow(10).has_point(player.position) and player.dead_time <= 0: complete()

func _draw() -> void:
	if world == null: return
	# Sparse background grid and the selected rounded landmark style.
	for x in range(0,960,40):
		draw_line(Vector2(x,80),Vector2(x,540),Color(0.12,0.17,0.24,0.3))
	if data.has("goal"):
		var flag_foot: Vector2 = data.spawn + Vector2(-38,15)
		var flag_space := Rect2(flag_foot - Vector2(12,48),Vector2(24,48))
		for block in data.blocks:
			if block.intersects(flag_space):
				flag_foot = data.spawn + Vector2(38,15)
				break
		Landmarks.draw_flag(self, flag_foot, elapsed)
		Landmarks.draw_gate(self, data.goal, elapsed)
		for hazard in data.get("hazards",[]):
			for x in range(int(hazard.position.x),int(hazard.end.x),16):
				draw_colored_polygon(PackedVector2Array([Vector2(x,hazard.end.y),Vector2(x+8,hazard.position.y),Vector2(minf(x+16,hazard.end.x),hazard.end.y)]),Color("ff526b"))
		for x in range(0,960,18):
			var on_ground := false
			for block in data.blocks:
				if block.position.x <= x and block.end.x >= x and block.end.y >= 540: on_ground = true
			if not on_ground:
				draw_colored_polygon(PackedVector2Array([Vector2(x,540),Vector2(x+9,525),Vector2(x+18,540)]),Color("ff526b"))
	if state == "playing":
		for mark in guidance.markers:
			var radius := 15 + sin(elapsed * 4) * 2
			draw_arc(mark.p, radius, 0, TAU, 30, mark.color, 2)
		var mouse := get_global_mouse_position()
		var color := Color("55e0ae") if not preview.is_empty() else Color("ff526b")
		draw_arc(mouse,7,0,TAU,20,color,1.5)
		draw_line(mouse-Vector2(11,0),mouse+Vector2(11,0),color,1)
		draw_line(mouse-Vector2(0,11),mouse+Vector2(0,11),color,1)
		if not preview.is_empty():
			var tangent := Vector2(-preview.n.y,preview.n.x)
			draw_line(preview.p-tangent*36,preview.p+tangent*36,Color(0.3,1,0.7,0.4),8)
