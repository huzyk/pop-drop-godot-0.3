extends SceneTree
## Catch real touch overlaps when polishing the 720x1280 mobile UI.
const Game = preload("res://scripts/gravity_game.gd")

func _initialize() -> void:
	var view = Game.new()
	assert(view != null)
	# Keep the art screen-sized and resolvable by the runtime importer.
	assert(ResourceLoader.exists("res://assets/ui/arcade_backdrop.svg"))
	assert(Game.BACKDROP != null)
	assert(Game.BACKDROP.get_size() == Game.BASE)
	assert(Game.CELL * 8.0 == Game.BOARD.size.x)
	assert(Game.BOARD.size.x == Game.BOARD.size.y)
	assert(Game.BOARD.size.x >= 530.0)

	# Language control must be visible, directly tappable and reachable
	# independently in settings, with no obstruction by top controls.
	assert(Game.LANG_RECT.size.x >= 100)
	assert(Game.SETTINGS_LANGUAGE.size.y >= 50)
	assert(Game.SETTINGS_LANGUAGE.position.y > Game.SETTINGS_AD_PRIVACY.end.y)
	assert(Game.SETTINGS_MUSIC.position.y >= Game.SETTINGS_LANGUAGE.end.y)
	assert(Game.SETTINGS_MUSIC_VOLUME.position.y == Game.SETTINGS_MUSIC.position.y)
	assert(Game.SETTINGS_MUSIC.end.y <= Game.SETTINGS_SOUND.position.y)
	assert(Game.SETTINGS_LANGUAGE.end.y < Game.SETTINGS_SOUND.position.y)
	assert(not Game.LANG_RECT.intersects(Game.SETTINGS_OPEN))
	var localize = Game.new()
	assert(localize.fx_t("amazing") == "AMAZING!") # Default en
	localize.language = "pl"
	assert(localize.fx_t("great") == "ŚWIETNIE!")
	assert(localize.fx_t("amazing") == "NIESAMOWITE!")
	assert(localize.fx_t("surge") == "NAWAŁNICA!")
	assert(localize.language_name() == "POLSKI")
	assert(localize.has_method("_cycle_language"))
	assert(Game.LOCALES.size() == 7)
	localize.free()

	# The board must not collide with any dashboard or action panels.
	for hud in [Game.HUD_SCORE,Game.HUD_WAVE,Game.HUD_LIVES]:
		assert(not Game.BOARD.grow(6).intersects(hud))
	assert(Game.BOARD.end.y + 12.0 < Game.DOCK_STATUS.position.y)
	assert(Game.DOCK_STATUS.end.y < Game.DOCK_SHAPES.position.y)
	assert(Game.DOCK_SHAPES.end.y < Game.DOCK_ACTIONS.position.y)

	# Three independent >90px-high selection targets, at least 25px from turns.
	var cards: Array = []
	for i in range(3):
		var rect: Rect2 = view._piece_card_rect(i)
		assert(rect.size.y >= 95.0)
		assert(rect.position.x >= Game.DOCK_SHAPES.position.x)
		assert(rect.end.x <= Game.DOCK_SHAPES.end.x)
		assert(rect.position.y >= Game.DOCK_SHAPES.position.y)
		assert(rect.end.y <= Game.DOCK_SHAPES.end.y)
		assert(rect.end.y + 12.0 <= Game.LEFT_RECT.position.y)
		assert(not rect.intersects(Game.LEFT_RECT))
		assert(not rect.intersects(Game.RIGHT_RECT))
		assert(not rect.intersects(Game.BOOST_BOMB))
		assert(not rect.intersects(Game.BOOST_REROLL))
		for previous in cards:
			assert(not rect.intersects(previous))
		cards.append(rect)

	# Rotate and consumable inputs cannot overlap, including both columns.
	assert(not Game.LEFT_RECT.intersects(Game.RIGHT_RECT))
	assert(not Game.BOOST_BOMB.intersects(Game.BOOST_REROLL))
	for turn in [Game.LEFT_RECT,Game.RIGHT_RECT]:
		for boost in [Game.BOOST_BOMB,Game.BOOST_REROLL]:
			assert(not turn.intersects(boost))
	for rect in cards + [Game.LEFT_RECT,Game.RIGHT_RECT,Game.BOOST_BOMB,Game.BOOST_REROLL]:
		assert(rect.position.x >= 0.0)
		assert(rect.position.y >= 0.0)
		assert(rect.end.x <= Game.BASE.x)
		assert(rect.end.y <= Game.BASE.y)
	# A purchasable collection uses a compact 2x2 touch-safe gallery.
	var shop_view = Game.new()
	shop_view.shop_tab = 1
	assert(shop_view._shop_pages() == 6)
	assert(shop_view._shop_items().size() == 4)
	var store_cards: Array = []
	for i in range(4):
		var rect: Rect2 = shop_view._shop_card(i)
		assert(rect.position.x >= 70 and rect.end.x <= 650)
		assert(rect.position.y >= 480 and rect.end.y <= 955)
		for previous in store_cards:
			assert(not rect.intersects(previous))
		store_cards.append(rect)
	shop_view.shop_page = 5
	assert(shop_view._shop_items().size() == 3)
	shop_view.language = "pl"
	assert(shop_view.analytics_erase_label() == "USUŃ DANE ANALITYKI")
	shop_view.language = "en"
	assert(shop_view.analytics_erase_label() == "CLEAR ANALYTICS DATA")
	assert(Game.FREE_PLAY_BETA)
	assert(shop_view.badge_t("first_drop") == "FIRST DROP")
	assert(shop_view.badge_icon("streak_7") == "heart")
	assert(shop_view.badge_icon("score_10000") == "coins")
	shop_view.language = "pl"
	assert(shop_view.badge_t("combo_4") == "KASKADA ×4")
	shop_view.free()
	# Hit mapping still fits the new cell coordinate system.
	assert(view._board_cell(Game.BOARD.position + Vector2(3.0,3.0)) == Vector2i(0,0))
	assert(view._board_cell(Game.BOARD.end - Vector2(3.0,3.0)) == Vector2i(7,7))
	assert(view._board_cell(Game.BOARD.position - Vector2(2,2)).x == -1)
	view.free()
	print("PASS: separated shape, rotate and power-up targets; board and HUD bounds")
	quit()
