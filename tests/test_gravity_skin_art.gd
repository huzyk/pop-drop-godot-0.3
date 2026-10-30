extends SceneTree
## Regression: vector Jelly Pals pack, free re-equip, and shop entry.
const SkinArt = preload("res://scripts/gravity_skin_art.gd")
const Game = preload("res://scripts/gravity_game.gd")
const Shop = preload("res://scripts/gravity_shop.gd")

func _initialize() -> void:
	assert(SkinArt.is_authored("default"))
	assert(not SkinArt.is_authored("capybara"))
	for color in range(3):
		var texture: Texture2D = SkinArt.sprite_for("default",color)
		assert(texture != null)
		assert(texture.get_size() == Vector2(256,256))
		assert(Game.MARBLE_TEXTURES[color] != null)
	assert(SkinArt.sprite_for("unknown",0) == null)
	var wallet = Shop.new()
	wallet.persist_enabled = false
	wallet.equipped_skin = "neon"
	assert(wallet.equip_skin("default"))
	assert(wallet.equipped_skin == "default")
	var game = Game.new()
	game.shop_tab = 1
	assert(game._shop_catalog()[0] == "default")
	assert(game._shop_items().has("default"))
	game.free()
	print("PASS: Jelly Pals SVGs import at 256 px, skin registry and free equip work")
	quit()
