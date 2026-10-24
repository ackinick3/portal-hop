extends RefCounted

static func face(a: Vector2,b: Vector2,n: Vector2) -> Dictionary:
	return {"a":a,"b":b,"n":n}
static func mark(p: Vector2,color: String,after: int,before: int) -> Dictionary:
	return {"p":p,"color":Color(color),"normal":Vector2.UP,"after":after,"before":before}
static func get_level(index: int) -> Dictionary:
	if index == 8:
		return {"name":"APEX RELAY","spawn":Vector2(169,175),"goal":Rect2(908,246,42,54),"blocks":[Rect2(50,190,120,18),Rect2(180,470,110,18),Rect2(315,430,100,18),Rect2(525,430,100,18),Rect2(725,430,100,18),Rect2(435,300,18,240),Rect2(645,300,18,240),Rect2(860,300,100,240)],"faces":[face(Vector2(180,470),Vector2(290,470),Vector2.UP),face(Vector2(315,430),Vector2(415,430),Vector2.UP),face(Vector2(525,430),Vector2(625,430),Vector2.UP),face(Vector2(725,430),Vector2(825,430),Vector2.UP)],"hint":"Keep the portal beneath you; move the other to the next floor near the top of each rise.","briefing":["Prepare RED on the low left floor and BLUE on the first small platform.","Fall into RED. Near the top of the rise, move RED to the next platform. Fall back into BLUE.","On the next rise move BLUE one platform farther. After the third launch hold D to reach the exit. R retries."],"guide":[mark(Vector2(230,470),"ff685e",0,0),mark(Vector2(365,430),"4ba9ff",0,0),mark(Vector2(575,430),"ff685e",1,1),mark(Vector2(775,430),"4ba9ff",2,2)],"enemy":false}
	if index >= 25 and index <= 34: return mixed_room(index+1)
	return {}


static func mixed_room(room: int) -> Dictionary:
	var titles := ["RUN SPRING POWER","TWIN CONTACTS","UNDER THE CIRCUIT","DOWNWARD CURRENT","RETURN CURRENT","SOURCE SELECTOR","AIRBORNE IGNITION","FLIGHT SWITCHES","TWO STAGE RUN","BACKFLOW RELAY"]
	var launch_x: float = [310.0,325.0,300.0,340.0,315.0,290.0,310.0,320.0,330.0,300.0][room-26]
	var landing_y: float = [350.0,360.0,340.0,370.0,350.0,360.0,350.0,365.0,355.0,360.0][room-26]
	var blocks: Array[Rect2] = [Rect2(0,450,launch_x+90,90),Rect2(770,landing_y,190,540-landing_y)]
	var faces: Array[Dictionary] = []
	var emitters: Array = []
	var receivers: Array = []
	var entry := Vector2(300,110)
	var output := Vector2(610,140)
	if room in [28,30]:
		blocks.append(Rect2(180,250,120,20))
		entry = Vector2(220,270)
		faces.append(face(Vector2(180,270),Vector2(300,270),Vector2.DOWN))
		emitters.append({"p":Vector2(220,400),"d":Vector2.UP})
	elif room in [32,33,34,35]:
		blocks.append(Rect2(120,295,20,95))
		entry = Vector2(120,340)
		faces.append(face(Vector2(120,295),Vector2(120,390),Vector2.LEFT))
		emitters.append({"p":Vector2(25,340),"d":Vector2.RIGHT})
		if room != 34: blocks.append(Rect2(160,300,170,18))
	else:
		blocks.append(Rect2(300,30,18,190))
		faces.append(face(Vector2(300,30),Vector2(300,220),Vector2.LEFT))
		emitters.append({"p":Vector2(80,110),"d":Vector2.RIGHT})
		if room == 31: emitters.append({"p":Vector2(80,180),"d":Vector2.RIGHT})
	if room == 29:
		blocks.append(Rect2(490,180,140,20))
		output = Vector2(540,200)
		faces.append(face(Vector2(490,200),Vector2(630,200),Vector2.DOWN))
		receivers.append({"p":Vector2(540,320),"id":"A"})
	else:
		blocks.append(Rect2(610,60,18,160))
		faces.append(face(Vector2(610,60),Vector2(610,220),Vector2.LEFT))
		receivers.append({"p":Vector2(420,140),"id":"A"})
	if room in [27,31,33,34,35]: receivers.append({"p":Vector2(420,180),"id":"B"})
	var requires: Array = ["A","B"] if receivers.size()==2 else ["A"]
	var gates: Array = [{"rect":Rect2(800,0,18,landing_y),"requires":requires}]
	if room == 34: gates.append({"rect":Rect2(230,370,18,80),"requires":["A"]})
	var materials: Array = [{"a":Vector2(15,450),"b":Vector2(launch_x,450),"n":Vector2.UP,"kind":"boost"},{"a":Vector2(launch_x,450),"b":Vector2(launch_x+65,450),"n":Vector2.UP,"kind":"bounce"}]
	var guide: Array = [{"p":entry,"color":Color("ff685e"),"normal":Vector2.ZERO},{"p":output,"color":Color("4ba9ff"),"normal":Vector2.ZERO}]
	var briefing: Array = ["Redirect the amber beam through RED into BLUE to power the linked gate.","Run along RED coating, then touch BLUE coating to carry your speed across the spikes.","Hold D through the launch. R resets portals, power and the room."]
	if room in [27,31]: briefing[0] = "Power both amber sockets. Move BLUE between the two wall heights; room 31 also changes RED's source height."
	if room in [32,33,35]: briefing[0] = "Prepare RED on the low wall. The overhang hides BLUE's target: shoot it during your bounce."
	if room in [33,35]: briefing[2] = "During flight move BLUE between both socket heights. Both lamps must light before the gate."
	if room == 34: briefing[0] = "First BLUE height opens the runway gate. After passing it, move BLUE lower to power the exit gate."
	var data := {"name":titles[room-26],"spawn":Vector2(60,435),"goal":Rect2(908,landing_y-54,42,54),"blocks":blocks,"faces":faces,"enemy":false,"materials":materials,"emitters":emitters,"receivers":receivers,"gates":gates,"briefing":briefing,"hint":"Combine laser power, a red run and a blue rebound.","guide":guide}
	if room in [30,35]:
		data.spawn.x = 960-data.spawn.x
		data.goal.position.x = 960-data.goal.end.x
		for i in data.blocks.size(): data.blocks[i].position.x = 960-data.blocks[i].end.x
		for group in [data.faces,data.materials]:
			for surface in group:
				surface.a.x = 960-surface.a.x
				surface.b.x = 960-surface.b.x
				surface.n.x = -surface.n.x
		for emitter in data.emitters:
			emitter.p.x = 960-emitter.p.x
			emitter.d.x = -emitter.d.x
		for receiver in data.receivers: receiver.p.x = 960-receiver.p.x
		for gate in data.gates: gate.rect.position.x = 960-gate.rect.end.x
		for point in data.guide: point.p.x = 960-point.p.x
		data.briefing[1] = "This route runs LEFT: hold A along RED coating and into the BLUE rebound."
	return data
