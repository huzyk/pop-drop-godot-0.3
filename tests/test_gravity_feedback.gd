extends SceneTree
const Feedback = preload("res://scripts/gravity_feedback.gd")
const Game = preload("res://scripts/gravity_game.gd")

func _initialize() -> void:
	var game = Game.new()
	assert(game != null)
	game.free()
	var feedback = Feedback.new()
	feedback.persist_enabled = false
	# Avoid invoking AudioServer playback in a headless test.
	# The main-scene CI smoke test covers lifecycle initialization.
	assert(feedback.CUES.size() == 8)
	for key in feedback.CUES.keys():
		var wav: AudioStreamWAV = feedback._render_cue(str(key))
		assert(wav.format == AudioStreamWAV.FORMAT_16_BITS)
		assert(wav.mix_rate == feedback.RATE)
		assert(not wav.stereo)
		var expected: int = maxi(2,int(float(feedback.CUES[key])*float(feedback.RATE)))*2
		assert(wav.data.size() == expected)
	feedback.set_sound_enabled(false)
	assert(not feedback.sound_enabled)
	feedback.set_haptics_enabled(false)
	assert(not feedback.haptics_enabled)
	feedback.cue("level") # Silent; never triggers vibration.
	feedback.set_sound_enabled(true)
	assert(feedback.sound_enabled)
	feedback.set_sound_enabled(false)
	feedback.cue("tap")
	feedback.cue("not_an_event")
	feedback.free()
	print("PASS: Sound cue synthesis, preference toggles, disabled haptics and game parse")
	quit()
