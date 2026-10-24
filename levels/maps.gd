extends RefCounted

static func get_level(index: int) -> Dictionary:
	match index:
		0:
			return {"name":"THE FIRST CROSSING", "spawn":Vector2(128,365), "goal":Rect2(860,326,42,54), "blocks":[Rect2(0,380,370,160),Rect2(610,380,350,160),Rect2(40,340,55,40),Rect2(0,300,40,80)], "faces":[face(Vector2(245,380),Vector2(350,380),Vector2.UP),face(Vector2(650,380),Vector2(800,380),Vector2.UP)], "hint":"LMB: RED / RMB: BLUE  |  Shoot both pale floors. Jump into red, steer out of blue.", "enemy":false}
		1:
			return {"name":"GRAVITY SLINGSHOT", "spawn":Vector2(330,130), "goal":Rect2(876,416,42,54), "blocks":[Rect2(0,470,520,70),Rect2(700,470,260,70),Rect2(255,145,140,18),Rect2(155,25,25,280)], "faces":[face(Vector2(405,470),Vector2(520,470),Vector2.UP),face(Vector2(180,35),Vector2(180,305),Vector2.RIGHT)], "hint":"BLUE: upper left wall. Step off the ledge, shoot RED below, brake over it.", "enemy":false}
		_:
			return {"name":"MECHANICAL GUARDIAN", "spawn":Vector2(140,335), "goal":Rect2(866,376,42,54), "blocks":[Rect2(0,430,670,110),Rect2(740,430,220,110),Rect2(80,350,125,18),Rect2(390,175,240,22)], "faces":[face(Vector2(105,430),Vector2(265,430),Vector2.UP),face(Vector2(390,197),Vector2(630,197),Vector2.DOWN)], "hint":"Land on the guard from ABOVE, or jump past. Optional: floor RED + ceiling BLUE.", "enemy":true}

static func face(a: Vector2, b: Vector2, n: Vector2) -> Dictionary:
	return {"a":a,"b":b,"n":n}


