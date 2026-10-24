extends RefCounted

const LEVEL_COUNT := 5

static func get_level(index: int) -> Dictionary:
	match index:
		0:
			return {"name":"THE FIRST CROSSING", "spawn":Vector2(128,365), "goal":Rect2(860,326,42,54), "blocks":[Rect2(0,380,370,160),Rect2(610,380,350,160),Rect2(40,340,55,40),Rect2(0,300,40,80)], "faces":[face(Vector2(245,380),Vector2(350,380),Vector2.UP),face(Vector2(650,380),Vector2(800,380),Vector2.UP)], "hint":"LMB: RED / RMB: BLUE  |  Shoot both pale floors. Jump into red, steer out of blue.", "enemy":false}
		1:
			return {"name":"GRAVITY SLINGSHOT", "spawn":Vector2(330,130), "goal":Rect2(876,416,42,54), "blocks":[Rect2(0,470,520,70),Rect2(700,470,260,70),Rect2(255,145,140,18),Rect2(155,25,25,280)], "faces":[face(Vector2(405,470),Vector2(520,470),Vector2.UP),face(Vector2(180,35),Vector2(180,305),Vector2.RIGHT)], "hint":"BLUE: upper left wall. Step off the ledge, shoot RED below, brake over it.", "enemy":false}
		2:
			return {"name":"MECHANICAL GUARDIAN", "spawn":Vector2(140,335), "goal":Rect2(866,376,42,54), "blocks":[Rect2(0,430,670,110),Rect2(740,430,220,110),Rect2(80,350,125,18),Rect2(390,175,240,22)], "faces":[face(Vector2(105,430),Vector2(265,430),Vector2.UP),face(Vector2(390,197),Vector2(630,197),Vector2.DOWN)], "hint":"Land on the guard from ABOVE, or jump past. Optional: floor RED + ceiling BLUE.", "enemy":true}
		3:
			return {"name":"THE VECTOR SWITCH", "spawn":Vector2(128,205), "goal":Rect2(560,231,42,54), "blocks":[Rect2(0,470,960,70),Rect2(60,220,140,18),Rect2(310,250,25,220),Rect2(750,300,170,20),Rect2(560,285,140,20),Rect2(360,140,240,20)], "faces":[face(Vector2(310,250),Vector2(310,390),Vector2.LEFT),face(Vector2(760,300),Vector2(900,300),Vector2.UP),face(Vector2(360,160),Vector2(600,160),Vector2.DOWN)], "hint":"BLUE on the right floor, then step off the ledge and shoot RED on the wall. Steer left after the turn.", "enemy":false}
		4:
			return {"name":"THE FINAL RELAY", "spawn":Vector2(260,130), "goal":Rect2(904,296,42,54), "blocks":[Rect2(0,470,490,70),Rect2(650,390,160,150),Rect2(865,350,95,190),Rect2(190,145,140,18),Rect2(95,25,25,280)], "faces":[face(Vector2(390,470),Vector2(490,470),Vector2.UP),face(Vector2(120,35),Vector2(120,305),Vector2.RIGHT)], "hint":"Launch from the left wall. Land above the guard, then bounce or jump across the last gap.", "enemy":true, "guard":{"spawn":Vector2(720,373),"low":680.0,"high":760.0}}
	return {}

static func face(a: Vector2, b: Vector2, n: Vector2) -> Dictionary:
	return {"a":a,"b":b,"n":n}


