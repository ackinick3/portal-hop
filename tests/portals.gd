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
			if not out.is_equal_approx(b * v.length()):
				failed += 1
			for sample in [Vector2.ZERO, -a * 0.01 + Vector2(-a.y,a.x) * 40, -a * 2000]:
				var redirected: Vector2 = script.transform_velocity(sample,a,b)
				if not redirected.is_equal_approx(b * sample.length()): failed += 1
	print("PORTAL_VECTOR_TEST_FAILURES=", failed)
	quit(0 if failed == 0 else 1)
