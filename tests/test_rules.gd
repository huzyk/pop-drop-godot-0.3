extends SceneTree
const Rules = preload("res://scripts/rules.gd")

func _initialize() -> void:
	var checks := 0
	var board := Rules.empty_board()
	assert(board.size() == 8)
	board[7][1] = 0
	board[7][2] = 0
	var result: Dictionary = Rules.simulate(board,[[0,0,0]],Vector2i(3,7))
	assert(result.valid and result.removed == 3 and result.chains == 1)
	checks += 1
	assert(not Rules.simulate(board,[[0,0,1]],Vector2i(2,7)).valid)
	checks += 1

	# Reproduce the actual starter board, then test many random 3-piece trays.
	var starter := Rules.empty_board()
	for s in [[1,7,0],[2,7,0],[5,7,1],[6,7,1],[3,6,2],[4,6,2],[0,7,1],[7,7,2]]:
		starter[s[1]][s[0]] = s[2]
	var dense := Rules.empty_board()
	for y in range(4,8):
		for x in range(8):
			dense[y][x] = (x+y)%3

	var rng := RandomNumberGenerator.new()
	rng.seed = 20261026
	# Regression: a tray piece cannot contain its own pop of 3+ matching beads.
	# A 3-bead monochrome line is exactly the previous broken behaviour.
	var broken_piece: Array = Rules.make_piece(3,[0,0,0])
	assert(Rules.intrinsic_matches(broken_piece).size() == 3)
	for count in [3,4]:
		for sample in range(250):
			var candidate: Array = Rules.make_candidate(rng,starter,count)
			assert(Rules.intrinsic_matches(candidate).is_empty(),
				"Generated a piece that can clear without board interaction")
			checks += 1
	
	for sample_board in [Rules.empty_board(),starter,dense]:
		for i in range(30):
			var plan: Dictionary = Rules.generate_tray_plan(sample_board,rng)
			assert(plan.tray.size() == 3, "Expected a full tray with room on the board")
			assert(plan.anchors.size() == 3, "Each planned piece needs a legal move")
			var virtual_board: Array = Rules.copy_board(sample_board)
			for slot in range(3):
				var piece: Array = plan.tray[slot]
				assert(piece.size() >= 1 and piece.size() <= 4)
				assert(Rules.intrinsic_matches(piece).is_empty(),
					"Tray must not contain a self-clearing piece")
				# Every offered piece must be playable on the current real board.
				assert(Rules.any_placement(sample_board,piece))
				var landing: Vector2i = plan.anchors[slot]
				var move: Dictionary = Rules.simulate(virtual_board,piece,landing)
				assert(move.valid, "Generator's 3-move plan must be legal")
				virtual_board = move.board
				checks += 1

	print("POP DROP GDScript generator/regression tests OK: ",checks," checks")
	quit()
