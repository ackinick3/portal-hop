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
