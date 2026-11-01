extends SceneTree
const Music = preload("res://scripts/gravity_music.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	# Exercise real worker completion, switching mid-render and destruction.
	var music = Music.new()
	music.persist_enabled = false
	root.add_child(music)
	music.set_music_enabled(true)
	music.set_theme("forest")
	var deadline: int = Time.get_ticks_msec()+15000
	while not music.streams.has("forest") and Time.get_ticks_msec()<deadline:
		await process_frame
	assert(music.streams.has("forest"))
	var stream: AudioStreamWAV = music.streams["forest"]
	assert(stream.data.size() == int(Music.RATE*Music.SECONDS)*2)
	assert(stream.loop_end == int(Music.RATE*Music.SECONDS))
	assert(stream.mix_rate == Music.RATE)
	music.set_music_enabled(false)
	assert(not music.player.playing)
	music.set_music_enabled(true)
	music.set_theme("fantasy")
	music.queue_free() # Joins an active worker safely.
	stream = null
	for _frame in range(3):
		await process_frame
	print("PASS: threaded PCM, main-thread audio resource, theme switch and teardown")
	quit()
