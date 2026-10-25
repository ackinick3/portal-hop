extends RefCounted

static func face(a: Vector2, b: Vector2, n: Vector2) -> Dictionary:
	return {"a":a,"b":b,"n":n}
static func coating(a: Vector2, b: Vector2, n: Vector2, kind: String) -> Dictionary:
	return {"a":a,"b":b,"n":n,"kind":kind}

static func get_level(index: int) -> Dictionary:
	var data := {"name":"","spawn":Vector2.ZERO,"goal":Rect2(),"blocks":[],"faces":[],"materials":[],"enemy":false}
	match index:
		9:
			data.merge({"name":"A SOFT LANDING","spawn":Vector2(100,365),"goal":Rect2(610,206,42,54),"blocks":[Rect2(0,380,330,160),Rect2(400,260,300,280)],"materials":[coating(Vector2(220,380),Vector2(330,380),Vector2.UP,"bounce")]},true)
		10:
			data.merge({"name":"THE REDLINE SLING","spawn":Vector2(100,385),"goal":Rect2(860,396,42,54),"blocks":[Rect2(0,400,450,140),Rect2(450,270,20,270),Rect2(20,0,20,210),Rect2(600,450,360,90)],"faces":[face(Vector2(40,20),Vector2(40,200),Vector2.RIGHT),face(Vector2(450,280),Vector2(450,460),Vector2.LEFT)],"materials":[coating(Vector2(0,400),Vector2(450,400),Vector2.UP,"boost")],"hazards":[Rect2(470,510,130,30)]},true)
		13:
			data.merge({"name":"SPRING TO SLING","spawn":Vector2(150,435),"goal":Rect2(850,306,42,54),"blocks":[Rect2(0,450,330,90),Rect2(400,480,160,60),Rect2(80,0,20,210),Rect2(580,360,380,180)],"faces":[face(Vector2(100,20),Vector2(100,200),Vector2.RIGHT),face(Vector2(410,480),Vector2(550,480),Vector2.UP)],"materials":[coating(Vector2(220,450),Vector2(330,450),Vector2.UP,"bounce")]},true)
		16:
			data.merge({"name":"RED TO SKY","spawn":Vector2(100,435),"goal":Rect2(885,226,42,54),"blocks":[Rect2(0,450,250,90),Rect2(434,480,130,60),Rect2(600,450,130,90),Rect2(800,280,160,260)],"faces":[face(Vector2(434,480),Vector2(560,480),Vector2.UP),face(Vector2(610,450),Vector2(720,450),Vector2.UP)],"materials":[coating(Vector2(0,450),Vector2(250,450),Vector2.UP,"boost")]},true)
		18:
			data.merge({"name":"CLIMB THEN SPRINT","spawn":Vector2(85,435),"goal":Rect2(875,276,42,54),"blocks":[Rect2(0,450,230,90),Rect2(300,330,300,210),Rect2(800,330,160,210)],"materials":[coating(Vector2(120,450),Vector2(230,450),Vector2.UP,"bounce"),coating(Vector2(300,330),Vector2(600,330),Vector2.UP,"boost")]},true)
		_: return {}
	return data
