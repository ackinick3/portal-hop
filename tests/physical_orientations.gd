extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var normals := [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]
	for n_in in normals:
		for n_out in normals:
			var room := Node2D.new()
			root.add_child(room)
			var portals = load("res://portals/system.gd").new()
			room.add_child(portals)
			var a := Vector2(250,270)
			var b := Vector2(700,270)
			var solids: Array[Rect2] = [block(a,n_in),block(b,n_out)]
			var surfaces: Array[Dictionary] = []
			portals.configure(solids,surfaces)
			portals.doors[0] = {"p":a,"n":n_in}
			portals.doors[1] = {"p":b,"n":n_out}
			portals.rebuild()
			var player = load("res://actors/player.gd").new()
			player.position = a+n_in*90
			player.spawn = player.position
			player.velocity = -n_in*900 + Vector2(-n_in.y,n_in.x)*60
			player.portal_system = portals
			room.add_child(player)
			var crossed := false
			for i in 30:
				await physics_frame
				if player.position.x > 550:
					crossed = true
					break
			if not crossed:
				failures += 1
				print("FAIL PHYSICAL ",n_in," -> ",n_out," pos=",player.position)
			room.queue_free()
			await process_frame
	print("PHYSICAL_ORIENTATION_PAIRS=16 FAILURES=",failures)
	quit(0 if failures == 0 else 1)
func block(p: Vector2,n: Vector2) -> Rect2:
	if n == Vector2.UP: return Rect2(p-Vector2(100,0),Vector2(200,40))
	if n == Vector2.DOWN: return Rect2(p-Vector2(100,40),Vector2(200,40))
	if n == Vector2.RIGHT: return Rect2(p-Vector2(40,100),Vector2(40,200))
	return Rect2(p-Vector2(0,100),Vector2(40,200))

