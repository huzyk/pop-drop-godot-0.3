extends SceneTree

const Game = preload("res://scripts/gravity_game.gd")
const Rules = preload("res://scripts/gravity_rules.gd")

func _initialize() -> void:
	var screen = Game.new()
	# Every drawn and clickable board cell must share the same 72px grid.
	assert(Game.BOARD.size == Vector2(576,576))
	assert(Game.CELL * Rules.SIZE == Game.BOARD.size.x)
	assert(Game.BOARD.position == Vector2(72,244))
	assert(Game.BOARD.end.y <= 824.0)
	assert(Game.BOARD.position.y > Game.HUD_SCORE.end.y)
	assert(not Game.HUD_SCORE.intersects(Game.HUD_WAVE))
	assert(not Game.HUD_WAVE.intersects(Game.HUD_LIVES))
	assert(not Game.HUD_LIVES.intersects(Game.BOARD))
	assert(not Game.COINS_OPEN.intersects(Game.SHOP_OPEN))
	for i in range(3):
		var card: Rect2 = screen._piece_card_rect(i)
		assert(card.size.y >= 100.0)
		assert(card.position.x >= 20.0)
		assert(card.end.x <= 700.0)
		assert(card.position.y >= Game.DOCK_STATUS.end.y + 20.0)
		assert(Game.LEFT_RECT.position.y - card.end.y >= 28.0)
		assert(not card.intersects(Game.LEFT_RECT))
		assert(not card.intersects(Game.RIGHT_RECT))
		assert(not card.intersects(Game.BOOST_BOMB))
		assert(not card.intersects(Game.BOOST_TIME))
		for j in range(i+1,3):
			assert(not card.intersects(screen._piece_card_rect(j)))
	assert(not Game.LEFT_RECT.intersects(Game.RIGHT_RECT))
	assert(not Game.BOOST_BOMB.intersects(Game.BOOST_TIME))
	assert(Game.BOOST_BOMB.position.y - Game.LEFT_RECT.end.y >= 18.0)
	assert(Game.BOOST_TIME.position.y - Game.RIGHT_RECT.end.y >= 18.0)
	assert(Game.BOOST_BOMB.end.y <= 1252.0)
	assert(Game.BOOST_TIME.end.y <= 1252.0)
	assert(Game.SETTINGS_OPEN.end.y <= Game.HUD_SCORE.position.y)
	assert(Game.SHOP_OPEN.end.y <= Game.HUD_WAVE.position.y)
	# The touch map and visuals agree for board corners.
	assert(screen._board_cell(Game.BOARD.position+Vector2(5,5)) == Vector2i(0,0))
	assert(screen._board_cell(Game.BOARD.end-Vector2(5,5)) == Vector2i(7,7))
	assert(screen._board_cell(Vector2(15,400)) == Vector2i(-1,-1))
	screen.pieces = [
		[[0,0,0],[1,0,1]],
		[[0,0,0],[0,1,1]],
		[[0,0,0]]
	]
	assert(screen._drop_column_at(Game.BOARD.position+Vector2(10,200)) == 0)
	assert(screen._drop_column_at(Vector2(714,400)) == -1)
	screen.free()
	print("PASS: 720x1280 layout, board mapping, HUD, large shape cards, 28px+ spacing and distinct boosters")
	quit()
