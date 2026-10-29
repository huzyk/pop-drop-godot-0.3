extends SceneTree
const Shop = preload("res://scripts/gravity_shop.gd")
const Rules = preload("res://scripts/gravity_rules.gd")
const Game = preload("res://scripts/gravity_game.gd")

func _initialize() -> void:
	var game = Game.new()
	assert(game != null)
	game.free()
	var wallet = Shop.new()
	wallet.persist_enabled = false
	assert(wallet.coins == 0)
	assert(wallet.stock("bomb") == 0)
	assert(not wallet.can_purchase("bomb"))
	assert(Shop.earned_from_pop(0) == 0)
	assert(Shop.earned_from_pop(320) == 32)
	assert(Shop.earned_from_pop(560) == 56)
	assert(Shop.earned_from_pop(900) == 90)
	assert(wallet.credit_pop("r1:a1:pop1",320) == 32)
	assert(wallet.credit_pop("r1:a1:pop1",320) == 0)
	assert(wallet.coins == 32)
	for i in range(4):
		wallet.credit_pop("r1:a2:pop%d" % i,900)
	assert(wallet.coins == 392)
	assert(wallet.purchase("bomb"))
	assert(wallet.stock("bomb") == 1)
	assert(wallet.coins == 232)
	assert(wallet.purchase("time"))
	assert(wallet.stock("time") == 1)
	assert(wallet.coins == 122)
	assert(not wallet.purchase("gold"))
	assert(not wallet.equip_skin("neon"))
	assert(wallet.use_boost("bomb"))
	assert(wallet.stock("bomb") == 0)
	assert(not wallet.use_boost("bomb"))
	assert(wallet.use_boost("time"))
	assert(wallet.stock("time") == 0)
	for i in range(6):
		wallet.credit_pop("r2:pop%d" % i,1000)
	assert(wallet.purchase("neon"))
	assert(wallet.owns_skin("neon"))
	assert(wallet.equip_skin("neon"))
	assert(wallet.equipped_skin=="neon")
	assert(not wallet.purchase("neon"))
	assert(wallet.equip_skin("default"))
	assert(not wallet.equip_skin("gold"))
	assert(not wallet.purchase("unknown"))
	assert(not wallet.use_boost("unknown"))

	# Bomb is a clean 3x3 removal, not a synthetic POP that earns score/coins.
	var board: Array = Rules.empty_board()
	board[4][4] = Rules.ROCK_MAX
	board[3][3] = 0
	board[3][4] = 1
	board[3][5] = 2
	board[4][3] = 0
	board[5][3] = 0
	board[5][4] = 1
	board[5][5] = 2
	var result: Dictionary = Rules.explode(board,Vector2i(4,4))
	assert(result.valid)
	assert(result.removed == 7)
	assert(result.rocks_hit == 1)
	assert(result.board[4][4] == 4)
	assert(result.board[3][3] == Rules.EMPTY)
	assert(board[4][4] == Rules.ROCK_MAX) # Input board was not mutated.
	result = Rules.explode(result.board,Vector2i(4,4))
	assert(result.valid)
	assert(result.rocks_hit == 1)
	assert(result.board[4][4] == 3)
	result = Rules.explode(result.board,Vector2i(4,4))
	assert(result.valid)
	assert(result.board[4][4] == Rules.EMPTY)
	assert(not Rules.explode(Rules.empty_board(),Vector2i(4,4)).valid)
	assert(not Rules.explode(board,Vector2i(-1,-1)).valid)
	# Boundary: blast can be aimed at every corner.
	board = Rules.empty_board()
	board[0][0] = 0
	board[0][1] = 1
	board[1][0] = 2
	result = Rules.explode(board,Vector2i(0,0))
	assert(result.removed == 3)
	assert(Rules.find_groups(result.board).is_empty())
	print("PASS: wallet idempotency, purchases, ownership, powerup stock, 3x3 bomb and rock damage")
	quit()
