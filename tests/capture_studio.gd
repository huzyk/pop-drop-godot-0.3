extends SceneTree
## Real screenshots from Godot's viewport. Regressions must be inspected visually.
func _initialize() -> void:
	call_deferred("_capture")

func _save_frame(scene: Control, filename: String) -> bool:
	scene.queue_redraw()
	if scene.studio != null:
		scene.studio.queue_redraw()
	for _index in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = root.get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		push_error("No real frame for: "+filename)
		return false
	var result: Error = image.save_png("res://artifacts/"+filename)
	if result != OK:
		push_error("Screenshot not saved: "+filename)
		return false
	print("PASS: rendered %s at %dx%d" % [filename,image.get_width(),image.get_height()])
	return true

func _capture() -> void:
	var scene: PackedScene = load("res://scenes/gravity.tscn")
	var game: Control = scene.instantiate()
	root.add_child(game)
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for _index in range(10):
		await process_frame
	# Hide first-run tutorial only for the main game screenshot; render it explicitly.
	game.tutorial_open = false
	if not await _save_frame(game,"preview-phone.png"):
		quit(1)
		return
	game.shop_open = true
	game.shop_tab = 1
	if not await _save_frame(game,"preview-shop.png"):
		quit(1)
		return
	game.shop_page = game._shop_pages()-1
	if not await _save_frame(game,"preview-shop-fantasy.png"):
		quit(1)
		return
	game.shop_open = false
	game.shop.equipped_skin = "dragon"
	if not await _save_frame(game,"preview-fantasy.png"):
		quit(1)
		return
	game.shop.equipped_skin = "default"
	game.profile_open = true
	if not await _save_frame(game,"preview-profile.png"):
		quit(1)
		return
	game.profile_open = false
	game.settings_open = true
	if not await _save_frame(game,"preview-settings.png"):
		quit(1)
		return
	game.settings_open = false
	game.phase = "over"
	if not await _save_frame(game,"preview-over.png"):
		quit(1)
		return
	game.phase = "drop"
	game.tutorial_open = true
	if not await _save_frame(game,"preview-tutorial.png"):
		quit(1)
		return
	quit()
