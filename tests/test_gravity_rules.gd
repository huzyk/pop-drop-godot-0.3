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
	# Generate hundreds of actual turns, not just isolated shapes.
	var simulation: Array = Rules.empty_board()
	for turn in range(300):
		var piece: Array = Rules.next_piece(random,simulation)
		assert(piece.size() >= 1 and piece.size() <= 3)
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
