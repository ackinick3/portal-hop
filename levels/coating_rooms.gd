extends RefCounted

static func face(a: Vector2, b: Vector2, n: Vector2) -> Dictionary:
	return {"a":a,"b":b,"n":n}
static func coating(a: Vector2, b: Vector2, n: Vector2, kind: String) -> Dictionary:
	return {"a":a,"b":b,"n":n,"kind":kind}

static func get_level(index: int) -> Dictionary:
	var data := {"name":"","spawn":Vector2.ZERO,"goal":Rect2(),"blocks":[],"faces":[],"materials":[],"hint":"","enemy":false}
	match index:
		9:
			data.merge({"name":"A SOFT LANDING","spawn":Vector2(100,365),"goal":Rect2(610,206,42,54),"blocks":[Rect2(0,380,330,160),Rect2(400,260,300,280)],"materials":[coating(Vector2(220,380),Vector2(330,380),Vector2.UP,"bounce")],"briefing":["BLUE COATING BOUNCES AUTOMATICALLY","Walk right onto the blue strip.","Keep holding D to land on the higher island.","No jump or portal is needed. R retries."]},true)
		10:
			data.merge({"name":"THE REDLINE SLING","spawn":Vector2(100,385),"goal":Rect2(860,396,42,54),"blocks":[Rect2(0,400,450,140),Rect2(450,270,20,270),Rect2(20,0,20,210),Rect2(600,450,360,90)],"faces":[face(Vector2(40,20),Vector2(40,200),Vector2.RIGHT),face(Vector2(450,280),Vector2(450,460),Vector2.LEFT)],"materials":[coating(Vector2(0,400),Vector2(450,400),Vector2.UP,"boost")],"hazards":[Rect2(470,510,130,30)],"briefing":["RED COATING BUILDS RUNNING SPEED","BLUE portal: high left wall. RED: right wall.","Hold D along the red runway and through the portal.","The fast exit clears the wall and spike ditch.","Release movement to brake on red. R resets."]},true)
		11:
			data.merge({"name":"BOUNCE STAIRCASE","spawn":Vector2(85,365),"goal":Rect2(670,126,42,54),"blocks":[Rect2(0,380,220,160),Rect2(310,300,140,240),Rect2(560,180,230,360)],"materials":[coating(Vector2(120,380),Vector2(220,380),Vector2.UP,"bounce"),coating(Vector2(310,300),Vector2(450,300),Vector2.UP,"bounce")],"briefing":["TWO BLUE STEPS","Hold D onto the first blue strip.","Land on the second strip to rebound again.","Keep right to reach the upper exit."]},true)
		12:
			data.merge({"name":"THE RETURN WALL","spawn":Vector2(700,70),"goal":Rect2(440,366,42,54),"blocks":[Rect2(660,85,100,18),Rect2(830,0,20,540),Rect2(400,420,250,120)],"materials":[coating(Vector2(830,20),Vector2(830,500),Vector2.LEFT,"bounce")],"briefing":["BLUE WALLS REVERSE YOUR IMPACT","Walk right from the starting ledge.","The coated wall sends you back left.","After impact hold A toward the lower island.","The return keeps your falling speed. R retries."]},true)
		13:
			data.merge({"name":"SPRING TO SLING","spawn":Vector2(150,435),"goal":Rect2(850,306,42,54),"blocks":[Rect2(0,450,330,90),Rect2(400,480,160,60),Rect2(80,0,20,210),Rect2(580,360,380,180)],"faces":[face(Vector2(100,20),Vector2(100,200),Vector2.RIGHT),face(Vector2(410,480),Vector2(550,480),Vector2.UP)],"materials":[coating(Vector2(220,450),Vector2(330,450),Vector2.UP,"bounce")],"briefing":["A BOUNCE CAN PREPARE A LONG FALL","BLUE portal: high left wall. Walk right.","After bouncing past the ledge, shoot RED below.","Aim near the right edge of the pale lower floor.","Keep D through the floor entry and wall exit."]},true)
		14:
			data.merge({"name":"RUNNING BROAD JUMP","spawn":Vector2(100,385),"goal":Rect2(870,346,42,54),"blocks":[Rect2(0,400,400,140),Rect2(700,400,260,140)],"materials":[coating(Vector2(0,400),Vector2(400,400),Vector2.UP,"boost")],"briefing":["BUILD SPEED BEFORE THE EDGE","Hold D along the red runway.","Jump near its right edge and keep holding D.","The long gap needs a running jump. R retries."]},true)
		15:
			data.merge({"name":"LOW ROOF RUNUP","spawn":Vector2(80,435),"goal":Rect2(875,356,42,54),"blocks":[Rect2(0,450,500,90),Rect2(160,320,260,70),Rect2(650,410,310,130)],"materials":[coating(Vector2(0,450),Vector2(500,450),Vector2.UP,"boost")],"briefing":["WAIT UNTIL YOU CLEAR THE ROOF","Run right beneath the low ceiling.","Once outside, jump before the runway ends.","Keep D to land on the slightly higher island.","An early jump hits the roof. R retries."]},true)
		16:
			data.merge({"name":"RED TO SKY","spawn":Vector2(100,435),"goal":Rect2(885,226,42,54),"blocks":[Rect2(0,450,250,90),Rect2(434,480,130,60),Rect2(600,450,130,90),Rect2(800,280,160,260)],"faces":[face(Vector2(434,480),Vector2(560,480),Vector2.UP),face(Vector2(610,450),Vector2(720,450),Vector2.UP)],"materials":[coating(Vector2(0,450),Vector2(250,450),Vector2.UP,"boost")],"briefing":["TURN RUNWAY SPEED INTO HEIGHT","BLUE portal: far right lower floor.","Run right; off the ledge, shoot RED on the middle floor.","Keep D after the upward exit to reach the high island.","The far shot opens as you approach. R retries."]},true)
		17:
			data.merge({"name":"FAST SPRING CROSSING","spawn":Vector2(60,435),"goal":Rect2(875,396,42,54),"blocks":[Rect2(0,450,260,90),Rect2(700,450,260,90)],"materials":[coating(Vector2(0,450),Vector2(180,450),Vector2.UP,"boost"),coating(Vector2(180,450),Vector2(260,450),Vector2.UP,"bounce")],"briefing":["RED SPEED, BLUE HEIGHT","Run right across the red strip.","Stay right as the blue edge rebounds you.","Keep the running speed across the wide gap.","Both coatings work together. R retries."]},true)
		18:
			data.merge({"name":"CLIMB THEN SPRINT","spawn":Vector2(85,435),"goal":Rect2(875,276,42,54),"blocks":[Rect2(0,450,230,90),Rect2(300,330,300,210),Rect2(800,330,160,210)],"materials":[coating(Vector2(120,450),Vector2(230,450),Vector2.UP,"bounce"),coating(Vector2(300,330),Vector2(600,330),Vector2.UP,"boost")],"briefing":["CLIMB BEFORE BUILDING SPEED","Hold D: blue lifts you onto the red runway.","Keep running right to build speed on that island.","Jump near its right side across the last gap.","A missed landing is a quick R retry."]},true)
		_: return {}
	if index == 10:
		data.guide = [{"p":Vector2(40,60),"color":Color("4ba9ff"),"normal":Vector2.RIGHT,"before":0},{"p":Vector2(450,364),"color":Color("ff6377"),"normal":Vector2.LEFT,"before":0}]
	elif index == 13:
		data.guide = [{"p":Vector2(100,60),"color":Color("4ba9ff"),"normal":Vector2.RIGHT,"before":0},{"p":Vector2(500,480),"color":Color("ff6377"),"normal":Vector2.UP,"before":0}]
	elif index == 16:
		data.guide = [{"p":Vector2(650,450),"color":Color("4ba9ff"),"normal":Vector2.UP,"before":0},{"p":Vector2(470,480),"color":Color("ff6377"),"normal":Vector2.UP,"before":0}]
	data.hint = " ".join(data.briefing)
	return data
