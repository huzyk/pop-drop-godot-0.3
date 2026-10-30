extends SceneTree
const Rules = preload("res://scripts/gravity_rules.gd")
const Session = preload("res://scripts/gravity_session.gd")
const Game = preload("res://scripts/gravity_game.gd")

func _initialize() -> void:
	var game = Game.new()
	assert(game != null)
	game.free()
	# Three tiers replace the old rapidly accelerating, rising death-line waves.
	assert(Rules.wave_interval(0) == 16.0)
	assert(Rules.wave_interval(3) == 16.0)
	assert(Rules.wave_interval(4) == 14.0)
	assert(Rules.wave_interval(8) == 14.0)
	assert(Rules.wave_interval(9) == 12.0)
	assert(Rules.wave_interval(60) == 12.0)
	assert(Rules.wave_marble_count(1) == 4)
	assert(Rules.wave_marble_count(4) == 4)
	assert(Rules.wave_marble_count(5) == 5)
	assert(Rules.wave_marble_count(10) == 6)
	assert(not Rules.wave_is_surge(4))
	assert(Rules.wave_is_surge(5))
	assert(Rules.wave_is_surge(10))
	assert(not Rules.wave_is_surge(11))
	assert(Rules.wave_total_marbles(4) == 4)
	assert(Rules.wave_total_marbles(5) == 7)
	assert(Rules.wave_total_marbles(10) == 8)
	assert(Rules.wave_total_marbles(15) == 8)

	var rng = RandomNumberGenerator.new()
	rng.seed = 12345
	var board: Array = Rules.empty_board()
	board[0][0] = 0
	board[5][3] = Rules.ROCK_MAX
	board[7][4] = 1
	var wave: Dictionary = Rules.drop_wave(board,rng,4)
	assert(wave.added == 4)
	assert(wave.motions.size() == 4)
	assert(wave.board[0][0] == 0) # Top-row marble survives; no death line.
	assert(wave.board[5][3] == Rules.ROCK_MAX) # Anchored rock remains.
	assert(wave.board[7][4] == 1)
	assert(Rules.filled(wave.board) == Rules.filled(board)+4)
	assert(board[0][0] == 0) # Original board is not mutated.
	var columns: Dictionary = {}
	for motion in wave.motions:
		columns[int(motion["to"].x)] = true
	assert(columns.size() == 4) # No wave stacks multiple balls in one column.

	# More varied shapes are offered, but the fallback must keep them playable.
	rng.seed = 934
	var wide: int = 0
	var small: int = 0
	for i in range(300):
		if Rules.choose_piece_size(rng,Rules.empty_board()) >= 3:
			wide += 1
		else:
			small += 1
	assert(wide > small)

	# If only two columns have room, the wave adds only two balls.
	board = Rules.empty_board()
	for x in range(6):
		board[0][x] = Rules.ROCK_MAX
	wave = Rules.drop_wave(board,rng,5)
	assert(wave.added == 2)
	assert(Rules.filled(wave.board) == Rules.filled(board)+2)
	for x in range(6):
		assert(wave.board[0][x] == Rules.ROCK_MAX)

	# Full roof: no imaginary overflow damage or erased cells.
	board = Rules.empty_board()
	for x in range(8):
		board[0][x] = Rules.ROCK_MAX
	wave = Rules.drop_wave(board,rng,5)
	assert(wave.added == 0)
	assert(wave.motions.is_empty())
	assert(wave.board == board)

	# Nonempty top row is legal when offered shapes fit elsewhere.
	board = Rules.empty_board()
	for y in range(8):
		board[y][0] = Rules.ROCK_MAX
	var single: Array = [[0,0,2]]
	assert(Rules.any_drop(board,single))
	# Completely packed rocks are truly unwinnable, even after all rotations.
	board = Rules.empty_board()
	for y in range(8):
		for x in range(8):
			board[y][x] = Rules.ROCK_MAX
	assert(not Rules.any_drop(board,single))
	assert(not Rules.can_recover_by_rotating(board,[single]))
	var continuation: Array = Rules.rescue_for_continue(board)
	assert(Rules.any_drop(continuation,single))
	assert(Rules.rock_count(continuation) == 62)

	# A rock is still destroyed by three SEPARATE adjacent POP stages.
	board = Rules.empty_board()
	board[5][3] = Rules.ROCK_MAX
	var touches: Array = [Vector2i(2,5),Vector2i(3,4),Vector2i(4,5)]
	var hit: Dictionary = Rules.damage_rocks(board,touches)
	assert(hit.board[5][3] == 4)
	assert(hit.cracked.size() == 1)
	hit = Rules.damage_rocks(hit.board,touches)
	assert(hit.board[5][3] == 3)
	hit = Rules.damage_rocks(hit.board,touches)
	assert(hit.board[5][3] == Rules.EMPTY)

	# No arbitrary rock limit: can accumulate more than eight.
	board = Rules.empty_board()
	for n in range(12):
		var spawned: Dictionary = Rules.spawn_rock(board,rng)
		assert(spawned.spawned)
		board = spawned.board
	assert(Rules.rock_count(board) == 12)
	assert(Rules.rock_count(Rules.rotate(board,true).board) == 12)
	assert(Rules.rock_count(Rules.settle(board).board) == 12)

	# The existing save schema stays compatible with old alpha checkpoints.
	var state: Dictionary = {
		"board":board,
		"pieces":[[[0,0,0]],[[0,0,1]],[[0,0,2]]],
		"score":0,"moves":0,"lives":1,"revives":0,
		"phase":"drop","wave_number":2,"wave_time_left":16.0,
		"loss_reason":""
	}
	assert(Session.valid(state))
	state["wave_time_left"] = 99.0
	assert(not Session.valid(state))
	print("PASS: 16/14/12 pressure, surge bursts, varied pieces, no-moves loss and unlimited rocks")
	quit()
