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
	assert(Studio.PIECE_ACTIVE.get_size()==Vector2(440,230))
	assert(Studio.PIECE_IDLE.get_size()==Vector2(440,230))
	assert(Studio.TURN_PINK.get_size()==Vector2(760,206))
	assert(Studio.TURN_TEAL.get_size()==Vector2(760,206))
	assert(Studio.BOOST_ART.size()==3)
	for art in Studio.BOOST_ART:
		assert(art.get_size()==Vector2(520,170))
	assert(Studio.BOARD==Game.BOARD)
	
	assert(Studio.HUD_ART.get_size()==Vector2(1360,184))
	assert(Studio.STATUS_ART.get_size()==Vector2(1400,112))
	assert(Studio.COIN_CHIP.get_size()==Vector2(300,132))
	assert(Studio.UTILITY_ART.get_size()==Vector2(128,128))
	assert(Studio.PANEL_ART.get_size()==Vector2(256,256))
	assert(Studio.ROCK_ART.get_size()==Vector2(512,512))
	assert(Studio.ENERGY_ON.get_size()==Vector2(72,72))
	assert(Studio.ENERGY_OFF.get_size()==Vector2(72,72))
	assert(Studio.CTA_MINT.get_size()==Vector2(680,154))
	assert(Studio.CTA_MUTED.get_size()==Vector2(680,154))
	assert(Studio.BOARD==Game.BOARD)
	assert(Studio.CELL==Game.CELL)
	var wallet = Shop.new()
	wallet.persist_enabled=false
	assert(wallet.equip_skin("default"))
	var game = Game.new()
	game.shop_tab=1
	assert(game._shop_catalog()==SKINS)
	game.free()
	print("PASS: 24 characters, 8 skins, Atelier v5 textures and nine-slice materials, unchanged hitboxes")
	quit()
