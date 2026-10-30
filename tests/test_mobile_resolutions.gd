extends SceneTree
## Virtual Android phone sizes: same Godot painting and input transform must agree.
const Game = preload("res://scripts/gravity_game.gd")
const Studio = preload("res://scripts/gravity_studio.gd")

func _initialize() -> void:
	for skin in [Studio.MODAL_SHOP,Studio.MODAL_PROFILE,Studio.MODAL_SETTINGS,
		Studio.MODAL_OVER,Studio.MODAL_TUTORIAL]:
		assert(skin != null)
		assert(skin.get_size() == Game.BASE)
	for dimensions in [Vector2(320,568),Vector2(360,640),Vector2(360,800),
		Vector2(393,873),Vector2(412,915),Vector2(540,1200),
		Vector2(720,1280),Vector2(1080,2400)]:
		var game = Game.new()
		game.size = dimensions
		var s: float = game._scale()
		var offset: Vector2 = game._offset()
		assert(s > 0.4)
		assert(offset.x >= -0.01 and offset.y >= -0.01)
		assert(offset.x + Game.BASE.x*s <= dimensions.x + 0.01)
		assert(offset.y + Game.BASE.y*s <= dimensions.y + 0.01)
		for control in [Game.BOARD,Game.LEFT_RECT,Game.RIGHT_RECT,
			Game.BOOST_BOMB,Game.BOOST_REROLL,Game.SHOP_OPEN,
			Game.PROFILE_OPEN,Game.SETTINGS_OPEN,Game.TUTORIAL_ACK]:
			var center: Vector2 = control.get_center()
			var position: Vector2 = offset+center*s
			assert(position.x >= 0.0 and position.x <= dimensions.x)
			assert(position.y >= 0.0 and position.y <= dimensions.y)
			assert(game._logical(position).distance_to(center) < 0.03)
		assert(Game.LEFT_RECT.size.y*s > 55.0 if dimensions.x >= 360 else
			Game.LEFT_RECT.size.y*s > 50.0)
		game.free()
	print("PASS: eight portrait viewport ratios, authored modal artwork and precise transformed touch targets")
	quit()
