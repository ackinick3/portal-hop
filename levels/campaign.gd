extends RefCounted

static func face(a: Vector2,b: Vector2,n: Vector2) -> Dictionary:
	return {"a":a,"b":b,"n":n}
static func get_level(index: int) -> Dictionary:
	if index == 8:
		return {"name":"APEX RELAY","spawn":Vector2(169,175),"goal":Rect2(908,246,42,54),"blocks":[Rect2(50,190,120,18),Rect2(180,470,110,18),Rect2(315,430,100,18),Rect2(525,430,100,18),Rect2(725,430,100,18),Rect2(435,300,18,240),Rect2(645,300,18,240),Rect2(860,300,100,240)],"faces":[face(Vector2(180,470),Vector2(290,470),Vector2.UP),face(Vector2(315,430),Vector2(415,430),Vector2.UP),face(Vector2(525,430),Vector2(625,430),Vector2.UP),face(Vector2(725,430),Vector2(825,430),Vector2.UP)],"enemy":false}
	if index == 33:
		return {"name":"TWO STAGE RUN","spawn":Vector2(60,435),"goal":Rect2(908,301,42,54),"blocks":[Rect2(0,450,420,90),Rect2(770,355,190,185),Rect2(120,295,20,95),Rect2(610,60,18,160)],"faces":[face(Vector2(120,295),Vector2(120,390),Vector2.LEFT),face(Vector2(610,60),Vector2(610,220),Vector2.LEFT)],"enemy":false,"materials":[{"a":Vector2(15,450),"b":Vector2(330,450),"n":Vector2.UP,"kind":"boost"},{"a":Vector2(330,450),"b":Vector2(395,450),"n":Vector2.UP,"kind":"bounce"}],"emitters":[{"p":Vector2(25,340),"d":Vector2.RIGHT}],"receivers":[{"p":Vector2(420,140),"id":"A"},{"p":Vector2(420,180),"id":"B"}],"gates":[{"rect":Rect2(800,0,18,355),"requires":["A","B"]},{"rect":Rect2(230,370,18,80),"requires":["A"]}]}
	return {}
