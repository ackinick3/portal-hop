extends RefCounted

static func face(a: Vector2, b: Vector2, n: Vector2) -> Dictionary:
	return {"a":a, "b":b, "n":n}

static func coating(a: Vector2, b: Vector2, kind: String) -> Dictionary:
	var patch := face(a, b, Vector2.UP)
	patch.kind = kind
	return patch

static func base(title: String, spawn: Vector2, goal: Rect2, blocks: Array, faces: Array = []) -> Dictionary:
	return {"name":title,"spawn":spawn,"goal":goal,"blocks":blocks,"faces":faces,"hint":"","enemy":false,"briefing":[],"guide":[]}

static func ceiling_room(title: String) -> Dictionary:
	var room := base(title,Vector2(100,385),Rect2(880,346,42,54),[
		Rect2(0,400,260,140),Rect2(560,400,400,140),Rect2(400,240,30,300),Rect2(0,40,960,20)],
		[face(Vector2(100,400),Vector2(240,400),Vector2.UP),face(Vector2(590,400),Vector2(740,400),Vector2.UP)])
	room.mirrors = [face(Vector2(20,60),Vector2(940,60),Vector2.DOWN)]
	room.briefing = ["Green reflects the gun. Aim at the green ceiling to reach the pale floor behind the barrier.","RED on your floor, BLUE on the hidden floor. Walk right into RED, then continue to the exit."]
	room.guide = [{"p":Vector2(370,60),"color":Color("63edbd"),"normal":Vector2.DOWN},{"p":Vector2(180,400),"color":Color("ff6377"),"normal":Vector2.UP}]
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
	room.briefing = ["RED on the central pale wall. Reflect BLUE from the green floor to the far pale wall.","The routed beam powers your platform. Ride it, then jump to the exit ledge."]
	room.guide = [{"p":Vector2(400,220),"color":Color("ff6377"),"normal":Vector2.LEFT},{"p":Vector2(340,floor_y),"color":Color("63edbd"),"normal":Vector2.UP}]
	return room

static func get_level(index: int) -> Dictionary:
	match index:
		35:
			return ceiling_room("THE GREEN DETOUR")
		36:
			var room := base("THE GEAR FERRY",Vector2(295,385),Rect2(890,346,42,54),[Rect2(0,400,230,140),Rect2(810,400,150,140)])
			room.movers = [{"rect":Rect2(240,400,110,20),"to":Vector2(690,400),"speed":90.0}]
			room.briefing = ["The geared platform carries you across the wide gap. Stand still and ride.","Near the far dock, hold D and jump across. R restores the platform to its starting rail stop."]
			return room
		37:
			return powered_room("LIGHT THE TRACK")
		38:
			var room := ceiling_room("BEHIND THE LIFT")
			room.blocks[1] = Rect2(560,400,210,140)
			room.blocks.append(Rect2(890,200,70,20))
			room.movers = [{"rect":Rect2(780,400,100,20),"to":Vector2(780,200),"speed":65.0}]
			room.goal = Rect2(905,146,42,54)
			room.briefing = ["Reflect BLUE off the ceiling to reach the hidden right floor; RED stays on your floor.","After the portal, wait for the elevator to come down. Jump aboard, ride up, then jump right."]
			return room
		39:
			var room := base("RUNWAY TO THE LIFT",Vector2(60,405),Rect2(900,226,42,54),[Rect2(0,420,350,120),Rect2(600,500,150,40),Rect2(880,280,80,20)])
			room.materials = [coating(Vector2(80,420),Vector2(350,420),"boost")]
			room.movers = [{"rect":Rect2(760,500,110,20),"to":Vector2(760,260),"speed":65.0}]
			room.briefing = ["Hold D across the red runway. Run off the edge to the lower island; do not brake in the gap.","Wait for the elevator low, jump aboard and ride up. Jump right to the exit."]
			return room
		40:
			var room := base("THE UPPER BRIDGE",Vector2(155,435),Rect2(875,166,42,54),[Rect2(0,220,90,20),Rect2(800,220,160,20)],
				[face(Vector2(0,220),Vector2(90,220),Vector2.UP),face(Vector2(810,220),Vector2(950,220),Vector2.UP)])
			room.movers = [{"rect":Rect2(100,450,110,20),"to":Vector2(100,220),"speed":70.0}]
			room.briefing = ["Ride the elevator up, then jump left onto the small upper dock.","From the dock, place BLUE on the far pale floor and RED under yourself. Walk through RED."]
			return room
		41:
			var room := ceiling_room("MINT SKYLINE")
			room.blocks.append(Rect2(845,240,115,20))
			room.materials = [coating(Vector2(710,400),Vector2(840,400),"bounce")]
			room.goal = Rect2(885,186,42,54)
			room.briefing = ["Use the ceiling reflection and the two pale floors to cross the central barrier.","Walk right onto blue coating. Its automatic rebound reaches the high exit ledge."]
			return room
		42:
			return powered_room("THE LIGHT ELEVATOR",true)
		43:
			var room := base("THE RETURN RAIL",Vector2(750,385),Rect2(20,346,42,54),[Rect2(0,480,960,60),Rect2(540,80,20,270),Rect2(40,60,20,290),Rect2(0,400,90,140)],
				[face(Vector2(560,120),Vector2(560,320),Vector2.RIGHT),face(Vector2(60,100),Vector2(60,320),Vector2.RIGHT)])
			room.mirrors = [face(Vector2(0,480),Vector2(960,480),Vector2.UP)]
			room.emitters = [{"p":Vector2(780,220),"d":Vector2.LEFT}]
			room.receivers = [{"p":Vector2(210,200),"id":1}]
			room.gates = [{"rect":Rect2(75,300,16,100),"requires":[1]}]
			room.movers = [{"rect":Rect2(750,400,110,20),"to":Vector2(100,400),"speed":95.0,"requires":[1]}]
			room.briefing = ["RED on the central wall. Reflect BLUE from the green floor onto the far LEFT pale wall.","The beam opens the dock and powers a leftward ferry. Ride, then jump left into the exit."]
			return room
		44:
			var room := base("BOUNCE TO THE FERRY",Vector2(60,465),Rect2(900,266,42,54),[Rect2(0,480,300,60),Rect2(340,320,180,20),Rect2(890,320,70,20)])
			room.materials = [coating(Vector2(210,480),Vector2(290,480),"bounce")]
			room.movers = [{"rect":Rect2(520,320,110,20),"to":Vector2(780,320),"speed":70.0}]
			room.briefing = ["Run right onto the blue patch; its rebound reaches the middle dock.","Wait for the ferry at the dock, jump aboard and ride it right. Jump again near the exit."]
			return room
		45:
			var room := ceiling_room("THE REFLECTED RUNWAY")
			room.blocks[1] = Rect2(480,400,210,140)
			room.blocks.append(Rect2(900,400,60,140))
			room.faces[1] = face(Vector2(500,400),Vector2(650,400),Vector2.UP)
			room.materials = [coating(Vector2(590,400),Vector2(690,400),"boost")]
			room.goal = Rect2(915,346,38,54)
			room.briefing = ["Reflect BLUE from the ceiling onto the middle pale floor. Place RED on the starting floor.","After crossing, keep D held over the red runway. Jump near its end to clear the final wide gap."]
			return room
		46:
			var room := powered_room("SWITCH THE SIGNAL")
			room.faces.append(face(Vector2(800,400),Vector2(890,400),Vector2.UP))
			room.blocks[3] = Rect2(800,400,160,140)
			room.receivers.append({"p":Vector2(845,160),"id":2})
			room.gates = [{"rect":Rect2(900,270,18,130),"requires":[2]}]
			room.movers[0].to = Vector2(680,400)
			room.goal = Rect2(925,346,30,54)
			room.briefing = ["First reflect BLUE to the far wall and route RED's beam into the first receiver.","Then move BLUE to the far pale floor below the second receiver. Both signals stay latched.","Ride the powered ferry, jump to the far dock, and pass the now-open gate."]
			return room
		47:
			var room := powered_room("TWO GREEN HORIZONS",true)
			room.blocks.append(Rect2(0,20,960,20))
			room.blocks.append(Rect2(800,200,100,20))
			room.receivers[0].p = Vector2(750,280)
			room.faces.append(face(Vector2(0,200),Vector2(90,200),Vector2.UP))
			room.faces.append(face(Vector2(810,200),Vector2(890,200),Vector2.UP))
			room.mirrors.append(face(Vector2(20,40),Vector2(940,40),Vector2.DOWN))
			room.goal = Rect2(835,146,42,54)
			room.briefing = ["Reflect off the FLOOR to route the laser and power the elevator. Ride up and jump left.","From the upper dock reflect BLUE off the CEILING to the far upper pale floor.","Replace RED on your upper floor and walk through. Two different mirrors solve two different heights."]
			return room
		48:
			var room := ceiling_room("THE DOUBLE BANK")
			room.blocks[1] = Rect2(560,400,340,140)
			room.blocks.append(Rect2(900,60,20,320))
			room.blocks.append(Rect2(820,240,40,20))
			room.mirrors.append(face(Vector2(900,60),Vector2(900,380),Vector2.LEFT))
			room.materials = [coating(Vector2(660,400),Vector2(740,400),"bounce")]
			room.goal = Rect2(824,186,28,54)
			room.briefing = ["Bank BLUE off the green ceiling AND the green right wall to the hidden pale floor.","Use RED on your floor to cross. Walk onto blue coating and ride its rebound to the high exit."]
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
			room.briefing = ["Reflect BLUE from the green floor to the far wall at mid-height; RED routes the laser.","Move BLUE lower on that wall to latch the second receiver. Ride the ferry and jump right onto blue.","Rebound left to the upper red runway. Hold A and jump off its left end to the final exit."]
			return room
	return {}
