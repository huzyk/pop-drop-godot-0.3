extends SceneTree
## Deterministic offline balance smoke test, not a claim about real player retention.
const Rules = preload("res://scripts/gravity_rules.gd")
const Shop = preload("res://scripts/gravity_shop.gd")
const Game = preload("res://scripts/gravity_game.gd")

func _initialize() -> void:
	assert(Shop.earned_from_pop(320) == 9)
	assert(Shop.earned_from_pop(900) == 15)
	assert(Shop.earned_from_pop(9000) == 47)
	assert(Shop.earned_from_pop(90000) == 150)
	assert(100 * Shop.earned_from_pop(320) >= int(Shop.item("neon")["price"]))
	assert(Shop.earned_from_pop(6400) > Shop.earned_from_pop(3200))
	var total_drops: int = 0
	var total_pops: int = 0
	var total_coins: int = 0
	var completed: Array = []
	for seed in range(12):
		var rng = RandomNumberGenerator.new()
		rng.seed = 11002 + seed * 97
		var board: Array = Rules.empty_board()
		var drops: int = 0
		var pops: int = 0
		var coins: int = 0
		for turn in range(24):
			var piece: Array = Rules.next_piece(rng,board)
			var best: Array = []
			var best_points: int = -100000
			var best_reward: int = 0
			for column in range(Rules.SIZE):
				var attempt: Dictionary = Rules.drop(board,piece,column)
				if not bool(attempt.get("valid",false)):
					continue
				var preview: Dictionary = Rules.resolve_preview(attempt.board)
				var points: int = int(preview["score"])
				var quality: int = points*10 - Rules.filled(preview["board"])
				if quality > best_points:
					best_points = quality
					best = preview["board"]
					best_reward = Shop.earned_from_pop(points)
			if best.is_empty():
				break
			board = best
			drops += 1
			if best_reward > 0:
				pops += 1
				coins += best_reward
			if (turn + 1) % 4 == 0:
				var wave_number: int = int((turn + 1) / 4)
				board = Rules.drop_wave(board,rng,Rules.wave_total_marbles(wave_number)).board
				if wave_number % 2 == 0:
					board = Rules.spawn_rock(board,rng).board
				board = Rules.resolve_preview(board).board
				assert(Rules.rock_count(board) <= Rules.MAX_ACTIVE_ROCKS)
		total_drops += drops
		total_pops += pops
		total_coins += coins
		completed.append(drops)
	assert(total_drops > 0)
	assert(total_coins >= 0)
	assert(total_pops <= total_drops)
	completed.sort()
	print("PASS: deterministic 12-seed balance sample drops=%d pops=%d coins=%d median_drops=%d (not player data)" %
		[total_drops,total_pops,total_coins,int(completed[6])])
	quit()
