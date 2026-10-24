extends RefCounted

static func marker(point: Vector2, color: Color, text: String, normal: Vector2 = Vector2.ZERO) -> Dictionary:
	return {"p":point, "color":color, "text":text, "normal":normal}

static func guidance(level: int, doors: Array[Dictionary], transfers: int, position: Vector2) -> Dictionary:
	var red := Color("ff685e")
	var blue := Color("4ba9ff")
	if level == 6:
		if transfers >= 2:
			return {"text":"Ride the upward launch. Once above the goal ledge, steer RIGHT and land. R retries.", "markers":[]}
		if transfers == 1:
			if doors[0].is_empty() or doors[0].n != Vector2.LEFT:
				return {"text":"First airborne shot: move RED to the far wall ahead.", "markers":[marker(Vector2(780,430),red,"RED AHEAD",Vector2.LEFT)]}
			if doors[1].is_empty() or doors[1].n != Vector2.UP:
				return {"text":"Second airborne shot: move BLUE to the floor revealed past the baffle.", "markers":[marker(Vector2(300,300),blue,"BLUE REVEALED",Vector2.UP)]}
			return {"text":"Both shots ready. Keep your launch speed and enter the wall RED.", "markers":[marker(doors[0].p,red,"TURN UP",Vector2.LEFT)]}
		if doors[1].is_empty():
			return {"text":"Place BLUE on the left wall before leaving the starting ledge.", "markers":[marker(Vector2(180,170),blue,"BLUE WALL",Vector2.RIGHT)]}
		if doors[0].is_empty():
			return {"text":"Walk RIGHT off the starting ledge, place RED below, brake with A and release.", "markers":[marker(Vector2(530,480),red,"RED BELOW",Vector2.UP)]}
		return {"text":"Fall through RED. During flight replace RED ahead, then BLUE on the hidden floor.", "markers":[marker(doors[0].p,red,"FIRST FALL",Vector2.UP)]}
	if level == 5:
		if transfers >= 2:
			return {"text":"Second launch! Steer toward the far exit. R retries immediately.", "markers":[]}
		if transfers == 1:
			if doors[1].is_empty() or doors[1].n != Vector2.RIGHT:
				return {"text":"You can shoot in midair: move BLUE to the left wall now. Keep RED on the floor.", "markers":[marker(Vector2(120,100),blue,"BLUE IN MIDAIR",Vector2.RIGHT)]}
			return {"text":"Keep falling into the same RED floor portal for the second, faster launch.", "markers":[marker(doors[0].p,red,"SECOND FALL",Vector2.UP)]}
		if doors[1].is_empty():
			return {"text":"Place BLUE on the ceiling first. The second fall will add speed.", "markers":[marker(Vector2(465,60),blue,"BLUE CEILING",Vector2.DOWN)]}
		if doors[0].is_empty():
			return {"text":"Walk LEFT off the starting ledge, then place RED on the floor and brake over it.", "markers":[marker(Vector2(465,480),red,"RED BELOW",Vector2.UP)]}
		return {"text":"Fall through RED. After exiting the ceiling, shoot BLUE at the left wall while airborne.", "markers":[marker(doors[0].p,red,"FIRST FALL",Vector2.UP)]}
	if level == 4:
		if transfers > 0:
			return {"text":"Steer LEFT to descend onto the guard, then steer RIGHT after the bounce. Or land beyond it and jump to the exit.", "markers":[]}
		if doors[1].is_empty():
			return {"text":"Place BLUE high on the left wall to clear the starting ledge.", "markers":[marker(Vector2(120,90),blue,"BLUE HIGH",Vector2.RIGHT)]}
		if doors[0].is_empty():
			return {"text":"Leave the ledge to the RIGHT, then place RED on the floor below. Brake over the opening.", "markers":[marker(Vector2(440,470),red,"RED BELOW",Vector2.UP)]}
		return {"text":"Fall into RED for the launch. R retries and restores the guard.", "markers":[marker(doors[0].p,red,"FALL IN",Vector2.UP)]}
	if level == 3:
		if transfers > 0:
			return {"text":"TURN COMPLETE! Steer LEFT to land on the raised platform, then walk to the green exit. Missed it? R retries.", "markers":[]}
		if doors[1].is_empty():
			return {"text":"1 / 3   RMB: place BLUE on the upper right floor. Optional: try the ceiling for a different exit direction.", "markers":[marker(Vector2(830,300),blue,"BLUE FLOOR",Vector2.UP)]}
		if doors[0].is_empty():
			return {"text":"2 / 3   Walk off the RIGHT ledge. Once clear, LMB the pale WALL near the red marker; keep moving right.", "markers":[marker(Vector2(310,300),red,"RED WALL",Vector2.LEFT)]}
		return {"text":"3 / 3   Fall into the wall while holding D. Your fall becomes sideways motion. After exiting, steer LEFT onto the goal ledge.", "markers":[marker(doors[0].p,red,"FALL + RUN",Vector2.LEFT)]}
	if level == 0:
		if transfers > 0:
			return {"text":"CROSSING COMPLETE! Steer onto the right bank, then walk to the green exit.", "markers":[]}
		if doors[0].is_empty():
			return {"text":"1 / 3   LMB: place RED on the pale floor nearby. Markers are suggestions; aim freely.", "markers":[marker(Vector2(300,380),red,"RED")]}
		if doors[1].is_empty():
			return {"text":"2 / 3   RMB: place BLUE on the pale floor across the pit. Both portals must be placed.", "markers":[marker(Vector2(720,380),blue,"BLUE")]}
		return {"text":"3 / 3   Jump into the nearby portal. After crossing, hold D to land away from the opening.", "markers":[]}
	if level == 1:
		if transfers > 0:
			return {"text":"LAUNCH! Keep moving right. Land on the far bank and reach the green exit.", "markers":[]}
		if doors[1].is_empty():
			return {"text":"1 / 4   RMB: aim at the UPPER left wall. A high exit clears the starting platform.", "markers":[marker(Vector2(180,90),blue,"BLUE HIGH")]}
		if doors[0].is_empty():
			return {"text":"2 / 4   Walk off the RIGHT ledge. Once clear, LMB the pale floor below; the ledge blocks earlier shots.", "markers":[marker(Vector2(465,470),red,"RED BELOW")]}
		return {"text":"3 / 4   Fall into RED. Tap A to brake above it, then release movement. Fall speed becomes launch speed.", "markers":[marker(doors[0].p,red,"FALL IN")]}
	if transfers > 0:
		return {"text":"AIR DROP! Aim your feet at the guard to stomp; side contact is fatal. Then jump the small gap.", "markers":[]}
	if doors[1].is_empty():
		var text := "GROUND: jump over or onto the guard. PORTAL route: from this high ledge, RMB the ceiling first."
		if position.y > 380:
			text = "GROUND route: jump onto or past the guard, then jump the gap. R retries; ceiling setup is easiest on the high ledge."
		return {"text":text, "markers":[marker(Vector2(510,197),blue,"AIR DROP")]}
	if doors[0].is_empty():
		return {"text":"Ceiling ready. Step off the LEFT side of the high ledge; from the lower floor, LMB the pale ground.", "markers":[marker(Vector2(200,430),red,"RED BELOW")]}
	return {"text":"Walk into the floor portal for an approach from above. Or use the ground route: jump onto or past the guard.", "markers":[]}
