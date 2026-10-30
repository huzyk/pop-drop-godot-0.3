extends SceneTree
## Guard art-direction assets and gameplay touch targets against accidental regressions.
const Game = preload("res://scripts/gravity_game.gd")
const Illustrated = preload("res://scripts/gravity_illustrated.gd")

func _initialize() -> void:
	assert(Illustrated.SCENE_ART != null)
	assert(Illustrated.CLEAN_OVERLAY != null)
	assert(Illustrated.CLEAN_OVERLAY.get_size() == Game.BASE)
	# The painted old life HUD must be masked fully, with no off-frame pill.
	var hud_overlay: Image = Illustrated.CLEAN_OVERLAY.get_image()
	assert(hud_overlay.get_pixel(607,220).a > 0.95)
	assert(hud_overlay.get_pixel(575,243).a > 0.95)
	assert(hud_overlay.get_pixel(610,265).a > 0.95)
	assert(hud_overlay.get_pixel(698,242).a < 0.05)
	assert(Illustrated.SCENE_ART.get_size()==Vector2(941,1672))
	assert(Illustrated.SELECTED_CARD.get_size()==Vector2(386,278))
	for sprite in [Illustrated.GLASS_PINK,Illustrated.GLASS_GREEN,
		Illustrated.GLASS_BLUE,Illustrated.STONE]:
		assert(sprite.get_size()==Vector2(256,256))
		var pixels: Image = sprite.get_image()
		assert(pixels.get_pixel(0,0).a < 0.04)
		assert(pixels.get_pixel(128,128).a > 0.9)
	for width in range(1,6):
		for height in range(1,6):
			var span := Vector2i(width,height)
			var metrics: Vector2 = Illustrated.preview_metrics(span)
			assert(float(height-1)*metrics.x+2.0*metrics.y <= 83.0)
			assert(float(width-1)*metrics.x+2.0*metrics.y <= 145.0)
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
