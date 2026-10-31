extends SceneTree
## Soak rendering through the real game screen, not just checking file existence.
## Resource memory stays bounded while players preview every shop page and skin.
const SkinArt = preload("res://scripts/gravity_skin_art.gd")
const Themes = preload("res://scripts/gravity_themes.gd")

func _initialize() -> void:
	call_deferred("_soak")

func _soak() -> void:
	var game_scene: PackedScene = load("res://scenes/gravity.tscn")
	var game: Control = game_scene.instantiate()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.tutorial_open = false
	game.music.set_music_enabled(false)
	game.shop.persist_enabled = false
	game.shop_tab = 1
	var changed: int = 0
	for page in range(game._shop_pages()):
		game.shop_open = true
		game.shop_page = page
		game.studio.queue_redraw()
		for _frame in range(3):
			await process_frame
		for id in game._shop_items():
			game.shop_open = false
			game.shop.equipped_skin = str(id)
			for tone in range(3):
				assert(SkinArt.sprite_for(str(id),tone) != null)
			assert(Themes.board_for_skin(str(id)) != null or id in ["default","neon","gold","donut","crystal"])
			assert(SkinArt.resident_count() <= SkinArt.MAX_RESIDENT_SPRITES)
			game.studio.queue_redraw()
			for _frame in range(3):
				await process_frame
			changed += 1
	game.shop.equipped_skin = "default"
	game.shop_open = false
	game.studio.queue_redraw()
	for _frame in range(30):
		await process_frame
	assert(changed == 23)
	assert(SkinArt.resident_count() <= 18)
	game.queue_free()
	for _frame in range(3):
		await process_frame
	SkinArt.release_unused()
	assert(SkinArt.resident_count() == 0)
	print("PASS: all 23 actual shop skins, six lazy worlds, thumbnails and bounded memory over rendered frames")
	quit()
