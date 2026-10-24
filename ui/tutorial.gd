extends RefCounted

static func marker(point: Vector2, color: Color, text: String) -> Dictionary:
	return {"p":point, "color":color, "text":text}

static func guidance(level: int, doors: Array[Dictionary], transfers: int, position: Vector2) -> Dictionary:
	var red := Color("ff685e")
	var blue := Color("4ba9ff")
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
