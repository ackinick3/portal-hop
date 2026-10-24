extends SceneTree
var failed := 0
func _initialize() -> void:
	var script = load("res://portals/system.gd")
	if script == null:
		quit(1)
		return
	var normals := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for a in normals:
		for b in normals:
			var v: Vector2 = -a * 765 + Vector2(-a.y, a.x) * 123
			var out: Vector2 = script.transform_velocity(v, a, b)
			if absf(out.length() - v.length()) > 0.01 or absf(out.dot(b) - 765) > 0.01:
				failed += 1
	print("PORTAL_VECTOR_TEST_FAILURES=", failed)
	quit(0 if failed == 0 else 1)
