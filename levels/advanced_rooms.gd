extends RefCounted

static func face(a: Vector2, b: Vector2, n: Vector2) -> Dictionary:
	return {"a":a, "b":b, "n":n}

static func coating(a: Vector2, b: Vector2, kind: String) -> Dictionary:
	var patch := face(a, b, Vector2.UP)
	patch.kind = kind
	return patch

static func base(title: String, spawn: Vector2, goal: Rect2, blocks: Array, faces: Array = []) -> Dictionary:
	return {"name":title,"spawn":spawn,"goal":goal,"blocks":blocks,"faces":faces,"enemy":false}

static func ceiling_room(title: String) -> Dictionary:
	var room := base(title,Vector2(100,385),Rect2(880,346,42,54),[
		Rect2(0,400,260,140),Rect2(560,400,400,140),Rect2(400,240,30,300),Rect2(0,40,960,20)],
		[face(Vector2(100,400),Vector2(240,400),Vector2.UP),face(Vector2(590,400),Vector2(740,400),Vector2.UP)])
	room.mirrors = [face(Vector2(20,60),Vector2(940,60),Vector2.DOWN)]
	return room

static func powered_room(title: String, elevator := false) -> Dictionary:
	var floor_y := 500.0 if elevator else 480.0
	var platform_y := 420.0 if elevator else 400.0
	var room := base(title,Vector2(210,platform_y-15),Rect2(20,146,42,54) if elevator else Rect2(900,346,42,54),[
		Rect2(0,floor_y,960,540-floor_y),Rect2(400,80,20,270),Rect2(900,60,20,290),
		Rect2(0,200,90,20) if elevator else Rect2(870,400,90,140)],
		[face(Vector2(400,120),Vector2(400,320),Vector2.LEFT),face(Vector2(900,100),Vector2(900,320),Vector2.LEFT)])
	room.mirrors = [face(Vector2(0,floor_y),Vector2(960,floor_y),Vector2.UP)]
	room.emitters = [{"p":Vector2(180,220),"d":Vector2.RIGHT}]
	room.receivers = [{"p":Vector2(750,200),"id":1}]
	room.movers = [{"rect":Rect2(100,platform_y,110,20),"to":Vector2(100,200) if elevator else Vector2(750,400),"speed":80.0,"requires":[1]}]
	return room

static func get_level(index: int) -> Dictionary:
	match index:
		35:
			return ceiling_room("THE GREEN DETOUR")
		36:
			var room := base("THE GEAR FERRY",Vector2(295,385),Rect2(890,346,42,54),[Rect2(0,400,230,140),Rect2(810,400,150,140)])
			room.movers = [{"rect":Rect2(240,400,110,20),"to":Vector2(690,400),"speed":90.0}]
			return room
		37:
			return powered_room("LIGHT THE TRACK")
		47:
			var room := powered_room("TWO GREEN HORIZONS",true)
			room.blocks.append(Rect2(0,20,960,20))
			room.blocks.append(Rect2(800,200,100,20))
			room.receivers[0].p = Vector2(750,280)
			room.faces.append(face(Vector2(0,200),Vector2(90,200),Vector2.UP))
			room.faces.append(face(Vector2(810,200),Vector2(890,200),Vector2.UP))
			room.mirrors.append(face(Vector2(20,40),Vector2(940,40),Vector2.DOWN))
			room.goal = Rect2(835,146,42,54)
			return room
		49:
			var room := powered_room("THE COMPLETE CIRCUIT")
			room.blocks[3] = Rect2(820,400,140,140)
			room.blocks[1] = Rect2(400,80,20,260)
			room.blocks.append(Rect2(500,250,230,18))
			room.blocks.append(Rect2(0,250,280,18))
			room.faces[1] = face(Vector2(900,100),Vector2(900,350),Vector2.LEFT)
			room.receivers.append({"p":Vector2(850,260),"id":2})
			room.gates = [{"rect":Rect2(810,310,10,90),"requires":[2]}]
			room.movers[0].to = Vector2(700,400)
			room.materials = [coating(Vector2(820,400),Vector2(890,400),"bounce"),coating(Vector2(500,250),Vector2(730,250),"boost")]
			room.goal = Rect2(80,196,42,54)
			return room
	return {}
