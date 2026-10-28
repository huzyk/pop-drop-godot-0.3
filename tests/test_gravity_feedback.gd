extends SceneTree
const Feedback = preload("res://scripts/gravity_feedback.gd")
const Game = preload("res://scripts/gravity_game.gd")

func _initialize() -> void:
	var game = Game.new()
	assert(game != null)
	game.free()
	var feedback = Feedback.new()
	feedback.persist_enabled = false
	root.add_child(feedback)
	assert(feedback.CUES.size() == 8)
	assert(feedback.voices.size() == feedback.VOICE_COUNT)
	for key in feedback.CUES.keys():
		var wav: AudioStreamWAV = feedback.streams[key]
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
	feedback.cue("tap")
	feedback.cue("not_an_event")
	feedback.free()
	print("PASS: Sound cue synthesis, preference toggles, disabled haptics and game parse")
	quit()
