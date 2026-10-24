extends Node2D

var player: CharacterBody2D
var deaths := 0
var status: Label

func _ready() -> void:
	terrain(Rect2(0, 430, 370, 110))
	terrain(Rect2(610, 430, 350, 110))
	terrain(Rect2(180, 350, 100, 20))
	terrain(Rect2(0, 0, 20, 540))
	terrain(Rect2(940, 0, 20, 540))
	player = load("res://actors/player.gd").new()
	player.spawn = Vector2(100, 400)
	player.position = player.spawn
	player.died.connect(func(): deaths += 1)
	add_child(player)
	var title := Label.new()
	title.text = "PORTAL HOP  /  MOVEMENT LAB"
	title.position = Vector2(38, 28)
	title.add_theme_font_size_override("font_size", 26)
	add_child(title)
	status = Label.new()
	status.position = Vector2(38, 68)
	add_child(status)
	var help := Label.new()
	help.text = "A / D  MOVE     SPACE  JUMP (hold for height)     R  RETRY     F11  FULLSCREEN\nPrototype: portals and levels are not available yet."
	help.position = Vector2(38, 110)
	add_child(help)
	print("PORTAL_HOP_MOVEMENT_LAB_READY")

func terrain(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	collider.shape = box
	body.position = rect.get_center()
	body.add_child(collider)
	var visual := Polygon2D.new()
	var h := rect.size / 2
	visual.polygon = PackedVector2Array([-h, Vector2(h.x, -h.y), h, Vector2(-h.x, h.y)])
	visual.color = Color("566579")
	body.add_child(visual)
	add_child(body)

func _process(_delta: float) -> void:
	status.text = "DEATHS  %02d     SPEED  %03d" % [deaths, player.velocity.length()]

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_R:
			player.die()
		if event.physical_keycode == KEY_F11:
			var full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)
