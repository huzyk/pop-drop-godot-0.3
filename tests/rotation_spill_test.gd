extends SceneTree
## Run with: godot --headless --path . --script res://tests/rotation_spill_test.gd
const Rules = preload("res://scripts/gravity_rules.gd")

func _initialize() -> void:
	var shaft: Array = Rules.empty_board()
	for y in range(2,8):
		shaft[y][0] = y%3
	var original: String = JSON.stringify(shaft)
	var bead_count: int = Rules.filled(shaft)
	var spilled: Dictionary = Rules.spill_after_rotation(shaft,true)
	assert(spilled.rolls > 0, "A tall shaft must roll into the neighbouring pocket.")
	assert(Rules.filled(spilled.board) == bead_count, "Marbles must be conserved.")
	assert(JSON.stringify(shaft) == original, "Spilling must not mutate the source board.")
	assert(spilled.board[7][1] != Rules.EMPTY, "A lower-side pocket must be filled.")
	assert(spilled.motions.size() > 0, "Every moved marble needs animation data.")
	for item in spilled.motions:
		var route: Array = item.path
		assert(route.size() >= 2, "Moved marbles must have a path.")
		assert(route[0] == item["from"], "Start point must match the animation.")
		assert(route[route.size()-1] == item["to"], "End point must match the animation.")
		for i in range(1,route.size()):
			assert(route[i].y == route[i-1].y+1, "Each movement must go one row down.")
			assert(absf(route[i].x-route[i-1].x) <= 1.0, "No sideways teleportation.")
	var settled: Dictionary = Rules.spill_after_rotation(spilled.board,true)
	assert(settled.motions.is_empty(), "Finished marble flow must be stable.")
	assert(JSON.stringify(settled.board) == JSON.stringify(spilled.board), "Stable flow must be idempotent.")
	var direct_drop: Dictionary = Rules.drop(shaft,[[0,0,1]],2)
	assert(direct_drop.valid, "Original drop should remain valid.")
	assert(direct_drop.board[7][2] == 1, "A drop must still land vertically.")
	assert(direct_drop.board[7][1] == Rules.EMPTY, "A drop must not trigger side spill.")
	for clockwise in [false,true]:
		var turned: Array = Rules.rotate(shaft,clockwise).board
		turned = Rules.settle(turned).board
		turned = Rules.spill_after_rotation(turned,clockwise).board
		var expected: Dictionary = Rules.resolve_preview(turned,true,clockwise)
		var actual: Dictionary = Rules.rotate_preview(shaft,clockwise)
		assert(expected.score == actual.score, "Rotation preview score must match gameplay.")
		assert(JSON.stringify(expected.board) == JSON.stringify(actual.board),
			"Rotation preview board must match gameplay.")
	print("PASS: rotation-only marble spill, paths, stability, drops and previews.")
	quit(0)
