extends Node2D

const Maps = preload("res://levels/maps.gd")
var world: Node2D
var portals: Node2D
var player: CharacterBody2D
var enemy: Node2D
var audio: Node
var panel: CanvasLayer
var hud: Label
var message: Label
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

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	audio = load("res://assets/sounds.gd").new()
	add_child(audio)
	var save := ConfigFile.new()
	if persistence_enabled and save.load("user://progress.cfg") == OK:
		unlocked = clampi(save.get_value("progress", "unlocked", 1), 1, 3)
		volume = clampf(save.get_value("settings", "volume", 0.6), 0, 1)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume,0.0001)))
	menu()
	print("PORTAL_HOP_READY")

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
	button("QUIT",Vector2(340,378),func(): get_tree().quit())
	label_at("ORIGINAL GEOMETRIC PROTOTYPE  /  THREE ROOMS",Vector2(260,474),15)
	queue_redraw()

func level_select() -> void:
	clear_panel()
	backdrop()
	label_at("SELECT A ROOM",Vector2(330,90),32)
	for i in 3:
		var level_index := i
		button("%02d  %s%s" % [i+1, Maps.get_level(i).name, "  [LOCKED]" if i >= unlocked else ""],Vector2(340,170+i*60),func(): start_level(level_index), i >= unlocked)
	button("BACK",Vector2(340,400),menu)

func instructions() -> void:
	clear_panel()
	backdrop()
	label_at("HOW TO PLAY",Vector2(330,70),34)
	label_at("A / D    Run and steer in the air\nSPACE    Jump (hold for a higher jump)\nLMB / RMB    Shoot red / blue portals\nR    Retry from checkpoint\nESC    Pause     |     F11    Fullscreen\n\nPale surfaces accept portals. Walls block shots.\nTwo portals open a passage; momentum changes direction.\nFalling farther gives a faster launch.\nLand on a guard from above; side contact is fatal.",Vector2(170,135),21)
	button("BACK",Vector2(340,458),menu)

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

func start_level(number: int) -> void:
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
	data = Maps.get_level(index)
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
	portals.feedback.connect(audio.play)
	player = load("res://actors/player.gd").new()
	player.spawn = data.spawn
	player.position = data.spawn
	player.portal_system = portals
	player.died.connect(on_death)
	player.jumped.connect(func(): audio.play("jump"))
	player.landed.connect(func(): audio.play("land"))
	world.add_child(player)
	enemy = null
	if data.enemy:
		enemy = load("res://actors/sentry.gd").new()
		world.add_child(enemy)
	clear_panel()
	hud = label_at("",Vector2(28,16),19)
	message = label_at(data.hint,Vector2(28,48),16)
	audio.play("checkpoint")
	queue_redraw()

func on_death() -> void:
	deaths += 1
	portals.clear()
	if enemy != null: enemy.reset()
	audio.play("death")

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
	hud = label_at("",Vector2(28,16),19)
	message = label_at(data.hint,Vector2(28,48),16)

func complete() -> void:
	state = "won"
	get_tree().paused = true
	unlocked = maxi(unlocked, mini(3,index+2))
	save_progress()
	audio.play("win")
	clear_panel()
	backdrop()
	label_at("ROOM COMPLETE" if index < 2 else "PROTOTYPE COMPLETE!",Vector2(265,85),36)
	label_at("%02d / %s\n\nTIME  %.2f s     DEATHS  %d" % [index+1,data.name,elapsed,deaths],Vector2(260,160),23)
	if index < 2:
		button("NEXT ROOM",Vector2(340,280),func(): start_level(index+1))
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
		hud.text = "ROOM %02d    TIME %06.1f    DEATHS %02d    RED %s / BLUE %s" % [index+1,elapsed,deaths,"READY" if not portals.doors[0].is_empty() else "--","READY" if not portals.doors[1].is_empty() else "--"]
		message.text = portals.hint if portals.hint_time > 0 else data.hint
		preview = portals.candidate(gun_origin(),get_global_mouse_position(),0)
		queue_redraw()

func _physics_process(_delta: float) -> void:
	if state != "playing" or player.dead_time > 0: return
	if enemy != null:
		var kind: String = enemy.hit(player,player.previous_position,player.previous_velocity)
		if kind == "stomp": audio.play("stomp")
	if player.position.y + 15 >= 530: player.die()
	if data.goal.grow(10).has_point(player.position) and player.dead_time <= 0: complete()

func _draw() -> void:
	if world == null: return
	# Sparse background grid and the green destination arch.
	for x in range(0,960,40):
		draw_line(Vector2(x,80),Vector2(x,540),Color(0.12,0.17,0.24,0.3))
	if data.has("goal"):
		draw_line(data.spawn + Vector2(0,15),data.spawn - Vector2(0,12),Color("55e0ae"),2)
		draw_line(data.spawn - Vector2(0,12),data.spawn + Vector2(14,-7),Color("55e0ae"),4)
		var goal: Rect2 = data.goal
		draw_rect(goal,Color("55e0ae"),false,4)
		draw_line(goal.get_center()+Vector2(-9,0),goal.get_center()+Vector2(9,0),Color("55e0ae"),3)
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
