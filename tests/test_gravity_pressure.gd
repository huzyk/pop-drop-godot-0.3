extends SceneTree
const Rules = preload("res://scripts/gravity_rules.gd")
const Session = preload("res://scripts/gravity_session.gd")
const Game = preload("res://scripts/gravity_game.gd")

func _initialize() -> void:
	var game = Game.new()
	assert(game != null)
	game.free()
	assert(Rules.wave_interval(0) == 15.0)
	assert(Rules.wave_interval(1) == 19.0)
	assert(Rules.wave_interval(3) == 27.0)
	assert(Rules.wave_interval(9) == 39.0)
	assert(Rules.wave_marble_count(1) == 6)
	assert(Rules.wave_marble_count(4) == 7)
	assert(Rules.wave_marble_count(8) == 8)
	var random = RandomNumberGenerator.new()
	random.seed = 12345
	var board: Array = Rules.empty_board()
	board[6][0] = 1
	board[5][3] = Rules.ROCK_MAX
	board[2][4] = 0
	var wave: Dictionary = Rules.rise_wave(board,random,6)
	assert(wave.valid and not wave.overflow)
	assert(wave.board[5][0] == 1)
	assert(wave.board[4][3] == Rules.ROCK_MAX)
	assert(wave.board[1][4] == 0)
	var filled: int = 0
	for value in wave.board[7]:
		if Rules.is_marble(int(value)):
			filled += 1
	assert(filled == 6)
	assert(wave.board[6][0] == Rules.EMPTY)
	assert(wave.motions.size() == 9)
	# Top overflow is a reported loss, not silent deletion.
	wave = Rules.rise_wave(wave.board,random,6)
	assert(wave.valid)
	wave.board[0][2] = 0
	var lost: Dictionary = Rules.rise_wave(wave.board,random,6)
	assert(not lost.valid and lost.overflow)
	assert(lost.board[0][2] == 0)

	# Three separate adjacent pop stages, even if multiple neighbouring hits.
	board = Rules.empty_board()
	board[5][3] = Rules.ROCK_MAX
	assert(Rules.find_groups(board,1).is_empty())
	var touched: Array = [Vector2i(2,5),Vector2i(3,4),Vector2i(4,5)]
	var result: Dictionary = Rules.damage_rocks(board,touched)
	assert(result.board[5][3] == 4)
	assert(result.cracked.size() == 1)
	assert(result.destroyed.is_empty())
	result = Rules.damage_rocks(result.board,touched)
	assert(result.board[5][3] == 3)
	result = Rules.damage_rocks(result.board,touched)
	assert(result.board[5][3] == Rules.EMPTY)
	assert(result.destroyed.size() == 1)
	# No diagonal damage.
	board[5][3] = Rules.ROCK_MAX
	result = Rules.damage_rocks(board,[Vector2i(2,4)])
	assert(result.board[5][3] == Rules.ROCK_MAX)
	# Rock cannot fall or be passed through by an ordinary dropped piece.
	board = Rules.empty_board()
	board[5][3] = Rules.ROCK_MAX
	board[2][3] = 1
	var settled: Dictionary = Rules.settle(board)
	assert(settled.board[5][3] == Rules.ROCK_MAX)
	assert(settled.board[4][3] == 1)
	var dropped: Dictionary = Rules.drop(settled.board,[[0,0,2]],3)
	assert(dropped.valid)
	assert(dropped.board[3][3] == 2)
	var spun: Dictionary = Rules.rotate(board,true)
	assert(Rules.rock_count(spun.board) == 1)
	assert(Rules.rock_count(Rules.settle(spun.board).board) == 1)
	# Wave blocks cannot be popped like normal marbles.
	board = Rules.empty_board()
	for x in range(5):
		board[7][x] = Rules.ROCK_MAX
	assert(Rules.find_matches(board).is_empty())
	# Spawn maximum: no more than three simultaneously.
	board = Rules.empty_board()
	for i in range(3):
		var spawn: Dictionary = Rules.spawn_rock(board,random)
		assert(spawn.spawned)
		board = spawn.board
	assert(Rules.rock_count(board) == 3)
	assert(not Rules.spawn_rock(board,random).spawned)
	# Old save versions remain valid, new rock grid values are accepted.
	var state: Dictionary = {
		"board":board,
		"pieces":[[[0,0,0]],[[0,0,1]],[[0,0,2]]],
		"score":0,"moves":0,"lives":3,"revives":0,
		"phase":"drop","wave_number":2,"wave_time_left":23.0
	}
	assert(Session.valid(state))
	state["wave_time_left"] = 99.0
	assert(not Session.valid(state))
	print("PASS: rising intervals, pressure rows, anchored rocks, three adjacent POP hits, saves")
	quit()
