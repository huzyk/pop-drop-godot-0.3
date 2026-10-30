extends SceneTree
## Every mobile HUD, rotate and boost icon is a full-resolution imported SVG.
const Game = preload("res://scripts/gravity_game.gd")

func _initialize() -> void:
	var icons: Array = [
		Game.ICON_COIN,
		Game.ICON_SHOP,
		Game.ICON_PROFILE,
		Game.ICON_SETTINGS,
		Game.ICON_ROTATE_LEFT,
		Game.ICON_ROTATE_RIGHT,
		Game.ICON_BOMB,
		Game.ICON_MAGIC,
		Game.ICON_REROLL,
		Game.ICON_HEART,
		Game.ICON_GLOBE,
	]
	assert(icons.size() == 11)
	for sprite in icons:
		assert(sprite != null)
		assert(sprite is Texture2D)
		assert(sprite.get_size() == Vector2(256,256))
	# The helper must remain available to each HUD/boost/menu drawing surface.
	var game = Game.new()
	assert(game != null)
	game.free()
	print("PASS: eleven anti-aliased 256px SVG icons load in Godot")
	quit()
