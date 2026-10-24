extends RefCounted

static func face(a: Vector2,b: Vector2,n: Vector2) -> Dictionary:
	return {"a":a,"b":b,"n":n}
static func mark(p: Vector2,color: String,n: Vector2) -> Dictionary:
	return {"p":p,"color":Color(color),"normal":n}
static func gate(x: float,required: Array) -> Dictionary:
	return {"rect":Rect2(x,0,20,480),"requires":required}
static func base(title: String) -> Dictionary:
	return {"name":title,"spawn":Vector2(140,465),"goal":Rect2(900,426,42,54),"blocks":[Rect2(0,480,960,60)],"faces":[],"emitters":[],"receivers":[],"gates":[],"hint":"Route light through portals to power receivers. Their lights stay on until R.","briefing":[],"guide":[],"enemy":false}

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
			data.briefing = ["Lasers are puzzle tools. Feed the beam into RED on the hanging wall.","BLUE on the floor behind you sends light UP into the receiver. Power stays latched.","Walk right below the wall and through the powered gate. R clears portals and power."]
			data.guide = [mark(Vector2(340,300),"ff685e",Vector2.LEFT),mark(Vector2(100,480),"4ba9ff",Vector2.UP)]
		20:
			data = base("LIGHT WELL")
			data.blocks.append(Rect2(390,150,60,250))
			data.faces = [face(Vector2(240,480),Vector2(360,480),Vector2.UP),face(Vector2(560,480),Vector2(700,480),Vector2.UP)]
			data.emitters = [{"p":Vector2(300,90),"d":Vector2.DOWN}]
			data.receivers = [{"p":Vector2(620,190),"id":"well"}]
			data.gates = [gate(800,["well"])]
			data.briefing = ["Catch the downward beam with RED on the left floor; BLUE belongs on the right floor.","The two floors turn falling light into rising light in a different shaft.","Jump over each floor opening on your way right. The hanging block has a low passage."]
			data.guide = [mark(Vector2(300,480),"ff685e",Vector2.UP),mark(Vector2(620,480),"4ba9ff",Vector2.UP)]
		21:
			data = base("AROUND THE CORNER")
			data.spawn = Vector2(220,465)
			data.blocks.append_array([Rect2(250,0,22,350),Rect2(500,120,24,300)])
			data.faces = [face(Vector2(80,480),Vector2(200,480),Vector2.UP),face(Vector2(500,180),Vector2(500,360),Vector2.LEFT)]
			data.emitters = [{"p":Vector2(150,90),"d":Vector2.DOWN}]
			data.receivers = [{"p":Vector2(370,280),"id":"corner"}]
			data.gates = [gate(760,["corner"])]
			data.briefing = ["The receiver sits behind the high divider. Ordinary light cannot turn that corner.","Put RED under the vertical source and BLUE on the far hanging wall, facing LEFT.","Shoot below the divider from the starting floor, then walk through both low passages."]
			data.guide = [mark(Vector2(150,480),"ff685e",Vector2.UP),mark(Vector2(500,280),"4ba9ff",Vector2.LEFT)]
		22:
			data = base("TWO LIGHT MEMORY")
			data.blocks.append_array([Rect2(300,100,24,320),Rect2(560,100,24,240)])
			data.faces = [face(Vector2(300,160),Vector2(300,340),Vector2.LEFT),face(Vector2(450,480),Vector2(570,480),Vector2.UP),face(Vector2(590,480),Vector2(730,480),Vector2.UP)]
			data.emitters = [{"p":Vector2(70,260),"d":Vector2.RIGHT}]
			data.receivers = [{"p":Vector2(520,180),"id":"left"},{"p":Vector2(660,140),"id":"right"}]
			data.gates = [gate(800,["left","right"])]
			data.briefing = ["One gate needs BOTH receivers. Their lights remember a real beam after it moves away.","Keep RED on the source wall. Aim BLUE at the first floor, then move BLUE to the second.","Walk right through the low passages. Jump over the last blue floor opening. R resets both lights."]
			data.guide = [mark(Vector2(300,260),"ff685e",Vector2.LEFT),mark(Vector2(520,480),"4ba9ff",Vector2.UP),mark(Vector2(660,480),"4ba9ff",Vector2.UP)]
		23:
			data = base("CEILING SWITCHBOARD")
			data.blocks.append_array([Rect2(300,100,24,320),Rect2(400,80,400,20)])
			data.faces = [face(Vector2(300,160),Vector2(300,340),Vector2.LEFT),face(Vector2(400,100),Vector2(800,100),Vector2.DOWN)]
			data.emitters = [{"p":Vector2(80,240),"d":Vector2.RIGHT}]
			data.receivers = [{"p":Vector2(480,300),"id":"near"},{"p":Vector2(760,300),"id":"far"}]
			data.gates = [gate(600,["near"]),gate(860,["far"])]
			data.briefing = ["Prepare RED on the source wall, then walk underneath it to aim at the ceiling.","BLUE above the near receiver opens the first gate. Cross it to see the far ceiling target.","Move BLUE above the far receiver. The first gate remembers its power; continue to the exit."]
			data.guide = [mark(Vector2(300,240),"ff685e",Vector2.LEFT),mark(Vector2(480,100),"4ba9ff",Vector2.DOWN),mark(Vector2(760,100),"4ba9ff",Vector2.DOWN)]
		24:
			data = base("CIRCUIT EXCHANGE")
			data.blocks.append_array([Rect2(300,80,24,340),Rect2(400,80,120,20),Rect2(820,100,24,320)])
			data.faces = [face(Vector2(300,140),Vector2(300,320),Vector2.LEFT),face(Vector2(400,100),Vector2(520,100),Vector2.DOWN),face(Vector2(640,480),Vector2(760,480),Vector2.UP),face(Vector2(820,200),Vector2(820,380),Vector2.LEFT)]
			data.emitters = [{"p":Vector2(80,220),"d":Vector2.RIGHT},{"p":Vector2(700,80),"d":Vector2.DOWN}]
			data.receivers = [{"p":Vector2(440,300),"id":"access"},{"p":Vector2(650,280),"id":"exit"}]
			data.gates = [gate(560,["access"]),gate(870,["exit"])]
			data.briefing = ["First circuit: RED on the left source wall, then BLUE on the near ceiling after walking under it.","After the first gate opens, replace RED below the second source and BLUE on the far wall.","The second receiver opens the exit. Jump over the red floor opening, then use the low wall passage."]
			data.guide = [mark(Vector2(300,220),"ff685e",Vector2.LEFT),mark(Vector2(440,100),"4ba9ff",Vector2.DOWN),mark(Vector2(700,480),"ff685e",Vector2.UP),mark(Vector2(820,280),"4ba9ff",Vector2.LEFT)]
		_:
			return {}
	return data
