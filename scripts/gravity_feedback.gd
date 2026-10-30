extends Node
## Original, procedural game cues. No external audio files, SDKs or music.
## Short PCM samples are generated only on startup, not during gameplay.
const PREFS := "user://gravity_feedback_v1.json"
const RATE := 22050
const VOICE_COUNT := 8
const CUES := {
	"tap": 0.065,
	"drop": 0.170,
	"rotate": 0.260,
	"pop": 0.260,
	"big_pop": 0.420,
	"cascade": 0.480,
	"rock_hit": 0.220,
	"rock_break": 0.570,
	"bomb": 0.510,
	"surge": 0.480,
	"mission": 0.565,
	"level": 0.880,
	"fail": 0.360
}
const VIBRATIONS := {
	"tap": [0,0.0],
	"drop": [10,0.28],
	"rotate": [12,0.32],
	"pop": [19,0.51],
	"big_pop": [32,0.70],
	"cascade": [39,0.82],
	"rock_hit": [29,0.63],
	"rock_break": [65,0.85],
	"bomb": [70,0.90],
	"surge": [32,0.57],
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
		player.volume_db = -8.0
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
		# Layer a soft tonal body, a transient, and a deterministic textured
		# component: more tactile than one plain oscillator per event.
		var noise: float = 2.0*fposmod(sin(float(i)*12.9898+78.233)*43758.5453,1.0)-1.0
		var transient: float = pow(1.0-u,9.0)
		var pitch: float = 400.0
		var amplitude: float = 0.20
		var sample: float = 0.0
		match name:
			"tap":
				pitch = lerpf(830.0,1180.0,u)
				amplitude = 0.07
				sample = sin(TAU*pitch*t)+noise*transient*.14
			"drop":
				pitch = lerpf(205.0,67.0,u)
				amplitude = 0.28
				sample = .80*sin(TAU*pitch*t)+.17*sin(TAU*2.0*pitch*t)+noise*transient*.29
			"rotate":
				pitch = lerpf(245.0,685.0,u)
				amplitude = 0.15
				sample = .56*sin(TAU*pitch*t)+.18*sin(TAU*1.51*pitch*t)+noise*.24*sin(PI*u)
			"pop":
				pitch = lerpf(350.0,1180.0,u)
				amplitude = 0.28
				sample = .58*sin(TAU*pitch*t)+.20*sin(TAU*1.69*pitch*t)+.22*sin(TAU*(134.0-66.0*u)*t)+noise*transient*.21
			"big_pop":
				pitch = lerpf(255.0,1375.0,u)
				amplitude = 0.35
				sample = .43*sin(TAU*pitch*t)+.18*sin(TAU*1.51*pitch*t)+.28*sin(TAU*(122.0-67.0*u)*t)+noise*transient*.33
			"cascade":
				var step_tone: float = float(mini(3,int(u*4.0)))
				pitch = 520.0+step_tone*190.0+140.0*u
				amplitude = 0.29
				sample = .60*sin(TAU*pitch*t)+.19*sin(TAU*1.49*pitch*t)+.15*sin(TAU*112.0*t)+noise*transient*.23
			"rock_hit":
				pitch = lerpf(180.0,78.0,u)
				amplitude = 0.32
				sample = .61*sin(TAU*pitch*t)+.14*sin(TAU*2.77*pitch*t)+noise*(.60*transient+.12)
			"rock_break":
				pitch = lerpf(165.0,52.0,u)
				amplitude = 0.34
				var grit: float = noise*(.65*pow(1.0-u,1.3)+.22*absf(sin(u*13.0*PI)))
				sample = .56*sin(TAU*pitch*t)+.19*sin(TAU*2.1*pitch*t)+grit
			"bomb":
				pitch = lerpf(102.0,36.0,u)
				amplitude = 0.38
				sample = .73*sin(TAU*pitch*t)+noise*(.62*pow(1.0-u,1.7)+.14)+.10*sin(TAU*2.2*pitch*t)
			"surge":
				pitch = lerpf(310.0,730.0,u)
				amplitude = 0.23
				sample = .49*sin(TAU*pitch*t)+.30*sin(TAU*(pitch*1.53)*t)+noise*.22*sin(PI*u)
			"mission":
				var notes: Array = [523.25,659.25,783.99]
				pitch = float(notes[mini(2,int(u*3.0))])
				amplitude = 0.19
				sample = sin(TAU*pitch*t)+.14*sin(TAU*pitch*2.0*t)
			"level":
				var notes: Array = [523.25,659.25,783.99,1046.50]
				pitch = float(notes[mini(3,int(u*4.0))])
				amplitude = 0.22
				sample = sin(TAU*pitch*t)+.20*sin(TAU*pitch*1.5*t)
			"fail":
				pitch = lerpf(315.0,105.0,u)
				amplitude = 0.20
				sample = sin(TAU*pitch*t)+.15*sin(TAU*pitch*.5*t)+noise*transient*.08
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
