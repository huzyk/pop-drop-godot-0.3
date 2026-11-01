extends SceneTree
const Copy = preload("res://scripts/gravity_copy.gd")
const Game = preload("res://scripts/gravity_game.gd")
const Shop = preload("res://scripts/gravity_shop.gd")

func _initialize() -> void:
	var game = Game.new()
	for language in Game.LOCALES:
		game.language = language
		assert(Copy.TEXT.has(language))
		for key in Copy.TEXT["en"]:
			assert(Copy.TEXT[language].has(key))
			assert(not Copy.text(language,key).is_empty())
		for offer in Shop.ITEMS:
			var id: String = offer.id
			assert(game.shop_t(id) != id)
			assert(game.shop_t(id+"_desc") != id+"_desc")
	game.free()
	print("PASS: live HUD, skin names, descriptions and badges for all seven selectable languages")
	quit()
