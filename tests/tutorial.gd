extends SceneTree

var failures := 0
func check(ok: bool, message: String) -> void:
	print("PASS: " if ok else "FAIL: ", message)
	if not ok: failures += 1

func _initialize() -> void:
	var tutorial = load("res://ui/tutorial.gd")
	if tutorial == null:
		quit(1)
		return
	var empty: Array[Dictionary] = [{}, {}]
	var blue: Array[Dictionary] = [{}, {"p":Vector2(180, 90), "n":Vector2.RIGHT}]
	var pair: Array[Dictionary] = [{"p":Vector2(465,470), "n":Vector2.UP}, blue[1]]
	check(tutorial.guidance(0, empty, 0, Vector2(128,365)).text.contains("LMB"), "First room teaches red shot first")
	check(tutorial.guidance(1, empty, 0, Vector2(330,130)).text.contains("RMB"), "Second room starts with upper wall portal")
	check(tutorial.guidance(1, blue, 0, Vector2(330,130)).text.contains("ledge"), "Second room explains floor shot is blocked until leaving ledge")
	check(tutorial.guidance(1, pair, 0, Vector2(465,200)).text.contains("brake"), "Second room explains braking above floor portal")
	check(tutorial.guidance(1, pair, 1, Vector2(740,200)).text.contains("green"), "After launch tutorial guides player to exit")
	check(tutorial.guidance(2, empty, 0, Vector2(140,335)).text.contains("ceiling"), "Third room teaches ceiling shot while on high platform")
	check(tutorial.guidance(2, empty, 0, Vector2(300,415)).text.contains("jump"), "Third room retains ordinary action route")
	check(tutorial.guidance(2, blue, 0, Vector2(140,335)).text.to_lower().contains("left"), "Third room describes safe repositioning for floor shot")
	var finish: Dictionary = tutorial.guidance(2, pair, 1, Vector2(510,240))
	check(finish.text.contains("guard"), "Third room explains downward stomp after ceiling exit")
	check(tutorial.guidance(3, empty, 0, Vector2(128,205)).text.contains("right floor"), "Fourth room begins with visible right floor exit")
	check(tutorial.guidance(3, blue, 0, Vector2(128,205)).text.contains("ledge"), "Fourth room warns to step clear before wall shot")
	check(not tutorial.guidance(3, pair, 1, Vector2(800,270)).text.contains("guard"), "Fourth room has its own post-transfer guidance")
	print("TUTORIAL_TEST_FAILURES=",failures)
	quit(0 if failures == 0 else 1)
