extends SceneTree
## Capture real Godot-rendered frame at the reference phone resolution.
## Run under xvfb with compatibility renderer, not --headless.
func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	var scene: PackedScene = load("res://scenes/gravity.tscn")
	var playable: Control = scene.instantiate()
	root.add_child(playable)
	playable.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for i in range(14):
		await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = root.get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		push_error("No rendered screenshot could be captured")
		quit(1)
		return
	var save_to: String = "res://artifacts/preview-phone.png"
	var code: Error = image.save_png(save_to)
	if code != OK:
		push_error("Failed saving preview: %d" % code)
		quit(1)
		return
	print("PASS: saved actual Godot-rendered preview at %dx%d" % [image.get_width(),image.get_height()])
	quit()
