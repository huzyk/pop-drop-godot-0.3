extends SceneTree
const Rules = preload("res://scripts/gravity_rules.gd")
const Session = preload("res://scripts/gravity_session.gd")
const Game = preload("res://scripts/gravity_game.gd")

func _initialize() -> void:
	var game = Game.new()
	assert(game != null)
	game.free()
	assert(Rules.wave_interval(0) == 12.0)
	assert(Rules.wave_interval(1) == 11.0)
	assert(Rules.wave_interval(3) == 9.0)
	assert(Rules.wave_interval(4) == 8.0)
	assert(Rules.wave_interval(9) == 8.0)
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
	# Regression: a rock reaching the roof after rotation previously triggered
	# ceiling loss -> rescue, which erased the supposedly three-hit rock.
	board = Rules.empty_board()
	board[2][0] = Rules.ROCK_MAX
	board[2][2] = Rules.ROCK_MAX - 1
	board[5][7] = Rules.ROCK_MIN
	var original_rock_count: int = Rules.rock_count(board)
	var rotated_rocks: Dictionary = Rules.rotate(board,true)
	assert(Rules.rock_count(rotated_rocks.board) == original_rock_count)
	assert(rotated_rocks.board[0][5] == Rules.ROCK_MAX)
	assert(not Rules.ceiling_reached(rotated_rocks.board))
	var after_gravity: Array = Rules.settle(rotated_rocks.board).board
	assert(after_gravity[0][5] == Rules.ROCK_MAX)
	assert(Rules.rock_count(after_gravity) == original_rock_count)
	var after_spill: Array = Rules.spill_after_rotation(after_gravity,true).board
	assert(Rules.rock_count(after_spill) == original_rock_count)
	var after_rescue: Array = Rules.rescue(after_spill)
	assert(Rules.rock_count(after_rescue) == original_rock_count)
	assert(after_rescue[0][5] == Rules.ROCK_MAX)
	var reversed_rocks: Array = Rules.rotate(rotated_rocks.board,false).board
	assert(reversed_rocks == board)
	var reset_rocks: Array = Rules.clear_marbles(after_spill)
	assert(Rules.rock_count(reset_rocks) == original_rock_count)
	assert(reset_rocks == after_spill)

	# A rescue should only remove marbles and retain each rock's hit points,
	# including one on a row that contains a marble.
	board = Rules.empty_board()
	board[0][0] = Rules.ROCK_MIN
	board[0][1] = 0
	board[1][1] = 1
	board[1][7] = Rules.ROCK_MAX
	board[3][4] = Rules.ROCK_MAX - 1
	board[7][4] = 2
	assert(Rules.ceiling_reached(board))
	var saved_rocks: Array = Rules.rescue(board)
	assert(Rules.rock_count(saved_rocks) == 3)
	assert(saved_rocks[0][0] == Rules.ROCK_MIN)
	assert(saved_rocks[1][7] == Rules.ROCK_MAX)
	assert(saved_rocks[3][4] == Rules.ROCK_MAX - 1)
	assert(not Rules.ceiling_reached(saved_rocks))
	var only_rocks: Array = Rules.clear_marbles(board)
	assert(Rules.rock_count(only_rocks) == 3)
	assert(only_rocks[7][4] == Rules.EMPTY)
	assert(only_rocks[0][1] == Rules.EMPTY)

	# A wave cannot discard a top-row rock even after rescue.
	var blocked_wave: Dictionary = Rules.rise_wave(saved_rocks,random,6)
	assert(not blocked_wave.valid and blocked_wave.overflow)
	assert(Rules.rock_count(blocked_wave.board) == 3)
	assert(Rules.rock_count(Rules.rescue(blocked_wave.board)) == 3)

	# Spawn maximum: eight independent obstacles can build up.
	board = Rules.empty_board()
	for i in range(Rules.MAX_ROCKS):
		var spawn: Dictionary = Rules.spawn_rock(board,random)
		assert(spawn.spawned)
		board = spawn.board
	assert(Rules.rock_count(board) == Rules.MAX_ROCKS)
	assert(not Rules.spawn_rock(board,random).spawned)
	# Old save versions remain valid, new rock grid values are accepted.
	var state: Dictionary = {
		"board":board,
		"pieces":[[[0,0,0]],[[0,0,1]],[[0,0,2]]],
		"score":0,"moves":0,"lives":3,"revives":0,
		"phase":"drop","wave_number":2,"wave_time_left":10.0
	}
	assert(Session.valid(state))
	state["wave_time_left"] = 99.0
	assert(not Session.valid(state))
	print("PASS: rising waves, three-hit rocks, rotate/rescue preserves every rock, saves")
	quit()
