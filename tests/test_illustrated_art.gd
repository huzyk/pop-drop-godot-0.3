extends SceneTree
## Guard art-direction assets and gameplay touch targets against accidental regressions.
const Game = preload("res://scripts/gravity_game.gd")
const Illustrated = preload("res://scripts/gravity_illustrated.gd")

func _initialize() -> void:
	assert(Illustrated.SHELL.get_size() == Game.BASE)
	var shell: Image = Illustrated.SHELL.get_image()
	assert(shell.get_pixel(607,220).a > 0.95)
	assert(shell.get_pixel(360,550).a > 0.95)
	assert(Illustrated.STONE.get_size() == Vector2(256,256))
	for width in range(1,6):
		for height in range(1,6):
			var span := Vector2i(width,height)
			var metrics: Vector2 = Illustrated.preview_metrics(span)
			assert(float(height-1)*metrics.x+2.0*metrics.y <= 83.0)
			assert(float(width-1)*metrics.x+2.0*metrics.y <= 145.0)
	# Rocks have three visible health states and their own destruction effect.
	var stone_test = Illustrated.new()
	assert(stone_test.has_method("_draw_rock_damage"))
	assert(stone_test.has_method("_rock_crack"))
	assert(stone_test.has_method("_draw_fx"))
	stone_test.free()
	assert(Game.BOARD==Illustrated.BOARD)
	assert(Game.CELL==Illustrated.CELL)
	assert(Game.BOARD.position==Vector2(88,292))
	assert(Game.BOARD.size==Vector2(536,536))
	var view = Game.new()
	for i in range(3):
		var hit: Rect2 = view._piece_card_rect(i)
		assert(Game.DOCK_SHAPES.encloses(hit))
		assert(not hit.intersects(Game.LEFT_RECT))
		assert(not hit.intersects(Game.BOOST_BOMB))
		assert(not hit.intersects(Game.BOOST_REROLL))
	assert(Game.LEFT_RECT.position.x < Game.BOOST_BOMB.position.x)
	assert(Game.BOOST_REROLL.end.x < Game.RIGHT_RECT.position.x)
	view.free()
	print("PASS: illustrated reference, four 256px alpha sprites and aligned gameplay hitboxes")
	quit()

