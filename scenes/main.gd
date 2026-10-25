extends Node2D

const Maps = preload("res://levels/maps.gd")
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
	var stored: int = save.get_value("progress", "unlocked", 1)
	if save.get_value("progress", "order_version", 1) < 2:
		unlocked = Maps.LEVEL_COUNT
		for i in Maps.LEVEL_COUNT:
			if Maps.ROOM_IDS[i] >= maxi(stored,1):
				unlocked = i+1
				break
	else:
		unlocked = clampi(stored,1,Maps.LEVEL_COUNT)
	volume = clampf(save.get_value("settings", "volume", 0.6), 0, 1)

func save_progress() -> void:
	if not persistence_enabled: return
	var save := ConfigFile.new()
	save.set_value("progress", "unlocked", unlocked)
	save.set_value("progress", "order_version", 2)
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
	button("START GAME",Vector2(340,170),func(): start_level(0))
	button("LEVEL SELECT",Vector2(340,222),level_select)
	button("SETTINGS",Vector2(340,274),settings)
	button("QUIT",Vector2(340,326),quit_game)
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
	start_level(number)

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
	portals.configure(blocks,surfaces,data.get("polygons",[]))
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
			enemy.vertical = data.guard.get("vertical",false)
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
		var mouse := get_global_mouse_position()
		var color := Color("55e0ae") if not preview.is_empty() else Color("ff526b")
		draw_arc(mouse,7,0,TAU,20,color,1.5)
		draw_line(mouse-Vector2(11,0),mouse+Vector2(11,0),color,1)
		draw_line(mouse-Vector2(0,11),mouse+Vector2(0,11),color,1)
		if not preview.is_empty():
			var tangent := Vector2(-preview.n.y,preview.n.x)
			draw_line(preview.p-tangent*36,preview.p+tangent*36,Color(0.3,1,0.7,0.4),8)
