extends Node
## Six original, seamless 8s instrumental loops for POP DROP worlds.
## Generated once per chosen habitat: no external music, samples or licenses.
const PREFS := "user://gravity_music_v1.json"
const RATE := 22050
const SECONDS := 8.0
const BEAT := 0.5
const LOOPS := {
	"classic":{"melody":[72,0,76,79,72,0,79,76,74,0,77,81,74,0,79,77],"bass":[48,48,55,55,53,53,55,55,50,50,57,57,55,55,48,48],"timbre":0.32,"drum":0.10},
	"jungle":{"melody":[76,79,0,83,79,76,74,0,76,83,79,86,0,79,74,76],"bass":[45,45,52,52,43,43,50,50,45,45,52,52,47,47,52,52],"timbre":0.63,"drum":0.28},
	"safari":{"melody":[69,0,72,76,0,72,69,67,69,0,76,79,76,72,69,0],"bass":[45,45,52,52,50,50,45,45,45,45,52,52,50,50,45,45],"timbre":0.48,"drum":0.34},
	"forest":{"melody":[72,0,74,0,79,0,76,0,72,0,67,0,71,0,74,0],"bass":[48,48,55,55,52,52,55,55,48,48,55,55,50,50,55,55],"timbre":0.21,"drum":0.05},
	"wetlands":{"melody":[74,0,77,81,0,79,77,0,74,0,72,77,79,0,74,0],"bass":[50,50,57,57,53,53,57,57,50,50,55,55,53,53,50,50],"timbre":0.58,"drum":0.15},
	"aviary":{"melody":[79,83,86,0,84,81,79,0,81,86,88,86,83,0,79,0],"bass":[55,55,62,62,57,57,62,62,55,55,62,62,59,59,55,55],"timbre":0.12,"drum":0.08},
	"fantasy":{"melody":[74,81,86,0,83,79,81,0,76,81,88,86,83,0,81,79],"bass":[50,50,57,57,53,53,57,57,50,50,57,57,53,53,50,50],"timbre":0.22,"drum":0.06}
}
const VOLUME_DB := [-30.0,-23.0,-17.0]
var music_enabled: bool = true
var volume_step: int = 1
var persist_enabled: bool = true
var theme: String = "classic"
var streams: Dictionary = {}
var player: AudioStreamPlayer
var render_thread: Thread = null
var rendering_theme: String = ""

func _ready() -> void:
	_load_prefs()
	player = AudioStreamPlayer.new()
	player.name = "WorldMusic"
	player.bus = "Master"
	add_child(player)
	_sync()

func _process(_delta: float) -> void:
	# Render new 8-second synth tracks in a worker rather than blocking the UI.
	if render_thread == null or render_thread.is_alive():
		return
	var completed: AudioStreamWAV = render_thread.wait_to_finish()
	render_thread = null
	if completed != null:
		streams[rendering_theme] = completed
	rendering_theme = ""
	_sync()

func _exit_tree() -> void:
	if render_thread != null:
		render_thread.wait_to_finish()
		render_thread = null

func _background_render(id: String) -> AudioStreamWAV:
	return _render_theme(id)

func set_theme(id: String) -> void:
	var next: String = id if LOOPS.has(id) else "classic"
	if theme == next and player != null and player.playing == music_enabled:
		return
	theme = next
	_sync()

func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	_sync()
	_save_prefs()

func cycle_volume() -> void:
	volume_step = (volume_step+1) % VOLUME_DB.size()
	_sync()
	_save_prefs()

func volume_label() -> String:
	return ["CICHO","ŚREDNIO","GŁOŚNO"][volume_step]

func _sync() -> void:
	if player == null:
		return
	player.volume_db = VOLUME_DB[volume_step]
	if not music_enabled:
		player.stop()
		return
	if not streams.has(theme):
		if render_thread == null:
			rendering_theme = theme
			render_thread = Thread.new()
			var error: Error = render_thread.start(Callable(self,"_background_render").bind(theme))
			if error != OK:
				render_thread = null
				streams[theme] = _render_theme(theme) # Safe fallback if threads unavailable.
		return
	var next: AudioStreamWAV = streams[theme]
	if player.stream != next:
		player.stop()
		player.stream = next
	if not player.playing:
		player.play()

static func _frequency(midi: int) -> float:
	return 440.0*pow(2.0,(float(midi)-69.0)/12.0)

static func _render_theme(id: String) -> AudioStreamWAV:
	var spec: Dictionary = LOOPS.get(id,LOOPS["classic"])
	var melody: Array = spec["melody"]
	var bass: Array = spec["bass"]
	var frequencies: Array = []
	var bass_frequencies: Array = []
	for note in melody:
		frequencies.append(_frequency(int(note)) if int(note)>0 else 0.0)
	for note in bass:
		bass_frequencies.append(_frequency(int(note)))
	var count: int = int(SECONDS*RATE)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(count*2)
	var timbre: float = float(spec["timbre"])
	var drums: float = float(spec["drum"])
	for i in range(count):
		var t: float = float(i)/float(RATE)
		var position: float = t/BEAT
		var step: int = mini(15,int(position))
		var local: float = position-float(step)
		var freq: float = float(frequencies[step])
		var bass_hz: float = float(bass_frequencies[step])
		var note_env: float = pow(1.0-local,1.55)*minf(1.0,local*24.0)
		var lead: float = (sin(TAU*freq*(t-float(step)*BEAT))
			+ sin(TAU*freq*1.995*(t-float(step)*BEAT))*.16
			+ sin(TAU*freq*2.994*(t-float(step)*BEAT))*timbre*.14)*note_env if freq>0.0 else 0.0
		var bass_voice: float = (sin(TAU*bass_hz*t)+.14*sin(TAU*bass_hz*2.0*t))*.20
		var kick: float = 0.0
		if step%2==0:
			kick = sin(TAU*(70.0-42.0*local)*local*BEAT)*pow(1.0-local,9.0)*drums
		var shaker: float = 0.0
		if (step%2)==1 or (id=="jungle" and step%2==0):
			shaker = (sin(float(i)*1.483)+sin(float(i)*2.793))*.065*drums*pow(1.0-local,5.0)
		var fade: float = minf(1.0,minf(t/.028,(SECONDS-t)/.03))
		var sample: float = (lead*.25+bass_voice+kick+shaker)*clampf(fade,0.0,1.0)
		bytes.encode_s16(i*2,int(round(clampf(sample,-.92,.92)*32767.0)))
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.mix_rate = RATE
	stream.stereo = false
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = count
	stream.data = bytes
	return stream

func _load_prefs() -> void:
	if not FileAccess.file_exists(PREFS):
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PREFS))
	if data is Dictionary:
		music_enabled = bool(data.get("enabled",true))
		volume_step = clampi(int(data.get("volume_step",1)),0,2)

func _save_prefs() -> void:
	if not persist_enabled:
		return
	var file: FileAccess = FileAccess.open(PREFS,FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"enabled":music_enabled,"volume_step":volume_step}))
		file.close()
