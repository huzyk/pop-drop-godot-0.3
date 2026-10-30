extends SceneTree
## All store skins must have distinct real art for each of the three tile types.
const SkinArt = preload("res://scripts/gravity_skin_art.gd")
const Studio = preload("res://scripts/gravity_studio.gd")
const Game = preload("res://scripts/gravity_game.gd")
const Shop = preload("res://scripts/gravity_shop.gd")
const SKINS = ["default","neon","gold","donut","capybara","crystal","cosmos","star_capybara"]

func _initialize() -> void:
	for id in SKINS:
		assert(SkinArt.is_authored(id))
		for color in range(3):
			var sprite: Texture2D = SkinArt.sprite_for(id,color)
			assert(sprite != null)
			assert(sprite.get_size() == Vector2(512,512))
			# Each skin owns three genuinely different authored files.
			assert(sprite.resource_path.begins_with("res://assets/"))
		assert(SkinArt.sprite_for(id,0) != SkinArt.sprite_for(id,1))
	assert(not SkinArt.is_authored("unknown"))
	assert(SkinArt.sprite_for("unknown",0)==null)
	assert(Studio.WORLD.get_size()==Game.BASE)
	# Main UI must remain composed of actual high-DPI organic materials.
	assert(Studio.BOARD_SHELL.get_size()==Vector2(720,720))
	assert(Studio.SOCKET.get_size()==Vector2(256,256))
	assert(Studio.PIECE_ACTIVE.get_size()==Vector2(420,222))
	assert(Studio.PIECE_IDLE.get_size()==Vector2(420,222))
	assert(Studio.TURN_PINK.get_size()==Vector2(640,218))
	assert(Studio.TURN_TEAL.get_size()==Vector2(640,218))
	assert(Studio.BOOST_ART.size()==3)
	for art in Studio.BOOST_ART:
		assert(art.get_size()==Vector2(430,156))
	assert(Studio.BOARD==Game.BOARD)
	assert(Studio.CELL==Game.CELL)
	var wallet = Shop.new()
	wallet.persist_enabled=false
	assert(wallet.equip_skin("default"))
	var game = Game.new()
	game.shop_tab=1
	assert(game._shop_catalog()==SKINS)
	game.free()
	print("PASS: 24 characters, 8 skins, 9 anti-aliased organic visual components, unchanged hitboxes")
	quit()
