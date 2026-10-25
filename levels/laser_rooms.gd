extends RefCounted

static func face(a: Vector2,b: Vector2,n: Vector2) -> Dictionary:
	return {"a":a,"b":b,"n":n}
static func gate(x: float,required: Array) -> Dictionary:
	return {"rect":Rect2(x,0,20,480),"requires":required}
static func base(title: String) -> Dictionary:
	return {"name":title,"spawn":Vector2(140,465),"goal":Rect2(900,426,42,54),"blocks":[Rect2(0,480,960,60)],"faces":[],"emitters":[],"receivers":[],"gates":[],"enemy":false}

static func get_level(index: int) -> Dictionary:
	var data: Dictionary
	match index:
		19:
			data = base("FIRST LIGHT")
			data.blocks.append(Rect2(340,120,24,300))
			data.faces = [face(Vector2(340,200),Vector2(340,380),Vector2.LEFT),face(Vector2(60,480),Vector2(220,480),Vector2.UP)]
			data.emitters = [{"p":Vector2(80,300),"d":Vector2.RIGHT}]
			data.receivers = [{"p":Vector2(100,160),"id":"light"}]
			data.gates = [gate(780,["light"])]
		20:
			data = base("LIGHT WELL")
			data.blocks.append(Rect2(390,150,60,250))
			data.faces = [face(Vector2(240,480),Vector2(360,480),Vector2.UP),face(Vector2(560,480),Vector2(700,480),Vector2.UP)]
			data.emitters = [{"p":Vector2(300,90),"d":Vector2.DOWN}]
			data.receivers = [{"p":Vector2(620,190),"id":"well"}]
			data.gates = [gate(800,["well"])]
		24:
			data = base("CIRCUIT EXCHANGE")
			data.blocks.append_array([Rect2(300,80,24,340),Rect2(400,80,120,20),Rect2(820,100,24,320)])
			data.faces = [face(Vector2(300,140),Vector2(300,320),Vector2.LEFT),face(Vector2(400,100),Vector2(520,100),Vector2.DOWN),face(Vector2(640,480),Vector2(760,480),Vector2.UP),face(Vector2(820,200),Vector2(820,380),Vector2.LEFT)]
			data.emitters = [{"p":Vector2(80,220),"d":Vector2.RIGHT},{"p":Vector2(700,80),"d":Vector2.DOWN}]
			data.receivers = [{"p":Vector2(440,300),"id":"access"},{"p":Vector2(650,280),"id":"exit"}]
			data.gates = [gate(560,["access"]),gate(870,["exit"])]
		_:
			return {}
	return data
