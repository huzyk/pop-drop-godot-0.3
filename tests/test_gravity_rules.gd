extends SceneTree
const Rules = preload("res://scripts/gravity_rules.gd")

func _initialize() -> void:
	var checks: int = 0
	var board: Array = Rules.empty_board()
	assert(Rules.filled(board) == 0)
	checks += 1

	# Three and four touching balls are NOT enough now. Five are needed.
	board[7][0] = 0
	board[7][1] = 0
	assert(Rules.find_matches(board).is_empty())
	var landing: Dictionary = Rules.drop(board,[[0,0,0]],2)
	assert(landing.valid)
	assert(landing.board[7][2] == 0)
	assert(Rules.find_matches(landing.board).is_empty())
	assert(Rules.find_groups(landing.board,3).size() == 1)
	assert(Rules.POP_THRESHOLD == 5)
	checks += 1

	# A vertical pair should enter one column, never overlap.
	var pair: Dictionary = Rules.drop(Rules.empty_board(),[[0,0,1],[0,1,2]],3)
	assert(pair.valid)
	assert(pair.board[6][3] == 1 and pair.board[7][3] == 2)
	checks += 1

	# Horizontal pairs enter two separate columns.
	var side: Dictionary = Rules.drop(Rules.empty_board(),[[0,0,1],[1,0,2]],4)
	assert(side.valid)
	assert(side.board[7][4] == 1 and side.board[7][5] == 2)
	checks += 1

	var edge: Dictionary = Rules.drop(Rules.empty_board(),[[0,0,1],[1,0,2]],7)
	assert(not edge.valid)
	checks += 1

	# Clockwise and counterclockwise rotation must be exact inverses.
	var test_board: Array = Rules.empty_board()
	test_board[7][0] = 0
	test_board[7][1] = 1
	test_board[3][2] = 2
	var clockwise: Dictionary = Rules.rotate(test_board,true)
	assert(clockwise.board[0][0] == 0)
	assert(clockwise.board[1][0] == 1)
	var reversed: Dictionary = Rules.rotate(clockwise.board,false)
	assert(reversed.board == test_board)
	checks += 1

	var settled: Dictionary = Rules.settle(clockwise.board)
	assert(settled.board[6][0] == 0)
	assert(settled.board[7][0] == 1)
	checks += 1

	# Different colours must never form an accidental match.
	var mixed: Array = Rules.empty_board()
	mixed[7][0] = 0
	mixed[7][1] = 1
	mixed[7][2] = 2
	assert(Rules.find_matches(mixed).is_empty())
	checks += 1

	# The faster opening must be busy but not already auto-cleared.
	var opening: Array = Rules.empty_board()
	for x in range(8):
		opening[7][x] = [-1,0,0,0,0,1,2,2][x]
		opening[6][x] = [-1,1,2,1,2,0,1,0][x]
		opening[5][x] = [-1,-1,2,0,1,2,0,1][x]
	assert(Rules.filled(opening) == 20)
	assert(Rules.find_matches(opening).is_empty())
	# The opening is four connected balls from a charged five-ball group.
	assert(Rules.find_groups(opening,4).size() == 1)
	assert(Rules.find_matches(opening).is_empty())
	assert(opening == Rules.settle(opening).board,
		"Starter must have no floating balls or unreachable bottom gaps")
	var first_goal: Dictionary = Rules.drop(opening,[[0,0,0]],0)
	assert(first_goal.valid)
	assert(Rules.find_matches(first_goal.board).size() == 5,
		"The open first column must really complete the first 5/5 target")
	var clockwise_opening: Array = Rules.settle(Rules.rotate(opening,true).board).board
	assert(Rules.find_matches(clockwise_opening).is_empty())
	checks += 4

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = 20261027
	# The previous immediate POP on drop is now only a POSSIBLE target:
	# dropping is a banking action; the real action cashing it in is rotation.
	var saved_group: Array = Rules.empty_board()
	saved_group[7][1] = 0
	saved_group[7][2] = 0
	# Place a three-ball piece beside a pair: now five connected.
	var prepared: Dictionary = Rules.drop(saved_group,[[0,0,0],[1,0,0],[2,0,0]],3)
	assert(prepared.valid and Rules.find_matches(prepared.board).size() == 5)
	assert(Rules.group_points(3) == 0 and Rules.group_points(4) == 0)
	assert(Rules.group_points(5) == 320)
	var projected: Dictionary = Rules.rotate_preview(prepared.board,true)
	assert(int(projected["score"]) == 320)
	assert(int(projected["removed"]) == 5)
	assert(int(projected["chains"]) == 1)
	# The preview must NEVER mutate the pending board, so the player
	# can choose to keep stacking rather than cash out now.
	assert(Rules.find_matches(prepared.board).size() == 5)
	checks += 7

	# Rewards are nonlinear. A large cluster is worth more than
	# splitting the same number of balls into smaller groups.
	var expected: Array = [320,560,900,1400]
	for i in range(expected.size()):
		assert(Rules.group_points(i+5) == expected[i])
	assert(Rules.group_points(9) > Rules.group_points(8))
	var group_of_six: Array = Rules.empty_board()
	for x in range(6):
		group_of_six[7][x] = 1
	var six_groups: Array = Rules.find_groups(group_of_six)
	assert(six_groups.size() == 1 and int(six_groups[0]["count"]) == 6)
	assert(Rules.score_groups(six_groups) == 560)
	assert(Rules.score_groups(six_groups,3) == 1680)
	checks += 10

	# Two disconnected groups of five score 2*320, not a single 10-ball prize.
	var separate: Array = Rules.empty_board()
	for y in range(3,8):
		separate[y][0] = 0
		separate[y][7] = 0
	var separate_groups: Array = Rules.find_groups(separate)
	assert(separate_groups.size() == 2)
	assert(Rules.score_groups(separate_groups) == 640)
	assert(Rules.find_matches(separate).size() == 10)
	checks += 3

	# Clear, fair loss boundary: reaching row zero means a life is at risk.
	var tower: Array = Rules.empty_board()
	for y in range(8):
		tower[y][4] = 2
	assert(Rules.ceiling_reached(tower))
	assert(Rules.tallest_column(tower) == 8)
	var rescued: Array = Rules.rescue(tower)
	assert(not Rules.ceiling_reached(rescued))
	assert(Rules.tallest_column(rescued) == 6)
	assert(not Rules.ceiling_reached(prepared.board))
	checks += 5

	# All piece templates have the expected size and valid unique positions.
	var shapes_checked: int = 0
	for piece_size in range(1,5):
		for shape in Rules.SHAPES_BY_SIZE[piece_size-1]:
			assert(shape.size() == piece_size)
			var occupied: Dictionary = {}
			for position in shape:
				assert(position.x >= 0 and position.x < 8)
				assert(position.y >= 0 and position.y < 8)
				assert(not occupied.has(position))
				occupied[position] = true
			shapes_checked += 1
	assert(shapes_checked == 12)
	checks += shapes_checked

	# Both zigzags are different playable drop shapes, not just preview art.
	# Colours intentionally stay in the same sequence for a fair comparison.
	var s_outline: Array = Rules.SHAPES_BY_SIZE[3][4]
	var z_outline: Array = Rules.SHAPES_BY_SIZE[3][5]
	var s_piece: Array = []
	var z_piece: Array = []
	var tones: Array = [0,1,2,0]
	for i in range(4):
		var sp: Vector2i = s_outline[i]
		var zp: Vector2i = z_outline[i]
		s_piece.append([sp.x,sp.y,tones[i]])
		z_piece.append([zp.x,zp.y,tones[i]])
	assert(Rules.piece_shape_id(s_piece) != Rules.piece_shape_id(z_piece))
	var s_result: Dictionary = Rules.drop(Rules.empty_board(),s_piece,2)
	var z_result: Dictionary = Rules.drop(Rules.empty_board(),z_piece,2)
	assert(s_result.valid and z_result.valid)
	assert(s_result.board != z_result.board,
		"Z and S must produce different arrangements, even with identical colours")
	checks += 3

	# Newly offered pieces may not clear themselves on an empty board.
	for piece_size in range(1,5):
		for sample in range(140):
			var candidate: Array = Rules.make_piece(random,Rules.empty_board(),piece_size)
			assert(candidate.size() == piece_size)
			var placed: Dictionary = Rules.drop(Rules.empty_board(),candidate,0)
			assert(placed.get("valid",false))
			assert(Rules.find_matches(placed.board).is_empty())
			checks += 1

	# Generator must actually surface all six four-ball silhouettes.
	var four_seen: Dictionary = {}
	for sample in range(500):
		var quad: Array = Rules.make_piece(random,Rules.empty_board(),4)
		four_seen[Rules.piece_shape_id(quad)] = true
	assert(four_seen.size() == 6,"All six four-ball silhouettes should occur")
	checks += 6

	# Test that the size distribution is not distorted toward four-ball pieces.
	var size_counts: Array = [0,0,0,0]
	for sample in range(900):
		var sampled_size: int = Rules.choose_piece_size(random,Rules.empty_board())
		size_counts[sampled_size-1] += 1
	assert(size_counts[1] > size_counts[3])
	assert(size_counts[2] > size_counts[3])
	assert(size_counts[3] > 170 and size_counts[3] < 365)
	checks += 3

	# Generate hundreds of actual turns, not just isolated shapes.
	var simulation: Array = Rules.empty_board()
	for turn in range(300):
		var piece: Array = Rules.next_piece(random,simulation)
		assert(piece.size() >= 1 and piece.size() <= 4)
		# The selected shape is not an automatic reward on an empty board.
		assert(Rules.find_matches(Rules.drop(Rules.empty_board(),piece,0).board).is_empty())
		var possible: Array = []
		for col in range(8):
			if Rules.drop(simulation,piece,col).get("valid",false):
				possible.append(col)
		if possible.is_empty():
			simulation = Rules.rescue(simulation)
			continue
		var result: Dictionary = Rules.drop(simulation,piece,possible[random.randi_range(0,possible.size()-1)])
		simulation = result.board
		# Holding a cluster after a drop is allowed; no automatic POP here.
		var direction: bool = random.randi_range(0,1) == 1
		simulation = Rules.settle(Rules.rotate(simulation,direction).board).board
		for depth in range(20):
			var hits: Array = Rules.find_matches(simulation)
			if hits.is_empty():
				break
			simulation = Rules.settle(Rules.erase_matches(simulation,hits)).board
		assert(Rules.filled(simulation) <= 64)
		checks += 1
	print("POP DROP Gravity rules OK: ",checks," checks")
	quit()
