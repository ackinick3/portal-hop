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
