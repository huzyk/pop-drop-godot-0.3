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
	assert(wallet.stock("magic") == 0)
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
	assert(wallet.purchase("reroll"))
	assert(wallet.stock("reroll") == 1)
	assert(wallet.coins == 92)
	assert(not wallet.purchase("gold"))
	assert(not wallet.equip_skin("neon"))
	assert(wallet.use_boost("bomb"))
	assert(wallet.stock("bomb") == 0)
	assert(not wallet.use_boost("bomb"))
	assert(wallet.use_boost("reroll"))
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
	assert(Shop.item("time").is_empty()) # +10 seconds removed
	assert(Shop.item("magic").is_empty()) # retired; no longer purchasable
	assert(Shop.item("reroll").get("price") == 140)
	assert(Shop.RESCUE_PRICE == 220)
	assert(wallet.credit_bonus("badge:first",80) == 80)
	assert(wallet.credit_bonus("badge:first",80) == 0)
	assert(wallet.spend_coins(50))
	assert(not wallet.spend_coins(100000))
	# Energy refreshes after 20 minutes and never exceeds five.
	var energy_wallet = Shop.new()
	energy_wallet.persist_enabled = false
	assert(energy_wallet.energy == 5)
	assert(energy_wallet.spend_energy(100000))
	assert(energy_wallet.energy == 4)
	assert(energy_wallet.refresh_energy(101199) == 4)
	assert(energy_wallet.refresh_energy(101200) == 5)
	for i in range(5):
		assert(energy_wallet.spend_energy(102000))
	assert(not energy_wallet.spend_energy(102000))
	assert(energy_wallet.reward_energy(102000))
	assert(energy_wallet.energy == 1)
	# Seven distinct calendar days grant 20/30/50/70/90/120/150 coins.
	var daily_wallet = Shop.new()
	daily_wallet.persist_enabled = false
	var expected: Array = [20,30,50,70,90,120,150]
	for i in range(7):
		var day: String = "2026-10-%02d" % (10+i)
		var prize: Dictionary = daily_wallet.claim_daily(day)
		assert(int(prize["day"]) == i+1)
		assert(int(prize["coins"]) == expected[i])
		assert(daily_wallet.claim_daily(day).is_empty())
	assert(daily_wallet.owns_skin("star_capybara"))
	assert(daily_wallet.equip_skin("star_capybara"))
	assert(daily_wallet.claim_daily("2026-10-20")["day"] == 1)

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
