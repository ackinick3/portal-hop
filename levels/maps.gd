extends RefCounted

const LEVEL_COUNT := 23
# Stable source IDs preserve legacy progress while displayed indices stay consecutive.
const ROOM_IDS := [1,2,3,4,5,6,7,8,9,10,11,14,17,19,20,21,25,34,36,37,38,48,50]

static func index_for_id(id: int) -> int:
	return ROOM_IDS.find(id)

static func get_level(index: int) -> Dictionary:
	if index < 0 or index >= LEVEL_COUNT: return {}
	return _get_original_level(ROOM_IDS[index]-1)

static func _get_original_level(index: int) -> Dictionary:
	match index:
		0:
			return {"name":"THE FIRST CROSSING", "spawn":Vector2(128,365), "goal":Rect2(860,326,42,54), "blocks":[Rect2(0,380,370,160),Rect2(610,380,350,160),Rect2(40,340,55,40),Rect2(0,300,40,80)], "faces":[face(Vector2(245,380),Vector2(350,380),Vector2.UP),face(Vector2(650,380),Vector2(800,380),Vector2.UP)],  "enemy":false}
		1:
			return {"name":"GRAVITY SLINGSHOT", "spawn":Vector2(330,130), "goal":Rect2(876,416,42,54), "blocks":[Rect2(0,470,520,70),Rect2(700,470,260,70),Rect2(255,145,140,18),Rect2(155,25,25,280)], "faces":[face(Vector2(405,470),Vector2(520,470),Vector2.UP),face(Vector2(180,35),Vector2(180,305),Vector2.RIGHT)],  "enemy":false}
		2:
			return {"name":"MECHANICAL GUARDIAN", "spawn":Vector2(140,335), "goal":Rect2(866,376,42,54), "blocks":[Rect2(0,430,670,110),Rect2(740,430,220,110),Rect2(80,350,125,18),Rect2(390,175,240,22)], "faces":[face(Vector2(105,430),Vector2(265,430),Vector2.UP),face(Vector2(390,197),Vector2(630,197),Vector2.DOWN)],  "enemy":true}
		3:
			return {"name":"THE VECTOR SWITCH", "spawn":Vector2(128,205), "goal":Rect2(560,231,42,54), "blocks":[Rect2(0,470,960,70),Rect2(60,220,140,18),Rect2(310,250,25,220),Rect2(750,300,170,20),Rect2(560,285,140,20),Rect2(360,140,240,20)], "faces":[face(Vector2(310,250),Vector2(310,390),Vector2.LEFT),face(Vector2(760,300),Vector2(900,300),Vector2.UP),face(Vector2(360,160),Vector2(600,160),Vector2.DOWN)],  "enemy":false}
		4:
			return {"name":"THE FINAL RELAY", "spawn":Vector2(260,130), "goal":Rect2(904,296,42,54), "blocks":[Rect2(0,470,490,70),Rect2(650,390,160,150),Rect2(865,350,95,190),Rect2(190,145,140,18),Rect2(95,25,25,280)], "faces":[face(Vector2(390,470),Vector2(490,470),Vector2.UP),face(Vector2(120,35),Vector2(120,305),Vector2.RIGHT)],  "enemy":true, "guard":{"spawn":Vector2(720,373),"low":680.0,"high":760.0}}
		5:
			return {"name":"AIRBORNE RELAY", "spawn":Vector2(665,115), "goal":Rect2(908,306,42,54), "blocks":[Rect2(0,480,560,60),Rect2(880,360,80,180),Rect2(600,130,140,18),Rect2(740,0,20,200),Rect2(390,25,160,35),Rect2(95,25,25,280)], "faces":[face(Vector2(420,480),Vector2(540,480),Vector2.UP),face(Vector2(390,60),Vector2(550,60),Vector2.DOWN),face(Vector2(120,35),Vector2(120,305),Vector2.RIGHT)],  "enemy":false}
		6:
			return {"name":"MIDAIR SWITCHBACK", "spawn":Vector2(420,65), "goal":Rect2(850,66,42,54), "blocks":[Rect2(0,510,960,30),Rect2(400,80,110,18),Rect2(155,25,25,280),Rect2(820,300,20,210),Rect2(620,420,100,18),Rect2(750,120,200,18),Rect2(600,0,18,140)], "faces":[face(Vector2(535,510),Vector2(690,510),Vector2.UP),face(Vector2(180,35),Vector2(180,305),Vector2.RIGHT),face(Vector2(820,340),Vector2(820,510),Vector2.LEFT),face(Vector2(620,420),Vector2(720,420),Vector2.UP)],  "enemy":false}
		7:
			return {"name":"THE HIGH ROAD", "spawn":Vector2(249,185), "goal":Rect2(866,346,42,54), "blocks":[Rect2(0,480,560,60),Rect2(70,200,180,18),Rect2(75,25,25,280),Rect2(620,350,30,190),Rect2(720,400,240,140)], "faces":[face(Vector2(385,480),Vector2(535,480),Vector2.UP),face(Vector2(100,35),Vector2(100,305),Vector2.RIGHT)],  "enemy":false}
	if index in [9,10,13,16,18]:
		return load("res://levels/coating_rooms.gd").get_level(index)
	if index in [19,20,24]:
		return load("res://levels/laser_rooms.gd").get_level(index)
	if index in [35,36,37,47,49]:
		return load("res://levels/advanced_rooms.gd").get_level(index)
	if index in [8,33]:
		return load("res://levels/campaign.gd").get_level(index)
	return {}

static func face(a: Vector2, b: Vector2, n: Vector2) -> Dictionary:
	return {"a":a,"b":b,"n":n}
