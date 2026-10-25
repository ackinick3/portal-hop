extends RefCounted

# Approved editor sketch 01; centers and thickness follow adjusted.json.
static func strip(a: Vector2,b: Vector2) -> PackedVector2Array:
	var edge := b-a
	var n := Vector2(edge.y,-edge.x).normalized()*10
	return PackedVector2Array([a+n,b+n,b-n,a-n])

static func fall_bounce() -> Dictionary:
	var blue_a := Vector2(220,295)
	var blue_b := Vector2(300,420)
	var blue_n := Vector2(125,-80).normalized()
	var white_a := Vector2(610,410)
	var white_b := Vector2(660,230)
	var white_n := Vector2(-180,-50).normalized()
	return {
		"name":"THE FALLING RETURN", "spawn":Vector2(131,185), "goal":Rect2(793,146,42,54), "enemy":true,
		"guard":{"spawn":Vector2(542,208.5),"low":54.0,"high":363.0,"vertical":true},
		"blocks":[Rect2(70,200,160,20),Rect2(210,210,20,85),Rect2(290,420,20,90),Rect2(300,500,60,20),Rect2(360,500,120,20),Rect2(480,500,130,20),Rect2(600,410,20,100),Rect2(650,210,20,20),Rect2(650,200,250,20)],
		"polygons":[strip(blue_a,blue_b),strip(white_a,white_b)],
		"faces":[{"a":Vector2(360,500),"b":Vector2(480,500),"n":Vector2.UP},{"a":white_a+white_n*10,"b":white_b+white_n*10,"n":white_n}],
		"materials":[{"a":blue_a+blue_n*10,"b":blue_b+blue_n*10,"n":blue_n,"kind":"bounce"}]
	}

static func second_ascent() -> Dictionary:
	var a := Vector2(175,150)
	var b := Vector2(278,258)
	var n := Vector2(108,-103).normalized()
	return {
		"name":"THE SECOND ASCENT", "spawn":Vector2(118,125), "goal":Rect2(872,26,42,54), "enemy":false,
		"blocks":[Rect2(56,140,134,20),Rect2(0,80,256,20),Rect2(268,248,20,162),Rect2(278,400,622,20),Rect2(680,80,250,20)],
		"polygons":[strip(a,b)],
		"faces":[{"a":a+n*10,"b":b+n*10,"n":n},{"a":Vector2(288,258),"b":Vector2(288,400),"n":Vector2.RIGHT},{"a":Vector2(288,400),"b":Vector2(900,400),"n":Vector2.UP}]
	}

static func crimson_arc() -> Dictionary:
	var red_a := Vector2(340,440)
	var red_b := Vector2(440,410)
	var red_n := Vector2(-30,-100).normalized()
	var in_a := Vector2(680,440)
	var in_b := Vector2(810,380)
	var in_n := Vector2(-60,-130).normalized()
	var out_a := Vector2(40,201)
	var out_b := Vector2(134,262)
	var out_n := Vector2(61,-94).normalized()
	return {
		"name":"THE CRIMSON ARC", "spawn":Vector2(89,415), "goal":Rect2(758,46,42,54), "enemy":false,
		"blocks":[Rect2(38,430,102,20),Rect2(140,430,200,20),Rect2(430,410,20,40),Rect2(30,201,20,249),Rect2(400,250,150,20),Rect2(800,100,20,290),Rect2(650,100,170,20)],
		"polygons":[strip(red_a,red_b),strip(in_a,in_b),strip(out_a,out_b)],
		"faces":[{"a":Vector2(38,430),"b":Vector2(140,430),"n":Vector2.UP},{"a":Vector2(50,201),"b":Vector2(50,430),"n":Vector2.RIGHT},{"a":in_a+in_n*10,"b":in_b+in_n*10,"n":in_n},{"a":Vector2(800,110),"b":Vector2(800,380),"n":Vector2.LEFT},{"a":out_a+out_n*10,"b":out_b+out_n*10,"n":out_n}],
		"materials":[{"a":Vector2(140,430),"b":Vector2(340,430),"n":Vector2.UP,"kind":"boost"},{"a":red_a+red_n*10,"b":red_b+red_n*10,"n":red_n,"kind":"boost"},{"a":Vector2(400,250),"b":Vector2(550,250),"n":Vector2.UP,"kind":"bounce"}],
		"hazards":[Rect2(450,428,220,22)]
	}

static func wandering_finish() -> Dictionary:
	var a := Vector2(810,220)
	var b := Vector2(885,145)
	var n := Vector2(-1,-1).normalized()
	return {
		"name":"THE WANDERING FINISH", "spawn":Vector2(58,95), "goal":Rect2(365.5,36,42,54), "enemy":true,
		"goal_mover":0,"goal_offset":Vector2(75.5,-54),
		"guard":{"spawn":Vector2(385,265.5),"low":133.0,"high":398.0,"vertical":true},
		"blocks":[Rect2(0,110,114,20),Rect2(104,128,20,217),Rect2(114,335,134,20),Rect2(238,335,20,113),Rect2(490,350,20,98),Rect2(500,350,310,20),Rect2(800,220,20,140)],
		"polygons":[strip(a,b)],
		"faces":[{"a":Vector2(124,128),"b":Vector2(124,335),"n":Vector2.RIGHT},{"a":Vector2(124,335),"b":Vector2(238,335),"n":Vector2.UP},{"a":Vector2(800,220),"b":Vector2(800,350),"n":Vector2.LEFT},{"a":a+n*10,"b":b+n*10,"n":n}],
		"materials":[{"a":Vector2(500,350),"b":Vector2(800,350),"n":Vector2.UP,"kind":"boost"}],
		"hazards":[Rect2(258,426,232,22)],
		"gun_screens":[{"a":Vector2(575,0),"b":Vector2(575,330)}],
		"movers":[{"rect":Rect2(290,90,180,20),"to":Vector2(760,90),"speed":50.0}]
	}

static func kinetic_chamber() -> Dictionary:
	return {
		"name":"THE KINETIC CHAMBER", "spawn":Vector2(488,495), "goal":Rect2(152,116,42,54), "enemy":true,
		"goal_mover":0,"goal_offset":Vector2(32,-54),
		"blocks":[Rect2(20,20,920,20),Rect2(20,20,20,510),Rect2(920,20,20,510),Rect2(20,510,920,20)],
		"faces":[{"a":Vector2(40,40),"b":Vector2(920,40),"n":Vector2.DOWN},{"a":Vector2(40,40),"b":Vector2(40,510),"n":Vector2.RIGHT},{"a":Vector2(920,40),"b":Vector2(920,510),"n":Vector2.LEFT},{"a":Vector2(40,510),"b":Vector2(920,510),"n":Vector2.UP}],
		"guards":[
			{"spawn":Vector2(480,272.5),"patrol":PackedVector2Array([Vector2(72,72),Vector2(888,473)])},
			{"spawn":Vector2(480,275),"patrol":PackedVector2Array([Vector2(72,478),Vector2(888,72)])},
			{"spawn":Vector2(269,275),"patrol":PackedVector2Array([Vector2(164,72),Vector2(374,478)])},
			{"spawn":Vector2(632.5,275),"patrol":PackedVector2Array([Vector2(495,72),Vector2(770,478)])},
			{"spawn":Vector2(485,144.5),"patrol":PackedVector2Array([Vector2(115,140),Vector2(855,149)])},
			{"spawn":Vector2(484,388.5),"patrol":PackedVector2Array([Vector2(80,383),Vector2(888,394)])}
		],
		"movers":[
			{"rect":Rect2(120,170,120,20),"to":Vector2(120,170),"speed":60.0,"path":PackedVector2Array([Vector2(120,170),Vector2(670,360),Vector2(670,165),Vector2(110,350),Vector2(120,170)])},
			{"rect":Rect2(151,367,148,12),"to":Vector2(42,367),"speed":75.0,"path":PackedVector2Array([Vector2(151,367),Vector2(744,367),Vector2(42,367)])}
		],
		"moving_hazards":[{"mover":1,"rect":Rect2(0,-22,148,22)}]
	}
