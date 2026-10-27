extends SceneTree
const Rules = preload("res://scripts/gravity_rules.gd")

func _initialize() -> void:
	var checks: int = 0
	var board: Array = Rules.empty_board()
	assert(Rules.filled(board) == 0)
	checks += 1

	# Two balls on the floor are a visible target; a third completes a POP.
	board[7][0] = 0
	board[7][1] = 0
	assert(Rules.find_matches(board).is_empty())
	var landing: Dictionary = Rules.drop(board,[[0,0,0]],2)
	assert(landing.valid)
	assert(landing.board[7][2] == 0)
	assert(Rules.find_matches(landing.board).size() == 3)
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
		opening[7][x] = [0,0,2,1,1,0,2,2][x]
		opening[6][x] = [1,2,0,2,0,2,1,0][x]
	for ball in [[0,5,2],[3,5,0],[5,5,1],[7,5,1]]:
		opening[ball[1]][ball[0]] = ball[2]
	assert(Rules.filled(opening) == 20)
	assert(Rules.find_matches(opening).is_empty())
	# Rotating is a meaningful action without first dropping another shape.
	var clockwise_opening: Array = Rules.settle(Rules.rotate(opening,true).board).board
	assert(Rules.find_matches(clockwise_opening).size() >= 3)
	checks += 3

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = 20261027
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
		for depth in range(20):
			var hits: Array = Rules.find_matches(simulation)
			if hits.is_empty():
				break
			simulation = Rules.settle(Rules.erase_matches(simulation,hits)).board
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
