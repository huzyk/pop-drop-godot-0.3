extends Node
## Original, procedural game cues. No external audio files, SDKs or music.
## Short PCM samples are generated only on startup, not during gameplay.
const PREFS := "user://gravity_feedback_v1.json"
const RATE := 22050
const VOICE_COUNT := 5
const CUES := {
	"tap": 0.060,
	"drop": 0.120,
	"rotate": 0.165,
	"pop": 0.195,
	"cascade": 0.255,
	"mission": 0.565,
	"level": 0.880,
	"fail": 0.320
}
const VIBRATIONS := {
	"tap": [0,0.0],
	"drop": [9,0.25],
	"rotate": [14,0.32],
	"pop": [24,0.50],
	"cascade": [35,0.62],
	"mission": [30,0.48],
	"level": [50,0.72],
	"fail": [48,0.50]
}
var sound_enabled: bool = true
var haptics_enabled: bool = true
var persist_enabled: bool = true
var streams: Dictionary = {}
var voices: Array = []
var cursor: int = 0
var last_played: Dictionary = {}

func _ready() -> void:
	_load_preferences()
	for key in CUES.keys():
		streams[key] = _render_cue(str(key))
	for i in range(VOICE_COUNT):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.volume_db = -5.0
		add_child(player)
		voices.append(player)

func set_sound_enabled(value: bool) -> void:
	sound_enabled = value
	if not value:
		for player in voices:
			player.stop()
	_save_preferences()

func set_haptics_enabled(value: bool) -> void:
	haptics_enabled = value
	_save_preferences()

func cue(name: String, pitch_multiplier: float = 1.0) -> void:
	if not CUES.has(name):
		return
	if not sound_enabled and not haptics_enabled:
		return
	var now: int = Time.get_ticks_msec()
	var last: int = int(last_played.get(name, -100000))
	if now-last < 65:
		return
	last_played[name] = now
	if sound_enabled and not voices.is_empty():
		var player: AudioStreamPlayer = voices[cursor]
		cursor = (cursor+1) % voices.size()
		player.stop()
		player.stream = streams[name]
		# Ascending pitch makes consecutive successful POP actions feel faster.
		player.pitch_scale = clampf(pitch_multiplier,0.8,1.4)
		player.play()
	if haptics_enabled and (OS.get_name() == "Android" or OS.get_name() == "iOS"):
		var spec: Array = VIBRATIONS[name]
		var duration_ms: int = int(spec[0])
		if duration_ms > 0:
			Input.vibrate_handheld(duration_ms, float(spec[1]))

func _render_cue(name: String) -> AudioStreamWAV:
	var duration: float = float(CUES[name])
	var count: int = maxi(2,int(duration*RATE))
	var data: PackedByteArray = PackedByteArray()
	data.resize(count*2)
	for i in range(count):
		var t: float = float(i)/float(RATE)
		var u: float = t/duration
		var attack: float = minf(1.0, t/0.007)
		var envelope: float = attack * pow(1.0-u,2.3)
		var pitch: float = 400.0
		var amplitude: float = 0.20
		var sample: float = 0.0
		match name:
			"tap":
				pitch = lerpf(850.0,1150.0,u)
				amplitude = 0.09
				sample = sin(TAU*pitch*t)
			"drop":
				pitch = lerpf(178.0,75.0,u)
				amplitude = 0.24
				sample = 0.84*sin(TAU*pitch*t)+0.16*sin(TAU*pitch*2.0*t)
			"rotate":
				pitch = lerpf(230.0,610.0,u)
				amplitude = 0.17
				sample = sin(TAU*pitch*t)+0.16*sin(TAU*2.0*pitch*t)
			"pop":
				pitch = lerpf(420.0,1040.0,u)
				amplitude = 0.30
				sample = 0.7*sin(TAU*pitch*t)+0.3*sin(TAU*1.49*pitch*t)
			"cascade":
				pitch = lerpf(580.0,1260.0,u)
				amplitude = 0.24
				sample = 0.66*sin(TAU*pitch*t)+0.28*sin(TAU*(pitch*1.5)*t)
			"mission":
				var notes: Array = [523.25,659.25,783.99]
				pitch = float(notes[mini(2,int(u*3.0))])
				amplitude = 0.20
				sample = sin(TAU*pitch*t)+0.14*sin(TAU*pitch*2.0*t)
			"level":
				var notes: Array = [523.25,659.25,783.99,1046.50]
				pitch = float(notes[mini(3,int(u*4.0))])
				amplitude = 0.23
				sample = sin(TAU*pitch*t)+0.22*sin(TAU*pitch*1.5*t)
			"fail":
				pitch = lerpf(350.0,125.0,u)
				amplitude = 0.20
				sample = sin(TAU*pitch*t)+0.15*sin(TAU*pitch*0.5*t)
		# Very short event sounds, not continuous music. Avoid clipped PCM.
		var value: float = clampf(sample*amplitude*envelope,-0.96,0.96)
		data.encode_s16(i*2,int(round(value*32767.0)))
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.mix_rate = RATE
	stream.stereo = false
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.data = data
	return stream

func _load_preferences() -> void:
	if not FileAccess.file_exists(PREFS):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PREFS))
	if parsed is Dictionary:
		sound_enabled = bool(parsed.get("sound",true))
		haptics_enabled = bool(parsed.get("haptics",true))

func _save_preferences() -> void:
	if not persist_enabled:
		return
	var file: FileAccess = FileAccess.open(PREFS,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"sound":sound_enabled,"haptics":haptics_enabled}))
		file.close()
