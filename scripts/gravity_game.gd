extends Control
## POP DROP Gravity / isolated gameplay experiment. NO real ads in this scene.
const Rules = preload("res://scripts/gravity_rules.gd")
const Session = preload("res://scripts/gravity_session.gd")
const Telemetry = preload("res://scripts/gravity_telemetry.gd")
const Ads = preload("res://scripts/gravity_ads.gd")
const Progression = preload("res://scripts/gravity_progression.gd")
const Feedback = preload("res://scripts/gravity_feedback.gd")
const FONT = preload("res://fonts/ClearSans-Regular.ttf")
const BOLD = preload("res://fonts/ClearSans-Bold.ttf")
# Artist-authored vector sprites imported as textures by Godot (no more circle stacks).
const MARBLE_TEXTURES = [
	preload("res://assets/marbles/coral.svg"),
	preload("res://assets/marbles/mint.svg"),
	preload("res://assets/marbles/blue.svg")
]
const BASE := Vector2(720,1280)
const BOARD := Rect2(44,274,632,632)
const CELL := 79.0
const COLORS := [Color("#ff7096"),Color("#55dcad"),Color("#62b5ff")]
const SAVE_FILE := "user://pop_drop_gravity.json"
const LOCALES := ["pl","en","es","pt","de","fr","ru"]
const TR := {
	"pl":{"life":"ŻYCIA","tap_short":"DOTKNIJ KOLUMNY","score":"WYNIK","best":"REKORD","move":"RUCH","drop":"DOTKNIJ KOLUMNĘ, ABY ZRZUCIĆ","turn":"OBRÓĆ PLANSZĘ LUB GRAJ DALEJ","left":"W LEWO","right":"W PRAWO","skip":"DALEJ","next":"WYBIERZ KSZTAŁT","ready":"5 KULEK POŁĄCZONYCH BOKAMI = POP  •  GÓRA = -1 ŻYCIE","over":"KONIEC RUNDY","again":"ZAGRAJ PONOWNIE","rescue":"TEST: +1 ŻYCIE","lost":"STRATA ŻYCIA","rotate_controls":"OBRACAJ PRZYCISKAMI PONIŻEJ","rotate_help":"SPRÓBUJ OBRÓCIĆ PLANSZĘ","charge":"GRUPA","danger":"WYSOKOŚĆ","danger_soon":"UWAGA: GÓRNA LINIA!","overflow":"UTRATA ŻYCIA!","hint":"Wybierz kolumnę dla spadającego kształtu"},
	"en":{"life":"LIVES","tap_short":"TAP A COLUMN","score":"SCORE","best":"BEST","move":"MOVE","drop":"TAP A COLUMN TO DROP","turn":"ROTATE OR KEEP GOING","left":"LEFT","right":"RIGHT","skip":"NEXT","next":"CHOOSE A SHAPE","ready":"5 TOUCHING BALLS = POP  •  TOP = -1 LIFE","over":"GAME OVER","again":"PLAY AGAIN","rescue":"TEST: +1 LIFE","lost":"LIFE LOST","rotate_controls":"ROTATE WITH THE BUTTONS BELOW","rotate_help":"ROTATE TO MAKE ROOM","charge":"GROUP","danger":"HEIGHT","danger_soon":"CAREFUL: TOP ROW!","overflow":"LIFE LOST!","hint":"Choose a column for the falling piece"},
	"es":{"life":"VIDAS","tap_short":"TOCA COLUMNA","score":"PUNTOS","best":"RÉCORD","move":"JUGADA","drop":"TOCA UNA COLUMNA PARA SOLTAR","turn":"GIRA O CONTINÚA","left":"IZQUIERDA","right":"DERECHA","skip":"SEGUIR","next":"ELIGE UNA FIGURA","ready":"5 BOLAS CONECTADAS = POP  •  ARRIBA = -1 VIDA","over":"FIN DEL JUEGO","again":"JUGAR OTRA VEZ","rescue":"PRUEBA: +1 VIDA","lost":"VIDA PERDIDA","rotate_controls":"USA LOS BOTONES PARA GIRAR","rotate_help":"GIRA PARA HACER ESPACIO","charge":"GRUPO","danger":"ALTURA","danger_soon":"¡FILA SUPERIOR!","overflow":"¡VIDA PERDIDA!","hint":"Elige una columna para las bolas"},
	"pt":{"life":"VIDAS","tap_short":"TOQUE A COLUNA","score":"PONTOS","best":"RECORDE","move":"JOGADA","drop":"TOQUE NA COLUNA PARA SOLTAR","turn":"GIRE OU CONTINUE","left":"ESQUERDA","right":"DIREITA","skip":"SEGUIR","next":"ESCOLHA UMA PEÇA","ready":"5 BOLAS CONECTADAS = POP  •  TOPO = -1 VIDA","over":"FIM DE JOGO","again":"JOGAR DE NOVO","rescue":"TESTE: +1 VIDA","lost":"VIDA PERDIDA","rotate_controls":"USE OS BOTÕES PARA GIRAR","rotate_help":"GIRE PARA ABRIR ESPAÇO","charge":"GRUPO","danger":"ALTURA","danger_soon":"CUIDADO: TOPO!","overflow":"VIDA PERDIDA!","hint":"Escolha uma coluna para jogar"},
	"de":{"life":"LEBEN","tap_short":"SPALTE TIPPEN","score":"PUNKTE","best":"REKORD","move":"ZUG","drop":"SPALTE ANTIPPEN ZUM FALLEN","turn":"DREHEN ODER WEITER","left":"LINKS","right":"RECHTS","skip":"WEITER","next":"FORM WÄHLEN","ready":"5 VERBUNDENE KUGELN = POP  •  OBEN = -1 LEBEN","over":"SPIEL VORBEI","again":"NOCHMAL SPIELEN","rescue":"TEST: +1 LEBEN","lost":"LEBEN VERLOREN","rotate_controls":"MIT DEN TASTEN UNTEN DREHEN","rotate_help":"DREHE FÜR MEHR PLATZ","charge":"GRUPPE","danger":"HÖHE","danger_soon":"ACHTUNG: OBERSTE REIHE!","overflow":"LEBEN VERLOREN!","hint":"Wähle eine Spalte zum Einwerfen"},
	"fr":{"life":"VIES","tap_short":"TOUCHE COLONNE","score":"SCORE","best":"RECORD","move":"COUP","drop":"TOUCHE UNE COLONNE POUR LÂCHER","turn":"TOURNE OU CONTINUE","left":"GAUCHE","right":"DROITE","skip":"SUITE","next":"CHOISIS UNE FORME","ready":"5 BILLES CONNECTÉES = POP  •  HAUT = -1 VIE","over":"PARTIE FINIE","again":"REJOUER","rescue":"TEST : +1 VIE","lost":"VIE PERDUE","rotate_controls":"TOURNE AVEC LES BOUTONS","rotate_help":"TOURNE POUR LIBÉRER DE LA PLACE","charge":"GROUPE","danger":"HAUTEUR","danger_soon":"ATTENTION AU SOMMET!","overflow":"VIE PERDUE!","hint":"Choisis une colonne pour les billes"},
	"ru":{"life":"ЖИЗНИ","tap_short":"ВЫБЕРИ СТОЛБЕЦ","score":"ОЧКИ","best":"РЕКОРД","move":"ХОД","drop":"НАЖМИ СТОЛБЕЦ ДЛЯ СБРОСА","turn":"ПОВЕРНИ ИЛИ ПРОДОЛЖИ","left":"ВЛЕВО","right":"ВПРАВО","skip":"ДАЛЕЕ","next":"ВЫБЕРИ ФИГУРУ","ready":"5 СОЕДИНЁННЫХ ШАРОВ = POP  •  ВЕРХ = -1 ЖИЗНЬ","over":"ИГРА ОКОНЧЕНА","again":"ИГРАТЬ СНОВА","rescue":"ТЕСТ: +1 ЖИЗНЬ","lost":"МИНУС ЖИЗНЬ","rotate_controls":"ПОВОРОТ КНОПКАМИ ВНИЗУ","rotate_help":"ПОВЕРНИ, ЧТОБЫ ОСВОБОДИТЬ МЕСТО","charge":"ГРУППА","danger":"ВЫСОТА","danger_soon":"ВНИМАНИЕ: ВЕРХ!","overflow":"МИНУС ЖИЗНЬ!","hint":"Выбери столбец для шариков"}
}
const LEFT_RECT := Rect2(35,1123,285,92)
const RIGHT_RECT := Rect2(400,1123,285,92)
const RESTART_RECT := Rect2(104,722,512,84)
const RESCUE_RECT := Rect2(104,821,512,79)
const SETTINGS_OPEN := Rect2(553,116,132,42)
const SETTINGS_CLOSE := Rect2(476,384,118,54)
const SETTINGS_TOGGLE := Rect2(120,550,480,80)
const SETTINGS_ERASE := Rect2(120,654,480,74)
const SETTINGS_AD_PRIVACY := Rect2(120,748,480,68)
const SETTINGS_SOUND := Rect2(114,886,492,67)
const SETTINGS_HAPTICS := Rect2(114,975,492,67)
const PROFILE_OPEN := Rect2(365,116,173,42)
const PROFILE_CLOSE := Rect2(512,265,120,54)
const PROFILE_CARD := Rect2(54,224,612,906)
const PROFILE_TR := {
	"pl":{"profile":"POSTĘP","level":"POZIOM","short":"POZ.","daily":"DZISIEJSZE MISJE","streak":"SERIA DNI","cosmetics":"WYGLĄD KULEK","drops":"ZRZUĆ KSZTAŁTY","pops":"WYWOŁAJ POP","points":"ZDOBĄDŹ PUNKTY","classic":"KLASYCZNE","aurora":"AURORA","starlight":"GWIEZDNE","locked":"POZ.","selected":"WYBRANE","close":"ZAMKNIJ","done":"UKOŃCZONA","autoclaim":"XP przyznaje się automatycznie"},
	"en":{"profile":"PROGRESS","level":"LEVEL","short":"LVL","daily":"TODAY'S MISSIONS","streak":"DAY STREAK","cosmetics":"MARBLE SKINS","drops":"DROP PIECES","pops":"TRIGGER POPS","points":"EARN POINTS","classic":"CLASSIC","aurora":"AURORA","starlight":"STARLIGHT","locked":"LVL","selected":"SELECTED","close":"CLOSE","done":"COMPLETE","autoclaim":"XP is awarded automatically"},
	"es":{"profile":"PROGRESO","level":"NIVEL","short":"NV","daily":"MISIONES DIARIAS","streak":"DÍAS SEGUIDOS","cosmetics":"ESTILOS DE BOLAS","drops":"SUELTA PIEZAS","pops":"HAZ POP","points":"GANA PUNTOS","classic":"CLÁSICO","aurora":"AURORA","starlight":"ESTELAR","locked":"NV","selected":"ELEGIDO","close":"CERRAR","done":"COMPLETA","autoclaim":"XP automático"},
	"pt":{"profile":"PROGRESSO","level":"NÍVEL","short":"NV","daily":"MISSÕES DIÁRIAS","streak":"DIAS SEGUIDOS","cosmetics":"ESTILOS DE BOLAS","drops":"SOLTE PEÇAS","pops":"FAÇA POP","points":"GANHE PONTOS","classic":"CLÁSSICO","aurora":"AURORA","starlight":"ESTELAR","locked":"NV","selected":"ESCOLHIDO","close":"FECHAR","done":"CONCLUÍDA","autoclaim":"XP automático"},
	"de":{"profile":"FORTSCHRITT","level":"LEVEL","short":"LVL","daily":"TAGESMISSIONEN","streak":"TAGES-SERIE","cosmetics":"KUGEL-DESIGNS","drops":"TEILE ABWERFEN","pops":"POPS AUSLÖSEN","points":"PUNKTE SAMMELN","classic":"KLASSISCH","aurora":"AURORA","starlight":"STERNEN","locked":"LVL","selected":"AKTIV","close":"SCHLIESSEN","done":"FERTIG","autoclaim":"XP automatisch"},
	"fr":{"profile":"PROGRESSION","level":"NIVEAU","short":"NIV","daily":"MISSIONS DU JOUR","streak":"JOURS DE SUITE","cosmetics":"STYLE DES BILLES","drops":"LÂCHER DES PIÈCES","pops":"FAIRE DES POPS","points":"GAGNER DES POINTS","classic":"CLASSIQUE","aurora":"AURORA","starlight":"ÉTOILÉ","locked":"NIV","selected":"CHOISI","close":"FERMER","done":"TERMINÉE","autoclaim":"XP automatique"},
	"ru":{"profile":"ПРОГРЕСС","level":"УРОВЕНЬ","short":"УР.","daily":"ЗАДАНИЯ НА ДЕНЬ","streak":"ДНЕЙ ПОДРЯД","cosmetics":"ВИД ШАРИКОВ","drops":"СБРОСЬ ФИГУРЫ","pops":"СОБЕРИ POP","points":"НАБЕРИ ОЧКИ","classic":"КЛАССИКА","aurora":"АВРОРА","starlight":"ЗВЁЗДНЫЕ","locked":"УР.","selected":"ВЫБРАНО","close":"ЗАКРЫТЬ","done":"ГОТОВО","autoclaim":"XP автоматически"}
}

var board: Array = []
var pieces: Array = []
var recent_shapes: Array = [] # remembers silhouettes, not ball colours
var rng := RandomNumberGenerator.new()
var language: String = "en"
var phase: String = "drop" # drop, anim, over
var score: int = 0
var best: int = 0
var moves: int = 0
var lives: int = 3
var revives: int = 0
var chain_depth: int = 0
var hover_column: int = -1
var selected_piece: int = 0
var dragging_piece: bool = false
var drag_point: Vector2 = Vector2.ZERO
var drag_column: int = -1
var queued_piece_index: int = 0
var motion: Array = []
var motion_time: float = 0.0
var motion_duration: float = 1.0
var motion_kind: String = "fall"
var spin_clockwise: bool = true
var animating: bool = false
var flash: Array = []
var fx: Array = []
var praise: String = ""
var praise_timer: float = 0.0
var hint_timer: float = 0.0
var style_cache: Dictionary = {}
# Lightweight, procedural VFX. No textures, external assets or gameplay changes.
var clock: float = 0.0
var display_score: float = 0.0
var praise_color: Color = Color.WHITE
var praise_length: float = 1.0
var pop_time: float = 0.0
var pop_length: float = 0.17
var glow: float = 0.0
var shake_time: float = 0.0
var shake_force: float = 0.0
var rings: Array = []
var floaters: Array = []
var queued_action: String = ""
var queued_column: int = -1
var tap_time: float = 0.0
var tap_point: Vector2 = Vector2.ZERO
# Strategic feedback, recomputed when board state changes (never each frame).
var pending_group: Dictionary = {}
var preview_left: Dictionary = {}
var preview_right: Dictionary = {}
var telemetry = null
var ads = null
var feedback = null
var progression = null
var profile_open: bool = false
var action_serial: int = 0
var action_id: String = ""
var mission_notice: String = ""
var mission_notice_time: float = 0.0
var level_fx_time: float = 0.0
var level_fx_number: int = 0
var settings_open: bool = false
var ad_note: String = ""
var run_id: String = ""
var rounds_played: int = 0
var best_at_round_start: int = 0
var game_over_reported: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	rng.randomize()
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var detected: String = OS.get_locale_language().to_lower()
	language = detected if detected in LOCALES else "en"
	if FileAccess.file_exists(SAVE_FILE):
		var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE_FILE))
		if saved is Dictionary:
			best = int(saved.get("best",0))
			rounds_played = int(saved.get("rounds_played",0))
			var remembered: String = str(saved.get("language",language))
			if remembered in LOCALES:
				language = remembered
	telemetry = Telemetry.new()
	add_child(telemetry)
	ads = Ads.new()
	add_child(ads)
	ads.reward_earned.connect(_on_ad_reward)
	feedback = Feedback.new()
	add_child(feedback)
	progression = Progression.new()
	progression.load_data()
	progression.mission_completed.connect(_on_mission_completed)
	progression.level_reached.connect(_on_level_reached)
	var previous: Dictionary = Session.read_progress()
	if previous.is_empty():
		new_game()
	else:
		_restore_progress(previous)
	telemetry.track("session_start", {"restored_round": not previous.is_empty()})

func t(key: String) -> String:
	return str(TR.get(language,TR["en"]).get(key,key))

func profile_t(key: String) -> String:
	return str(PROFILE_TR.get(language,PROFILE_TR["en"]).get(key,key))

func _on_mission_completed(mission_id: String, bonus_xp: int) -> void:
	mission_notice = "%s +%d XP" % [profile_t("done"),bonus_xp]
	mission_notice_time = 2.6
	if feedback != null:
		feedback.cue("mission")
	telemetry.track("mission_completed", {"mission":mission_id,"reward_xp":bonus_xp})

func _on_level_reached(new_level: int) -> void:
	mission_notice = "%s %d!" % [profile_t("level"),new_level]
	mission_notice_time = 3.2
	level_fx_number = new_level
	level_fx_time = 3.0
	glow = 1.0
	_shock(Vector2(360,200),2.0,Color("#ffe29d"))
	for i in range(16):
		_burst(Vector2i((i*5+1)%8,(i*3+2)%8),3)
	if feedback != null:
		feedback.cue("level")
	telemetry.track("level_reached", {"level":new_level})


func _save() -> void:
	var f: FileAccess = FileAccess.open(SAVE_FILE,FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"best":best,"language":language,"rounds_played":rounds_played}))

func new_game() -> void:
	run_id = Crypto.new().generate_random_bytes(8).hex_encode()
	best_at_round_start = best
	game_over_reported = false
	action_serial = 0
	action_id = ""
	mission_notice = ""
	mission_notice_time = 0.0
	level_fx_time = 0.0
	ad_note = ""
	board = Rules.empty_board()
	# Lively opening: a four-ball group is one ball away from a 5-POP.
	# The empty floor cell at column 0 offers an obvious first target.
	for x in range(8):
		board[7][x] = [-1,0,0,0,0,1,2,2][x]
		board[6][x] = [-1,1,2,1,2,0,1,0][x]
		board[5][x] = [-1,-1,2,0,1,2,0,1][x]
	score = 0
	moves = 0
	lives = 3
	revives = 0
	chain_depth = 0
	pieces = []
	recent_shapes.clear()
	motion.clear()
	flash.clear()
	fx.clear()
	rings.clear()
	floaters.clear()
	praise = ""
	pop_time = 0.0
	glow = 0.0
	shake_time = 0.0
	display_score = 0.0
	queued_action = ""
	queued_column = -1
	queued_piece_index = 0
	selected_piece = 0
	dragging_piece = false
	drag_column = -1
	hover_column = -1
	animating = false
	phase = "drop"
	for i in range(3):
		# A legible first move: the red bead can fill the empty floor
		# column for an instant 5-POP. Afterwards the randomized
		# shapes resume.
		var piece: Array = [[0,0,0],[1,0,1]] if i == 0 else Rules.next_piece(rng,board,recent_shapes)
		pieces.append(piece)
		_remember_shape(piece)
	_refresh_targets()
	_save_progress()
	if telemetry != null:
		telemetry.track("game_start", {"run_id":run_id, "round_number":rounds_played+1})
	queue_redraw()

func _save_progress() -> void:
	# Never checkpoint a partially animated cascade or transient rotated board.
	if phase not in ["drop","over"]:
		return
	Session.write_progress({
		"board": Rules.copy_board(board), "pieces": pieces.duplicate(true),
		"phase": phase, "score": score, "moves": moves, "lives": lives,
		"revives": revives, "run_id": run_id,
		"best_at_start": best_at_round_start,
		"over_reported": game_over_reported,
		"action_serial": action_serial
	})

func _restore_progress(data: Dictionary) -> void:
	board = Rules.copy_board(data["board"])
	pieces = data["pieces"].duplicate(true)
	phase = str(data["phase"])
	score = int(data["score"])
	moves = int(data["moves"])
	lives = int(data["lives"])
	revives = int(data["revives"])
	run_id = str(data.get("run_id","restored"))
	best_at_round_start = int(data.get("best_at_start",best))
	game_over_reported = bool(data.get("over_reported",phase=="over"))
	action_serial = maxi(0,int(data.get("action_serial",0)))
	action_id = ""
	best = maxi(best,score)
	display_score = float(score)
	selected_piece = 0
	dragging_piece = false
	animating = false
	motion.clear()
	flash.clear()
	fx.clear()
	rings.clear()
	floaters.clear()
	recent_shapes.clear()
	for piece in pieces:
		_remember_shape(piece)
	_refresh_targets()
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_progress()

func _on_game_over() -> void:
	if game_over_reported:
		return
	rounds_played += 1
	game_over_reported = true
	progression.record_round("round:"+run_id)
	_save()
	telemetry.track("game_over", {
		"run_id":run_id, "score":score, "moves":moves,
		"revives":revives, "distance_to_previous_best":maxi(0,best_at_round_start-score),
		"round_number":rounds_played
	})

func _on_ad_reward(_transaction: int) -> void:
	# Only the SDK provider's reward-earned callback can reach this function.
	if phase != "over" or revives >= 1:
		return
	revives += 1
	lives = 1
	board = Rules.rescue(board)
	pieces[0] = Rules.next_piece(rng,board,recent_shapes)
	_remember_shape(pieces[0])
	selected_piece = 0
	phase = "drop"
	ad_note = ""
	_refresh_targets()
	_praise("+1 ♥",Color("#ff9bb7"),1.2)
	telemetry.track("ad_reward_earned", {"run_id":run_id,"reward":"revive"})
	_save_progress()
	queue_redraw()

func _process(delta: float) -> void:
	clock += delta
	mission_notice_time = maxf(0.0,mission_notice_time-delta)
	level_fx_time = maxf(0.0,level_fx_time-delta)
	tap_time = maxf(0.0,tap_time-delta)
	if animating:
		motion_time = minf(motion_duration,motion_time+delta)
	pop_time = maxf(0.0,pop_time-delta)
	praise_timer = maxf(0.0,praise_timer-delta)
	hint_timer = maxf(0.0,hint_timer-delta)
	shake_time = maxf(0.0,shake_time-delta)
	glow = maxf(0.0,glow-delta*3.5)
	# A fast score roll-up makes even a small clear feel rewarding.
	display_score = move_toward(display_score,float(score),maxf(65.0,absf(float(score)-display_score)*delta*13.0))
	for i in range(fx.size()-1,-1,-1):
		var particle: Dictionary = fx[i]
		particle.p += particle.v * delta
		particle.v *= maxf(0.0,1.0-2.6*delta)
		particle.life -= delta
		fx[i] = particle
		if particle.life <= 0.0:
			fx.remove_at(i)
	for i in range(rings.size()-1,-1,-1):
		var ring: Dictionary = rings[i]
		ring.life -= delta
		if ring.life <= 0.0:
			rings.remove_at(i)
		else:
			rings[i] = ring
	for i in range(floaters.size()-1,-1,-1):
		var floater: Dictionary = floaters[i]
		floater.life -= delta
		if floater.life <= 0.0:
			floaters.remove_at(i)
		else:
			floaters[i] = floater
	if shake_time <= 0.0:
		shake_force = 0.0
	queue_redraw()

func _scale() -> float:
	return minf(size.x/BASE.x,size.y/BASE.y)

func _offset() -> Vector2:
	return (size-BASE*_scale())*0.5

func _logical(screen: Vector2) -> Vector2:
	return (screen-_offset())/_scale()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pointer: Vector2 = _logical(event.position)
		if dragging_piece:
			drag_point = pointer
			drag_column = _drop_column_at(pointer)
			hover_column = drag_column
		else:
			hover_column = _drop_column_at(pointer) if phase=="drop" else -1
		queue_redraw()
		return
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var pt: Vector2 = _logical(event.position)
	# A release, not a press, commits a dragged shape. Cancelling outside
	# the board never consumes it, and tapping a preview card only selects it.
	if not event.pressed:
		if dragging_piece:
			var landing_column: int = _drop_column_at(pt)
			dragging_piece = false
			drag_column = -1
			hover_column = -1
			if phase=="drop" and landing_column>=0:
				_play_drop(landing_column)
			queue_redraw()
		return
	tap_point = pt
	tap_time = 0.42
	if profile_open:
		if PROFILE_CLOSE.has_point(pt):
			profile_open = false
		else:
			for index in range(Progression.SKINS.size()):
				if Rect2(90+index*181,975,164,75).has_point(pt):
					var skin_id: String = str(Progression.SKINS[index]["id"])
					if progression.select_skin(skin_id):
						telemetry.track("skin_selected",{"skin":skin_id})
		queue_redraw()
		return
	if settings_open:
		if SETTINGS_CLOSE.has_point(pt):
			settings_open = false
		elif SETTINGS_TOGGLE.has_point(pt):
			telemetry.set_opted_in(not telemetry.opted_in)
			if telemetry.opted_in:
				telemetry.track("analytics_opt_in")
		elif SETTINGS_ERASE.has_point(pt):
			telemetry.erase_events_and_identity()
		elif SETTINGS_SOUND.has_point(pt):
			feedback.set_sound_enabled(not feedback.sound_enabled)
			feedback.cue("tap")
		elif SETTINGS_HAPTICS.has_point(pt):
			feedback.set_haptics_enabled(not feedback.haptics_enabled)
			feedback.cue("tap")
		elif SETTINGS_AD_PRIVACY.has_point(pt):
			ads.show_privacy_options()
		queue_redraw()
		return
	if SETTINGS_OPEN.has_point(pt) and phase != "anim":
		settings_open = true
		queue_redraw()
		return
	if PROFILE_OPEN.has_point(pt) and phase != "anim":
		progression.ensure_day()
		profile_open = true
		telemetry.track("profile_open",{"level":progression.level()})
		queue_redraw()
		return
	if phase=="anim":
		if LEFT_RECT.has_point(pt):
			queued_action = "left"
		elif RIGHT_RECT.has_point(pt):
			queued_action = "right"
		elif BOARD.has_point(pt):
			queued_action = "drop"
			queued_column = _drop_column_at(pt)
			queued_piece_index = selected_piece
		return
	if phase=="over":
		if RESTART_RECT.has_point(pt):
			var should_interstitial: bool = rounds_played >= 3 and rounds_played % 3 == 0
			new_game()
			if should_interstitial:
				ads.request_interstitial()
		elif RESCUE_RECT.has_point(pt) and revives < 1:
			if not ads.request_rewarded():
				ad_note = "ADS UNAVAILABLE" if language != "pl" else "REKLAMA NIEDOSTĘPNA"
			else:
				ad_note = "LOADING AD..." if language != "pl" else "ŁADOWANIE REKLAMY..."
			queue_redraw()
		return
	if Rect2(576,53,100,53).has_point(pt):
		var index: int = LOCALES.find(language)
		language = LOCALES[(index+1)%LOCALES.size()]
		_save()
		queue_redraw()
		return
	if phase!="drop":
		return
	if LEFT_RECT.has_point(pt):
		_rotate_board(false)
		return
	if RIGHT_RECT.has_point(pt):
		_rotate_board(true)
		return
	for i in range(pieces.size()):
		if _piece_card_rect(i).has_point(pt):
			selected_piece = i
			dragging_piece = true
			drag_point = pt
			drag_column = -1
			hover_column = -1
			queue_redraw()
			return
	if BOARD.has_point(pt):
		dragging_piece = true
		drag_point = pt
		drag_column = _drop_column_at(pt)
		hover_column = drag_column
		queue_redraw()
func _play_drop(column: int) -> void:
	if phase != "drop" or pieces.is_empty():
		return
	var used_index: int = clampi(selected_piece,0,pieces.size()-1)
	var result: Dictionary = Rules.drop(board,pieces[used_index],column)
	if not result.get("valid",false):
		_praise(t("hint"),Color("#ff8ba8"),0.8)
		return
	if feedback != null:
		feedback.cue("drop")
	action_serial += 1
	action_id = "action:%s:%d" % [run_id,action_serial]
	progression.record_drop(action_id+":drop")
	telemetry.track("piece_drop", {
		"run_id":run_id, "column":column, "shape_size":pieces[used_index].size(),
		"move":moves+1, "board_filled":Rules.filled(board),
		"player_level":progression.level()
	})
	phase = "anim"
	moves += 1
	chain_depth = 0
	await _animate_to(result.board,result.motions,0.23,"drop")
	# Matching 5+ touching balls POP immediately after any successful drop.
	# Resolve every resulting cascade BEFORE checking overflow or advancing.
	await _resolve_cascades()
	# No Next button: the next shape is ready immediately after this drop.
	_advance_piece(used_index)
	phase = "drop"
	_check_ceiling()
	if phase == "drop":
		_refresh_targets()
		_check_stuck()
	if phase == "over":
		_on_game_over()
	_save_progress()
	_flush_queued_input()
	queue_redraw()

func _rotate_board(clockwise: bool) -> void:
	if phase != "drop":
		return
	if feedback != null:
		feedback.cue("rotate")
	action_serial += 1
	action_id = "action:%s:%d" % [run_id,action_serial]
	telemetry.track("board_rotate", {
		"run_id":run_id, "clockwise":clockwise, "move":moves,
		"board_filled":Rules.filled(board)
	})
	phase = "anim"
	chain_depth = 0 # Each action has its own independent cascade multiplier.
	spin_clockwise = clockwise
	var turned: Dictionary = Rules.rotate(board,clockwise)
	_shock(BOARD.get_center(),1.15,Color("#78d9ff"))
	await _animate_to(turned.board,turned.motions,0.27,"spin")
	var gravity: Dictionary = Rules.settle(board)
	await _animate_to(gravity.board,gravity.motions,0.19,"fall")
	# Only rotation unlocks marble flow into lower neighbouring pockets.
	var spill: Dictionary = Rules.spill_after_rotation(board,clockwise)
	await _animate_to(spill.board,spill.motions,0.51,"roll")
	await _resolve_cascades(true)
	phase = "drop"
	_check_ceiling()
	if phase == "drop":
		_refresh_targets()
		_check_stuck()
	if phase == "over":
		_on_game_over()
	_save_progress()
	_flush_queued_input()
	queue_redraw()

func _flush_queued_input() -> void:
	var action: String = queued_action
	var column: int = queued_column
	var piece_index: int = queued_piece_index
	queued_action = ""
	queued_column = -1
	if phase != "drop":
		return
	if action == "left":
		call_deferred("_rotate_board",false)
	elif action == "right":
		call_deferred("_rotate_board",true)
	elif action == "drop" and column >= 0:
		selected_piece = clampi(piece_index,0,pieces.size()-1)
		call_deferred("_play_drop",column)

func _refresh_targets() -> void:
	# The largest cluster shows how much more the player could build.
	pending_group.clear()
	var groups: Array = Rules.find_groups(board,2)
	for group in groups:
		if pending_group.is_empty() or int(group["count"]) > int(pending_group["count"]):
			pending_group = group
	preview_left = Rules.rotate_preview(board,false)
	preview_right = Rules.rotate_preview(board,true)

func _remember_shape(piece: Array) -> void:
	recent_shapes.append(Rules.piece_shape_id(piece))
	while recent_shapes.size() > 5:
		recent_shapes.pop_front()


func _advance_piece(used_index: int) -> void:
	# The selected card disappears; other offered shapes stay available.
	pieces.remove_at(used_index)
	var next: Array = Rules.next_piece(rng,board,recent_shapes)
	pieces.append(next)
	_remember_shape(next)
	selected_piece = 0

func _could_recover_by_rotating() -> bool:
	# A blocked shape is not a loss when either of the other two can fit.
	for clockwise in [false,true]:
		var virtual: Array = Rules.copy_board(board)
		for quarter in range(4):
			virtual = Rules.rotate(virtual,clockwise).board
			virtual = Rules.settle(virtual).board
			virtual = Rules.spill_after_rotation(virtual,clockwise).board
			virtual = Rules.resolve_preview(virtual,true,clockwise).board
			if _any_piece_can_drop(virtual):
				return true
	return false
func _check_ceiling() -> void:
	# Reaching the clearly highlighted top row costs one life, even if there
	# are other empty columns. Rotating can prevent the loss beforehand.
	if not Rules.ceiling_reached(board):
		return
	if feedback != null:
		feedback.cue("fail")
	lives -= 1
	telemetry.track("life_lost", {"run_id":run_id,"cause":"ceiling","moves":moves,"lives_left":lives})
	_praise(t("overflow"),Color("#ff879d"),1.3)
	_shock(BOARD.position+Vector2(BOARD.size.x*0.5,CELL*0.5),2.5,Color("#ff6389"))
	if lives <= 0:
		phase = "over"
	else:
		# Remove the highest two occupied rows, settle and keep playing.
		board = Rules.rescue(board)
	queue_redraw()

func _any_piece_can_drop(on_board: Array) -> bool:
	for piece in pieces:
		if Rules.any_drop(on_board,piece):
			return true
	return false

func _check_stuck() -> void:
	if phase != "drop" or pieces.is_empty():
		return
	if _any_piece_can_drop(board):
		return
	if _could_recover_by_rotating():
		_praise(t("rotate_help"),Color("#ffe49c"),1.1)
		return
	if feedback != null:
		feedback.cue("fail")
	lives -= 1
	telemetry.track("life_lost", {"run_id":run_id,"cause":"blocked","moves":moves,"lives_left":lives})
	_praise(t("lost"),Color("#ff8ca4"),1.2)
	if lives <= 0:
		phase = "over"
	else:
		board = Rules.rescue(board)
		pieces[0] = Rules.next_piece(rng,board,recent_shapes)
		_remember_shape(pieces[0])
		if not _any_piece_can_drop(board):
			# Let the next input recover the board; no recursive losses.
			board = Rules.empty_board()
		selected_piece = 0
		_refresh_targets()
	queue_redraw()

func _animate_to(next_board: Array, motions: Array, seconds: float, kind: String) -> void:
	board = Rules.copy_board(next_board)
	if motions.is_empty():
		queue_redraw()
		return
	motion = motions
	motion_time = 0.0
	motion_duration = seconds
	motion_kind = kind
	animating = true
	queue_redraw()
	await get_tree().create_timer(seconds).timeout
	animating = false
	motion.clear()
	# Every arrival has a tiny physical recoil, a few glints and a board pulse.
	var impact_count: int = 0
	for m in motions:
		if impact_count >= 12:
			break
		var dest: Vector2 = m["to"]
		if kind != "spin":
			_burst(Vector2i(int(dest.x),int(dest.y)),2)
		impact_count += 1
	if kind == "roll":
		_shock(BOARD.get_center(),0.82,Color("#86f9e4"))
	elif kind != "spin":
		_shock(BOARD.get_center(),0.38 if kind == "fall" else 0.58,Color("#a2e9ff"))
	queue_redraw()

func _resolve_cascades(fluid: bool=false) -> void:
	# Called after both a successful drop and a board rotation.
	for depth in range(20):
		var groups: Array = Rules.find_groups(board)
		if groups.is_empty():
			return
		chain_depth += 1
		if feedback != null:
			feedback.cue("cascade" if chain_depth >= 2 else "pop")
		var hits: Array = []
		var largest: int = 0
		for group in groups:
			hits.append_array(group["cells"])
			largest = maxi(largest,int(group["count"]))
		flash = hits
		pop_length = 0.18 if chain_depth <= 2 else 0.21
		pop_time = pop_length
		if chain_depth >= 3 or largest >= 8:
			_praise("AMAZING!",Color("#ffe58c"),1.30)
		elif chain_depth >= 2 or largest >= 7 or groups.size() > 1:
			_praise("GREAT!",Color("#92f2e2"),1.0)
		else:
			_praise("POP!",Color("#ffffff"),0.72)
		await get_tree().create_timer(pop_length).timeout
		var main_color: Color = COLORS[int(groups[0]["color"])]
		# Score each actual connected group, not the total across unrelated colours.
		# An 8-ball group is worth much more than two separate groups of four.
		var payout: int = Rules.score_groups(groups,chain_depth)
		var centroid: Vector2 = Vector2.ZERO
		for group in groups:
			var group_center: Vector2 = Vector2.ZERO
			for pt in group["cells"]:
				var position: Vector2 = BOARD.position+(Vector2(pt)+Vector2(0.5,0.5))*CELL
				group_center += position
				centroid += position
				_burst(pt,8 if chain_depth <= 2 else 11)
			group_center /= float(group["count"])
			_float_score(group_center,Rules.group_points(int(group["count"]))*chain_depth,chain_depth)
		centroid /= float(hits.size())
		_shock(centroid,minf(4.5,1.15+float(chain_depth)*0.7+float(hits.size())*0.12),main_color)
		board = Rules.erase_matches(board,hits)
		score += payout
		progression.record_pop(action_id+":pop:"+str(chain_depth),
			groups.size(),hits.size(),payout,chain_depth)
		telemetry.track("pop_triggered", {
			"run_id":run_id, "balls":hits.size(), "groups":groups.size(),
			"largest_group":largest, "cascade":chain_depth,
			"points":payout, "move":moves
		})
		best = maxi(best,score)
		_save()
		flash.clear()
		pop_time = 0.0
		queue_redraw()
		var gravity: Dictionary = Rules.settle(board)
		await _animate_to(gravity.board,gravity.motions,0.20,"fall")
		if fluid:
			var aftershock: Dictionary = Rules.spill_after_rotation(board,spin_clockwise)
			await _animate_to(aftershock.board,aftershock.motions,0.38,"roll")

func _burst(cell: Vector2i, count: int) -> void:
	var center: Vector2 = BOARD.position+(Vector2(cell)+Vector2(0.5,0.5))*CELL
	var color_index: int = int(board[cell.y][cell.x])
	var base: Color = COLORS[clampi(color_index,0,COLORS.size()-1)]
	for i in range(count):
		if fx.size() >= 220:
			fx.pop_front()
		var angle: float = rng.randf_range(0.0,TAU)
		var speed: float = rng.randf_range(130.0,420.0)
		var duration: float = rng.randf_range(0.32,0.70)
		fx.append({"p":center+Vector2.from_angle(angle)*rng.randf_range(0.0,8.0),
			"v":Vector2.from_angle(angle)*speed,"life":duration,"max":duration,
			"color":base.lightened(rng.randf_range(0.0,0.4)),
			"r":rng.randf_range(2.5,6.0),"streak":i%3 != 0})

func _shock(at: Vector2, strength: float, tint: Color) -> void:
	rings.append({"p":at,"life":0.48,"max":0.48,"strength":strength,"color":tint})
	if rings.size() > 14:
		rings.pop_front()
	shake_time = maxf(shake_time,0.18)
	shake_force = maxf(shake_force,2.0+strength*2.0)
	glow = minf(1.0,glow+strength*0.18)

func _float_score(at: Vector2, gained: int, combo: int) -> void:
	floaters.append({"p":at,"text":"+%d" % gained,"combo":combo,
		"life":0.90,"max":0.90})
	if floaters.size() > 10:
		floaters.pop_front()

func _praise(value: String, color: Color, length: float) -> void:
	praise = value
	praise_color = color
	praise_length = length
	praise_timer = length

# ---------------------------------------------------------------------------
# COSMIC CANDY / polished responsive arcade skin.
# All drawing stays in this Control: no images, shaders or network assets.
# Original BOARD and button rectangles are preserved for gameplay and touch.
# ---------------------------------------------------------------------------
func _box(rect: Rect2, color: Color, radius: int=16, border: Color=Color.TRANSPARENT, width: int=0) -> void:
	var key: String = "%s:%d:%s:%d" % [color.to_html(true),radius,border.to_html(true),width]
	if not style_cache.has(key):
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = color
		style.set_corner_radius_all(radius)
		if width > 0:
			style.border_color = border
			style.set_border_width_all(width)
		style_cache[key] = style
	draw_style_box(style_cache[key],rect)

func _gradient(rect: Rect2, top: Color, bottom: Color, steps: int=18) -> void:
	var strip_height: float = rect.size.y/float(steps)
	for i in range(steps):
		draw_rect(Rect2(rect.position+Vector2(0.0,float(i)*strip_height),
			Vector2(rect.size.x,strip_height+1.0)),top.lerp(bottom,float(i)/float(steps-1)))

func _text(value: String, at: Vector2, pt: int, color: Color, bold: bool=true) -> void:
	draw_string(BOLD if bold else FONT,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,pt,color)

func _center(value: String, center_x: float, baseline: float, pt: int, color: Color, bold: bool=true) -> void:
	var font: Font = BOLD if bold else FONT
	var measured: Vector2 = font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,pt)
	draw_string(font,Vector2(center_x-measured.x*0.5,baseline),value,HORIZONTAL_ALIGNMENT_LEFT,-1,pt,color)

func _fit_center(value: String, center_x: float, baseline: float, pt: int, max_width: float, color: Color) -> void:
	var size_pt: int = pt
	while size_pt > 11 and BOLD.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,size_pt).x > max_width:
		size_pt -= 1
	_center(value,center_x,baseline,size_pt,color)

func _spark(at: Vector2, radius: float, tint: Color, opacity: float=1.0) -> void:
	var c: Color = Color(tint.r,tint.g,tint.b,opacity)
	draw_line(at+Vector2(-radius,0),at+Vector2(radius,0),c,2.2,true)
	draw_line(at+Vector2(0,-radius),at+Vector2(0,radius),c,2.2,true)
	draw_circle(at,2.0,Color(1,1,1,opacity))


func _neon_panel(rect: Rect2, accent: Color, strong: bool=false) -> void:
	# Five depth layers. Keeps shapes readable on small mobile screens.
	var radius: int = 26 if strong else 20
	_box(Rect2(rect.position+Vector2(0,7),rect.size),Color("#030817",0.85),radius+2)
	_box(Rect2(rect.position-Vector2(3,3),rect.size+Vector2(6,6)),
		Color(accent.r,accent.g,accent.b,0.10),radius+3)
	_box(rect,Color("#111930") if strong else Color("#131b34"),
		radius,Color(accent.r,accent.g,accent.b,0.62 if strong else 0.33),2)
	_box(Rect2(rect.position+Vector2(6,6),rect.size-Vector2(12,12)),
		Color("#212947",0.48),maxi(9,radius-6))
	draw_line(rect.position+Vector2(22,8),rect.position+Vector2(rect.size.x-22,8),
		Color(accent.r,accent.g,accent.b,0.52),2.0,true)
	draw_circle(rect.position+Vector2(21,18),2.0,Color(1,1,1,0.45))

func _corner(at: Vector2, direction: Vector2, color: Color, length: float=34.0) -> void:
	draw_line(at,at+Vector2(direction.x*length,0),Color(color.r,color.g,color.b,0.24),10.0,true)
	draw_line(at,at+Vector2(0,direction.y*length),Color(color.r,color.g,color.b,0.24),10.0,true)
	draw_line(at,at+Vector2(direction.x*length,0),color,3.0,true)
	draw_line(at,at+Vector2(0,direction.y*length),color,3.0,true)
	_spark(at,4.0,Color.WHITE,0.68)

func _draw_tap_ripple() -> void:
	if tap_time <= 0.0 or phase == "over":
		return
	var progress: float = 1.0-tap_time/0.42
	var fade: float = pow(1.0-progress,2.0)
	var tint: Color = Color("#9dfdf1")
	draw_arc(tap_point,15.0+progress*63.0,0.0,TAU,48,
		Color(tint.r,tint.g,tint.b,0.48*fade),3.5,true)
	draw_circle(tap_point,5.0+progress*12.0,Color(1,1,1,0.12*fade))

func _ball(center: Vector2, radius: float, color_index: int,
		alpha: float=1.0, stretch: Vector2=Vector2.ONE) -> void:
	# One actual high-resolution candy-glass sprite rather than 12 overlapping
	# flat circles. The authored transparent margin contains the soft glow.
	var marble: Texture2D = MARBLE_TEXTURES[clampi(color_index,0,2)]
	var half_width: float = radius*1.255*stretch.x
	var half_height: float = radius*1.255*stretch.y
	var box: Rect2 = Rect2(center-Vector2(half_width,half_height),
		Vector2(half_width*2.0,half_height*2.0))
	if progression != null and progression.skin == "aurora":
		var tint: Color = COLORS[clampi(color_index,0,2)]
		draw_circle(center,radius*1.16,Color(tint.r,tint.g,tint.b,0.13*alpha))
	draw_texture_rect(marble,box,false,Color(1.0,1.0,1.0,alpha))
	if progression != null and progression.skin == "aurora":
		draw_arc(center,radius*0.91,-PI*0.90,PI*0.12,30,
			Color("#ddfcff",0.55*alpha),2.3,true)
	elif progression != null and progression.skin == "starlight":
		draw_arc(center,radius*0.98,0,TAU,44,
			Color("#ffdb8f",0.66*alpha),2.6,true)
		var gleam: Vector2 = center+Vector2(radius*0.45,-radius*0.60)
		draw_line(gleam+Vector2(-5,0),gleam+Vector2(5,0),
			Color(1,1,1,0.85*alpha),1.5,true)
		draw_line(gleam+Vector2(0,-5),gleam+Vector2(0,5),
			Color(1,1,1,0.85*alpha),1.5,true)
func _draw_background() -> void:
	_gradient(Rect2(0,0,720,1280),Color("#07081a"),Color("#130b30"),44)
	# Atmospheric stage lighting with subtle motion, not a static wallpaper.
	var breathe: float = 0.5+0.5*sin(clock*0.68)
	draw_circle(Vector2(-140,135),420,Color("#e23f9b",0.055+0.022*breathe))
	draw_circle(Vector2(817,470),480,Color("#3caaf5",0.085+0.020*breathe))
	draw_circle(Vector2(360,1130),440,Color("#a04ffe",0.085))
	draw_circle(Vector2(340,542),480,Color("#294893",0.053))
	draw_arc(Vector2(380,602),470,PI*0.06,PI*1.65,100,
		Color("#6384e4",0.12),2.3,true)
	draw_arc(Vector2(345,598),511,PI*1.15,PI*1.93,70,
		Color("#ff5da8",0.10),2.1,true)
	for line_index in range(7):
		var x: float = float(line_index)*142.0-195.0
		draw_line(Vector2(x,-10),Vector2(x+470,1280),
			Color("#a185ef",0.018),1.6,true)
	for i in range(52):
		var speed: float = 5.0+float(i%6)*2.2
		var y: float = fposmod(float(i*173+31)-clock*speed,1320.0)
		var x: float = fposmod(float(i*257+29),694.0)+13.0
		var light: float = 0.20+0.24*(0.5+0.5*sin(clock*1.9+float(i)*1.6))
		if i%7==0:
			_spark(Vector2(x,y),3.5+float(i%3),Color("#e2efff"),light)
		else:
			draw_circle(Vector2(x,y),0.8+float(i%3)*0.6,
				Color(0.77,0.82,1.0,light))

func _draw_header() -> void:
	# Branded display typography, rainbow underline and subtle floating emblem.
	_text("POP",Vector2(36,103),72,Color("#f4f5ff"))
	_text("DROP",Vector2(188,103),72,Color("#91fff0"))
	_text("POP",Vector2(37,100),72,Color("#ffffff"))
	_text("DROP",Vector2(188,100),72,Color("#b8fff3"))
	for i in range(3):
		var x: float = 50.0+float(i)*109.0
		var width: float = 108.0 if i<2 else 73.0
		draw_line(Vector2(x,116),Vector2(x+width,116),COLORS[i],4.0,true)
	# Animated mini-molecule gives the header its own recognisable icon.
	var logo_center: Vector2 = Vector2(447,76)
	draw_arc(logo_center,27,0,TAU,52,Color("#8394d4",0.31),2.0,true)
	for i in range(3):
		var angle: float = clock*0.40+float(i)*TAU/3.0
		_ball(logo_center+Vector2.from_angle(angle)*22.0,8.5,i)
	_neon_panel(Rect2(575,48,110,54),Color("#b5b1ff"))
	_fit_center(language.to_upper(),629,82,22,94,Color("#f7f6ff"))
	_neon_panel(SETTINGS_OPEN,Color("#b5b1ff"))
	_fit_center("⚙ DATA",619,144,17,118,Color("#e9e6ff"))
	_neon_panel(PROFILE_OPEN,Color("#ffdf8b"))
	_fit_center("%s %d  •  XP" % [profile_t("short"),progression.level()],451,143,17,159,Color("#ffefd3"))
	_text("✦ GRAVITY EDITION",Vector2(49,151),18,Color("#d4c2ff"))
	draw_line(Vector2(316,144),Vector2(551,144),Color("#c695ff",0.23),1.5,true)

func _draw_hud() -> void:
	# Score is the hero. Best and hearts become a compact game dashboard.
	_neon_panel(Rect2(35,170,337,89),Color("#ff79bb"),true)
	draw_rect(Rect2(51,189,4,49),Color("#ff81b9"))
	_text(t("score"),Vector2(69,196),16,Color("#f7b7d4"))
	_text(str(int(round(display_score))),Vector2(67,246),48,Color.WHITE)
	_spark(Vector2(346,190),5,Color("#ffa6d1"),0.40+0.35*sin(clock*2.6))
	_neon_panel(Rect2(385,170,139,89),Color("#ffd48d"))
	_fit_center(t("best"),455,197,15,124,Color("#e4caad"))
	_fit_center(str(best),455,242,34,121,Color("#fff0b6"))
	_neon_panel(Rect2(537,170,148,89),Color("#ff729e"))
	_fit_center(t("life"),609,194,14,136,Color("#edbad4"))
	for i in range(3):
		var heart_center: Vector2 = Vector2(567+float(i)*43,229)
		var alive: bool = i<lives
		var tint: Color = Color("#ff75a9") if alive else Color("#596077")
		draw_circle(heart_center+Vector2(0,2),18,Color("#080c23"))
		draw_circle(heart_center,16,Color("#692b5f") if alive else Color("#252a42"))
		draw_arc(heart_center,17,0,TAU,28,
			Color(tint.r,tint.g,tint.b,0.72 if alive else 0.26),1.8,true)
		_center("♥",heart_center.x,heart_center.y+8,25,tint)
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("#080d24"))
	draw_set_transform(_offset(),0,Vector2.ONE*_scale())
	_draw_background()
	_draw_header()
	_draw_hud()
	var shake: Vector2 = Vector2.ZERO
	if shake_time > 0.0:
		var falloff: float = shake_time/0.18
		shake = Vector2(sin(clock*105.0),cos(clock*131.0))*shake_force*falloff*falloff
	draw_set_transform(_offset()+shake*_scale(),0,Vector2.ONE*_scale())
	_draw_board()
	_draw_particles()
	draw_set_transform(_offset(),0,Vector2.ONE*_scale())
	_draw_status()
	_draw_pieces()
	_draw_buttons()
	_draw_drag_overlay()
	_draw_tap_ripple()
	if glow > 0.0:
		draw_rect(Rect2(0,0,720,1280),Color(0.8,0.94,1.0,0.055*glow))
	if praise_timer > 0.0 and phase != "over":
		_draw_praise()
	if phase == "over":
		_draw_game_over()
		_neon_panel(SETTINGS_OPEN,Color("#b5b1ff"))
		_fit_center("⚙ DATA",619,144,17,118,Color("#e9e6ff"))
		_neon_panel(PROFILE_OPEN,Color("#ffdf8b"))
		_fit_center("%s %d  •  XP" % [profile_t("short"),progression.level()],451,143,17,159,Color("#ffefd3"))
	if mission_notice_time > 0 and not settings_open and not profile_open:
		_draw_mission_toast()
	if level_fx_time > 0 and not settings_open and not profile_open:
		_draw_level_celebration()
	if settings_open:
		_draw_settings()
	if profile_open:
		_draw_profile()
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)


func _draw_praise() -> void:
	var progress: float = clampf((praise_length-praise_timer)/0.20,0.0,1.0)
	var bounce: float = 1.0+0.16*sin(progress*PI)
	var opacity: float = minf(1.0,praise_timer*4.0)
	var center: Vector2 = Vector2(360,560)
	for i in range(3):
		var radius: float = (142.0+float(i)*44.0)*(0.8+progress*0.25)
		draw_arc(center,radius,clock*0.42+float(i)*0.6,
			clock*0.42+float(i)*0.6+PI*1.35,64,
			Color(praise_color.r,praise_color.g,praise_color.b,
				(0.21-float(i)*0.045)*opacity),3.5,true)
	draw_circle(center,188.0,Color(praise_color.r,praise_color.g,praise_color.b,0.10*opacity))
	var w: float = 420.0*bounce
	var h: float = 109.0*bounce
	var rect: Rect2 = Rect2(center-Vector2(w,h)*0.5,Vector2(w,h))
	_box(Rect2(rect.position+Vector2(0,7),rect.size),Color("#030916"),30)
	_box(rect,Color("#14142b"),29,Color(praise_color.r,praise_color.g,praise_color.b,0.85),3)
	_box(Rect2(rect.position+Vector2(8,8),rect.size-Vector2(16,16)),
		Color("#30204b"),23)
	_spark(rect.position+Vector2(20,14),12,praise_color,opacity)
	_spark(rect.end-Vector2(21,12),10,praise_color,opacity)
	_fit_center(praise,360,center.y+16,54,370,
		Color(praise_color.r,praise_color.g,praise_color.b,opacity))
	if chain_depth > 1:
		_fit_center("COMBO ×%d" % chain_depth,360,center.y-31,16,310,
			Color("#ffdaaa",opacity))
func _charged_cells() -> Array:
	if pending_group.is_empty():
		return []
	var count: int = int(pending_group["count"])
	if count < 3 or count >= Rules.POP_THRESHOLD:
		return []
	return pending_group["cells"]

# Evaluate a ball's complete discrete roll path; curve each diagonal hop
# slightly upward to suggest a bead rolling over its neighbour.
func _motion_position(item: Dictionary, progress: float) -> Vector2:
	var source: Vector2 = item["from"]
	var destination: Vector2 = item["to"]
	if motion_kind=="spin":
		var angle: float = (PI*0.5 if spin_clockwise else -PI*0.5)*progress
		return Vector2(3.5,3.5)+(source-Vector2(3.5,3.5)).rotated(angle)
	if motion_kind=="roll" and item.has("path"):
		var route: Array = item["path"]
		if route.size()>1:
			var position: float = clampf(progress,0.0,1.0)*float(route.size()-1)
			var segment: int = mini(int(position),route.size()-2)
			var fraction: float = position-float(segment)
			var a: Vector2 = route[segment]
			var b: Vector2 = route[segment+1]
			var bead: Vector2 = a.lerp(b,fraction)
			if a.x != b.x:
				bead.y -= 0.17*sin(fraction*PI)
			return bead
	return source.lerp(destination,progress)

func _draw_board() -> void:
	# Cabinet-depth border, four illuminated corners, and a living light rail.
	draw_circle(BOARD.get_center(),430.0,Color("#7c46fd",0.065+glow*0.07))
	draw_circle(BOARD.get_center(),394.0,Color("#37eafa",0.032+glow*0.05))
	_box(Rect2(17,247,686,688),Color("#03091b"),39)
	_box(Rect2(20,249,680,682),Color("#3a265d"),38,Color("#aa70f6",0.53),3)
	_box(Rect2(26,255,668,670),Color("#10182e"),32,Color("#4f619a"),2)
	_box(Rect2(35,265,650,650),Color("#080f24"),22,Color("#243b64"),2)
	_corner(Vector2(36,265),Vector2(1,1),Color("#ff85cf"),32.0)
	_corner(Vector2(684,265),Vector2(-1,1),Color("#83ecff"),32.0)
	_corner(Vector2(36,915),Vector2(1,-1),Color("#b28bff"),32.0)
	_corner(Vector2(684,915),Vector2(-1,-1),Color("#89ffd5"),32.0)
	var rail: float = 0.5+0.5*sin(clock*1.4)
	draw_line(Vector2(91,258),Vector2(297,258),Color("#ed8cff",0.29+rail*0.35),3,true)
	draw_line(Vector2(421,921),Vector2(623,921),Color("#75dafa",0.29+rail*0.35),3,true)
	# Highlight the whole target column so the 8-column touch mechanic reads.
	if phase=="drop" and hover_column >= 0 and hover_column < 8:
		var column_x: float = BOARD.position.x+float(hover_column)*CELL
		draw_rect(Rect2(column_x,BOARD.position.y,CELL,BOARD.size.y),
			Color("#8ae9e8",0.075))
	var hidden: Dictionary = {}
	if animating:
		for m in motion:
			var target: Vector2 = m["to"]
			hidden[int(target.y)*8+int(target.x)] = true
	var charged: Array = _charged_cells()
	for y in range(8):
		for x in range(8):
			var tile: Vector2 = BOARD.position+Vector2(x,y)*CELL
			_box(Rect2(tile+Vector2(2.5,2.5),Vector2(CELL-5.0,CELL-5.0)),
				Color("#131d38") if (x+y)%2==0 else Color("#192440"),12,
				Color("#2b365a"),1)
			# Light at the top of each recessed slot creates tactile separation.
			draw_line(tile+Vector2(13,5),tile+Vector2(CELL-13,5),
				Color("#9ebdff",0.085),1.7,true)
			if phase=="drop" and x==hover_column:
				draw_rect(Rect2(tile+Vector2(4,4),Vector2(CELL-8.0,CELL-8.0)),
					Color("#9df7e8",0.085))
			var center: Vector2 = tile+Vector2(CELL*0.5,CELL*0.5)
			draw_circle(center,25.0,Color("#050c21",0.58))
			draw_arc(center,25.0,PI*0.05,PI*0.92,16,Color("#8ca7f5",0.10),1.3,true)
			var occupied: bool = board[y][x] != Rules.EMPTY
			if occupied and not hidden.has(y*8+x):
				var is_pop: bool = Vector2i(x,y) in flash
				if is_pop and pop_time > 0.0:
					var progress: float = 1.0-pop_time/pop_length
					var swell: float = 1.0+0.30*sin(progress*PI)
					var tint: Color = COLORS[int(board[y][x])]
					draw_circle(center,42.0+18.0*progress,
						Color(tint.r,tint.g,tint.b,0.31*(1.0-progress)))
					_ball(center,CELL*0.365*swell,int(board[y][x]))
					_spark(center,13.0+progress*23.0,Color.WHITE,progress*0.8)
				else:
					_ball(center,CELL*0.365,int(board[y][x]))
				if Vector2i(x,y) in charged and phase == "drop":
					var pulse: float = 0.46+0.25*sin(clock*3.8)
					draw_arc(center,CELL*0.445,-PI*0.75,PI*1.25,42,
						Color("#ffd27e",pulse),3.4,true)
					if (x+y)%3==0:
						_spark(center+Vector2(22,-22),4.0,Color("#ffedbe"),pulse)
	if motion_kind=="spin" and animating:
		var step: float = clampf(motion_time/motion_duration,0.0,1.0)
		for i in range(4):
			var angle: float = float(i)*TAU/4.0+step*(PI*0.5 if spin_clockwise else -PI*0.5)
			var at: Vector2 = BOARD.get_center()+Vector2.from_angle(angle)*385
			_spark(at,7+6*sin(step*PI),Color("#adf8ff"),0.54)
	if animating:
		var raw: float = clampf(motion_time/motion_duration,0.0,1.0)
		var factor: float = raw*raw*(3.0-2.0*raw) if motion_kind=="spin" or motion_kind=="roll" else 1.0-pow(1.0-raw,3.4)
		for m in motion:
			var at: Vector2 = _motion_position(m,factor)
			var center: Vector2 = BOARD.position+(at+Vector2(0.5,0.5))*CELL
			var tint: Color = COLORS[int(m["color"])]
			# Moving marbles leave a chromatic comet trail, especially when rolling.
			var trails: int = 5 if motion_kind=="roll" else 3
			for echo in range(trails,0,-1):
				var older: float = maxf(0.0,factor-0.046*float(echo))
				var behind: Vector2 = _motion_position(m,older)
				var tail: Vector2 = BOARD.position+(behind+Vector2(0.5,0.5))*CELL
				var opacity: float = 0.04+float(trails+1-echo)*0.025
				draw_line(tail,center,Color(tint.r,tint.g,tint.b,opacity),
					5.0+float(echo)*2.1,true)
				if motion_kind=="roll" and echo%2==0:
					draw_circle(tail,2.3+float(echo)*0.7,
						Color(tint.r,tint.g,tint.b,0.24))
			var bounce: float = 0.09*sin(raw*PI)
			if motion_kind=="roll":
				bounce = 0.045*sin(raw*PI*4.0)
				var shimmer: float = 0.3+0.3*sin(clock*10.0+float(m["color"]))
				draw_arc(center,34.0,0.0,TAU,32,
					Color(tint.r,tint.g,tint.b,shimmer),2.0,true)
			var deform: Vector2 = Vector2.ONE
			if motion_kind=="roll":
				# The final contact squashes like a soft marble, then springs back.
				var contact: float = clampf((raw-0.77)/0.23,0.0,1.0)
				var squash: float = 0.13*sin(contact*PI)
				deform = Vector2(1.0+squash,1.0-squash*0.75)
			_ball(center,CELL*0.365*(1.0+bounce),int(m["color"]),1.0,deform)
			if motion_kind=="roll" and raw>0.82:
				var landing: float = (raw-0.82)/0.18
				draw_arc(center,31.0+landing*9.0,0.0,TAU,32,
					Color(1,1,1,0.27*(1.0-landing)),2.0,true)
	elif phase=="drop" and hover_column>=0 and not pieces.is_empty():
		var option: Array = pieces[clampi(selected_piece,0,pieces.size()-1)]
		var preview: Dictionary = Rules.drop(board,option,hover_column)
		if preview.get("valid",false):
			var x_start: float = BOARD.position.x+float(hover_column)*CELL
			var span: Vector2i = _piece_span(option)
			draw_rect(Rect2(x_start,BOARD.position.y,
				float(span.x)*CELL,BOARD.size.y),Color("#7fffe3",0.045))
			for m in preview.motions:
				var pos: Vector2 = m["to"]
				var center: Vector2 = BOARD.position+(pos+Vector2(0.5,0.5))*CELL
				var tint: Color = COLORS[int(m["color"])]
				draw_circle(center,35.0,Color(tint.r,tint.g,tint.b,0.18))
				draw_arc(center,32.0,0.0,TAU,48,
					Color("#d7fff7",0.64+0.16*sin(clock*5.0)),2.8,true)
				_ball(center,CELL*0.35,int(m["color"]),0.67)
		else:
			draw_rect(Rect2(BOARD.position.x+float(hover_column)*CELL,
				BOARD.position.y,CELL,BOARD.size.y),
				Color("#ff6e92",0.13))
	var used: int = Rules.tallest_column(board)
	var danger: Color = Color("#ff657e") if used >= 6 else Color("#e577a2")
	var danger_alpha: float = 0.88+0.12*sin(clock*7.0) if used >= 6 else 0.42
	draw_line(BOARD.position+Vector2(2,3),BOARD.position+Vector2(BOARD.size.x-2,3),
		Color(danger.r,danger.g,danger.b,danger_alpha),
		5.0 if used>=6 else 3.0,true)
	# Tiny numbered roof markers visually separate the eight drop lanes.
	for x in range(8):
		var marker: Vector2 = Vector2(BOARD.position.x+CELL*(float(x)+0.5),BOARD.position.y+9)
		draw_circle(marker,3,Color("#6b9ec5",0.23))

func _draw_particles() -> void:
	for ring in rings:
		var progress: float = 1.0-float(ring.life)/float(ring.max)
		var tint: Color = ring.color
		var strength: float = float(ring.strength)
		var radius: float = 15.0+progress*(55.0+strength*37.0)
		draw_circle(ring.p,13.0+progress*25.0,Color(1,1,1,0.11*(1.0-progress)))
		draw_arc(ring.p,radius,0.0,TAU,48,
			Color(tint.r,tint.g,tint.b,0.70*(1.0-progress)*(1.0-progress)),
			5.0+4.0*(1.0-progress),true)
		_spark(ring.p+Vector2.from_angle(progress*TAU)*radius,5,Color("#ffffff"),0.7*(1.0-progress))
	for p in fx:
		var fade: float = clampf(float(p.life)/float(p.max),0.0,1.0)
		var tint: Color = p.color
		if bool(p.streak):
			var dir: Vector2 = p.v.normalized()
			draw_line(p.p-dir*(8.0+17.0*fade),p.p+dir*2.0,
				Color(tint.r,tint.g,tint.b,fade),float(p.r)*0.85,true)
		else:
			draw_circle(p.p,float(p.r)*fade,Color(tint.r,tint.g,tint.b,fade))
			draw_circle(p.p,float(p.r)*2.1*fade,Color(tint.r,tint.g,tint.b,0.13*fade))
	for item in floaters:
		var fade: float = clampf(float(item.life)/float(item.max),0.0,1.0)
		var location: Vector2 = item.p-Vector2(0.0,65.0*(1.0-fade))
		var points: int = 26 if int(item.combo)==1 else 35
		var label: String = str(item.text)
		var measured: Vector2 = BOLD.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,points)
		var at: Vector2 = location-Vector2(measured.x*0.5,0.0)
		draw_string(BOLD,at+Vector2(1,3),label,HORIZONTAL_ALIGNMENT_LEFT,-1,points,
			Color(0.02,0.07,0.17,0.8*fade))
		draw_string(BOLD,at,label,HORIZONTAL_ALIGNMENT_LEFT,-1,points,
			Color(1.0,0.88,0.55,fade))
		if int(item.combo)>1:
			var combo_label: String = "×%d" % int(item.combo)
			_center(combo_label,location.x,location.y+27,24,Color(0.65,0.98,1.0,fade))


func _draw_status() -> void:
	var accent: Color = Color("#8cf8e8")
	_neon_panel(Rect2(35,935,650,76),accent)
	var actual: int = mini(int(pending_group.get("count",0)),Rules.POP_THRESHOLD)
	var bead_color: Color = COLORS[int(pending_group.get("color",0))]
	_text("%s %02d" % [t("move"),moves+1],Vector2(54,967),22,Color("#faf6ff"))
	_text(t("charge"),Vector2(232,957),15,Color("#9ab8d7"))
	for i in range(Rules.POP_THRESHOLD):
		var center: Vector2 = Vector2(246+float(i)*40,986)
		var filled: bool = i<actual
		draw_circle(center,15,Color("#080d20"))
		draw_circle(center,12.5,Color(bead_color.r,bead_color.g,bead_color.b,0.27)
			if filled else Color("#263858"))
		draw_circle(center,9.2,bead_color if filled else Color("#3b4669"))
		if filled:
			draw_circle(center-Vector2(3,3),2.9,Color(1,1,1,0.6))
		if i==actual-1 and actual>0 and actual<Rules.POP_THRESHOLD:
			draw_arc(center,16.3,0.0,TAU,40,
				Color("#ffecb9",0.56+0.35*sin(clock*4.5)),2.5,true)
	_fit_center("%d/%d" % [actual,Rules.POP_THRESHOLD],485,988,22,77,Color("#fff3c2"))
	var height_used: int = Rules.tallest_column(board)
	var danger: bool = height_used>=6
	var tint: Color = Color("#ff7fa8") if danger else Color("#7be4c8")
	_text(t("danger"),Vector2(545,959),15,
		Color("#ffc0cd") if danger else Color("#b4c1dc"))
	_box(Rect2(539,971,121,12),Color("#080f26"),6)
	_box(Rect2(542,974,115.0*float(height_used)/8.0,6),tint,3)
	_fit_center("%d / 8" % height_used,602,1001,16,117,tint)
	if danger:
		draw_line(Vector2(539,1007),Vector2(659,1007),
			Color("#ff819e",0.4+0.3*sin(clock*6.0)),2,true)


# Shared layout / gameplay mapping so mouse, drag and ghost cannot disagree.
func _piece_card_rect(index: int) -> Rect2:
	return Rect2(35+index*219,1042,207,71)

func _piece_span(piece: Array) -> Vector2i:
	var largest: Vector2i = Vector2i.ZERO
	for bead in piece:
		largest.x = maxi(largest.x,int(bead[0]))
		largest.y = maxi(largest.y,int(bead[1]))
	return largest+Vector2i.ONE

func _drop_column_at(pt: Vector2) -> int:
	if not BOARD.has_point(pt) or pieces.is_empty():
		return -1
	var width: int = _piece_span(pieces[clampi(selected_piece,0,pieces.size()-1)]).x
	var x: float = (pt.x-BOARD.position.x)/CELL
	return clampi(int(floor(x-float(width)*0.5+0.5)),0,8-width)

func _draw_drag_overlay() -> void:
	if not dragging_piece or phase!="drop" or pieces.is_empty():
		return
	var item: Array = pieces[clampi(selected_piece,0,pieces.size()-1)]
	var span: Vector2i = _piece_span(item)
	var width: float = float(span.x)*CELL
	var height: float = float(span.y)*CELL
	# Lift the silhouette above the user's fingertip, never cover it.
	var origin: Vector2 = drag_point-Vector2(width*0.5,145.0+height*0.5)
	origin.x = clampf(origin.x,12.0,720.0-width-12.0)
	origin.y = clampf(origin.y,18.0,1200.0-height)
	var allowed: bool = false
	if drag_column>=0:
		allowed = bool(Rules.drop(board,item,drag_column).get("valid",false))
	var tint: Color = Color("#a2b7ff")
	if drag_column>=0:
		tint = Color("#9fffe9") if allowed else Color("#ff9cb8")
	var halo_rect: Rect2 = Rect2(origin-Vector2(12,12),Vector2(width+24,height+24))
	_box(halo_rect,Color("#080c22",0.48),26,Color(tint.r,tint.g,tint.b,0.22),2)
	# Gentle links between touching beads preserve the selected silhouette.
	for bead in item:
		var a: Vector2 = origin+(Vector2(float(bead[0]),float(bead[1]))+Vector2(0.5,0.5))*CELL
		for peer in item:
			if int(peer[0])==int(bead[0])+1 and int(peer[1])==int(bead[1]) or int(peer[0])==int(bead[0]) and int(peer[1])==int(bead[1])+1:
				var b: Vector2 = origin+(Vector2(float(peer[0]),float(peer[1]))+Vector2(0.5,0.5))*CELL
				draw_line(a,b,Color(tint.r,tint.g,tint.b,0.3),23,true)
	for bead in item:
		var center: Vector2 = origin+(Vector2(float(bead[0]),float(bead[1]))+Vector2(0.5,0.5))*CELL
		draw_circle(center,34.0,Color(tint.r,tint.g,tint.b,0.11))
		_ball(center,28.5,int(bead[2]),0.94)
	if drag_column>=0 and not allowed:
		_center("×",drag_point.x,drag_point.y-35.0,43,Color("#ff8caa"))


func _draw_pieces() -> void:
	_text(t("next"),Vector2(47,1033),17,Color("#e6dcff"))
	for i in range(pieces.size()):
		var rect: Rect2 = _piece_card_rect(i)
		var active: bool = selected_piece==i
		var accent: Color = Color("#a1fff1") if active else Color("#8792c8")
		_neon_panel(rect,accent,active)
		if active:
			draw_rect(Rect2(rect.position+Vector2(8,8),Vector2(5,rect.size.y-16)),Color("#9af4e5"))
			_spark(rect.position+Vector2(rect.size.x-17,16),5,
				Color("#fff3bf"),0.4+0.4*sin(clock*3.0))
		var piece: Array = pieces[i]
		var span: Vector2i = _piece_span(piece)
		var step: float = minf(29.0,minf(46.0/float(maxi(1,span.y-1)),
			136.0/float(maxi(1,span.x-1))))
		var radius: float = minf(16.0,step*0.45)
		var left: float = rect.get_center().x+12.0-float(span.x-1)*step*0.5
		var top: float = rect.get_center().y-float(span.y-1)*step*0.5
		_fit_center("%02d" % (i+1),rect.position.x+23,
			rect.position.y+27,16,35,
			Color("#d7fff5") if active else Color("#9ba9cc"))
		for bead in piece:
			_ball(Vector2(left+float(bead[0])*step,top+float(bead[1])*step),
				radius,int(bead[2]),0.42 if dragging_piece and active else 1.0)
		if active and not dragging_piece:
			draw_line(rect.position+Vector2(64,62),rect.position+Vector2(178,62),
				Color("#b6fff4",0.62),2.4,true)
func _draw_button_arrow(at: Vector2, clockwise: bool, tint: Color) -> void:
	draw_arc(at,21.0,-PI*0.70 if clockwise else PI*0.30,
		PI*0.70 if clockwise else PI*1.70,26,tint,4.0,true)
	var tip: Vector2 = at+Vector2(15.0,-15.0) if clockwise else at+Vector2(-15.0,-15.0)
	draw_line(tip,tip+Vector2(-8,0) if clockwise else tip+Vector2(8,0),tint,3.8,true)
	draw_line(tip,tip+Vector2(0,9),tint,3.8,true)


func _draw_buttons() -> void:
	var enabled: bool = phase=="drop"
	for i in range(2):
		var rect: Rect2 = LEFT_RECT if i==0 else RIGHT_RECT
		var left: bool = i==0
		var accent: Color = Color("#fb76c0") if left else Color("#53e8e0")
		var bright: Color = Color("#ffb6e6") if left else Color("#c0fff3")
		var projected: int = int(preview_left.get("score",0)) if left else int(preview_right.get("score",0))
		var active: bool = enabled and tap_time>0.0 and rect.has_point(tap_point)
		var base: Color = Color("#632d77") if left else Color("#185f75")
		_box(Rect2(rect.position+Vector2(0,8),rect.size),Color("#04091b"),27)
		_box(Rect2(rect.position-Vector2(2,2),rect.size+Vector2(4,4)),
			Color(accent.r,accent.g,accent.b,0.14),29)
		_box(rect,base if enabled else Color("#222840"),26,
			accent if enabled else Color("#586079"),3)
		_box(Rect2(rect.position+Vector2(6,6),Vector2(rect.size.x-12,35)),
			Color("#b75b9e",0.24) if left and enabled else
			Color("#8bf8ff",0.18) if enabled else Color("#555674",0.14),20)
		draw_line(rect.position+Vector2(23,7),rect.position+Vector2(rect.size.x-23,7),
			Color(bright.r,bright.g,bright.b,0.65 if enabled else 0.16),2.4,true)
		var icon_at: Vector2 = rect.position+Vector2(53,46)
		draw_circle(icon_at,37,Color(accent.r,accent.g,accent.b,0.15) if enabled
			else Color("#2f3552"))
		draw_arc(icon_at,33,0,TAU,40,
			Color(bright.r,bright.g,bright.b,0.74 if enabled else 0.22),2.8,true)
		_draw_button_arrow(icon_at,not left,
			Color("#ffffff") if enabled else Color("#8490ad"))
		_fit_center(t("left") if left else t("right"),
			rect.position.x+181,rect.position.y+40,25,156,
			Color.WHITE if enabled else Color("#9fa8c2"))
		_fit_center("+%d %s" % [projected,"★"] if projected>0 else "↻ 90°",
			rect.position.x+181,rect.position.y+70,18,164,
			Color("#fff2bf") if projected>0 and enabled else
			Color("#cbafd4") if left and enabled else Color("#acdfec"))
		if active:
			draw_rect(Rect2(rect.position+Vector2(4,4),rect.size-Vector2(8,8)),
				Color(1,1,1,0.12))
		if projected>0 and enabled:
			_spark(rect.position+Vector2(rect.size.x-18,19),6,bright,
				0.45+0.38*sin(clock*3.1))
	_fit_center(t("ready"),360,1250,17,659,Color("#c7bce2"))

func _draw_game_over() -> void:
	draw_rect(Rect2(0,0,720,1280),Color("#030618",0.91))
	var center: Vector2 = Vector2(360,596)
	draw_circle(center,360,Color("#69287e",0.18))
	draw_circle(center,274,Color("#18a9ca",0.10))
	for i in range(16):
		var a: float = float(i)*TAU/16.0+clock*0.14
		var where: Vector2 = center+Vector2.from_angle(a)*(304.0+9.0*sin(clock+float(i)))
		_spark(where,5.0+float(i%4),Color("#ffdfac"),0.32+0.10*sin(clock*2.0+float(i)))
	_neon_panel(Rect2(64,375,592,593),Color("#bd95ff"),true)
	_box(Rect2(78,389,564,565),Color("#211b3d"),26,Color("#7161a4"),1)
	draw_arc(Vector2(360,484),62,PI*0.1,PI*1.9,60,
		Color("#e4b7ff",0.62),3.0,true)
	for i in range(3):
		var angle: float = clock*0.34+TAU*float(i)/3.0
		_ball(Vector2(360,480)+Vector2.from_angle(angle)*54.0,18.0,i)
	_fit_center(t("over"),360,567,51,520,Color.WHITE)
	_fit_center(t("score"),360,604,18,420,Color("#b6c5e6"))
	_fit_center(str(score),360,681,83,490,Color("#ffe5a9"))
	_fit_center(t("best")+"  "+str(best),360,718,23,460,Color("#ddc9ff"))
	_box(Rect2(RESTART_RECT.position+Vector2(0,7),RESTART_RECT.size),Color("#04091a"),25)
	_box(RESTART_RECT,Color("#50e6c9"),25,Color("#b8fff0"),3)
	_box(Rect2(RESTART_RECT.position+Vector2(7,7),Vector2(RESTART_RECT.size.x-14,26)),
		Color("#c1fff2",0.32),16)
	_fit_center(t("again"),360,777,30,462,Color("#102846"))
	_box(RESCUE_RECT,Color("#34365e"),24,Color("#8881bf"),2)
	_fit_center(("REKLAMA: +1 ŻYCIE" if language == "pl" else "WATCH AD: +1 LIFE")
		if ads != null and ads.rewarded_ready() and revives < 1
		else ("BRAK REKLAMY" if language == "pl" else "AD NOT AVAILABLE"),
		360,870,25,468,Color("#f3eaff") if ads != null and ads.rewarded_ready() and revives < 1 else Color("#9992b8"))
	_center(ad_note if not ad_note.is_empty() else
		("MAX 1 RATUNEK NA RUNDĘ" if language == "pl" else "MAX 1 REVIVE PER ROUND"),
		360,941,15,Color("#c0b5d8"))

func _draw_settings() -> void:
	draw_rect(Rect2(0,0,720,1280),Color("#030618",0.94))
	_neon_panel(Rect2(72,342,576,735),Color("#88e4ec"),true)
	_fit_center("PRYWATNOŚĆ" if language == "pl" else "PRIVACY",308,414,40,420,Color.WHITE)
	_box(SETTINGS_CLOSE,Color("#494e78"),18,Color("#a2b0d9"),2)
	_fit_center("ZAMKNIJ" if language == "pl" else "CLOSE",535,420,17,106,Color.WHITE)
	_fit_center("ANALITYKA GRY" if language == "pl" else "GAME ANALYTICS",360,513,22,445,Color("#d0e8fa"))
	_box(SETTINGS_TOGGLE,Color("#225d58") if telemetry.opted_in else Color("#40365d"),20)
	_fit_center(("WŁĄCZONA" if language == "pl" else "ON")
		if telemetry.opted_in else ("WYŁĄCZONA" if language == "pl" else "OFF"),
		360,601,26,420,Color.WHITE)
	_box(SETTINGS_ERASE,Color("#42354d"),20)
	_fit_center("USUŃ DANE LOKALNE" if language == "pl" else "CLEAR LOCAL DATA",
		360,701,21,420,Color("#ffcfdf"))
	_box(SETTINGS_AD_PRIVACY,Color("#303e61"),19)
	_fit_center("USTAWIENIA REKLAM" if language == "pl" else "AD PRIVACY OPTIONS",
		360,794,21,420,Color("#e0eeff"))
	_fit_center("Analityka jest opcjonalna. Reklamy: osobna zgoda." if language == "pl"
		else "Analytics is optional. Ads have separate consent.",
		360,855,15,530,Color("#b6c6db"))
	_box(SETTINGS_SOUND,Color("#225d58") if feedback.sound_enabled else Color("#40365d"),18)
	_fit_center(("DŹWIĘKI: TAK" if language == "pl" else "SOUND: ON")
		if feedback.sound_enabled else ("DŹWIĘKI: NIE" if language == "pl" else "SOUND: OFF"),
		360,930,23,450,Color.WHITE)
	_box(SETTINGS_HAPTICS,Color("#225d58") if feedback.haptics_enabled else Color("#40365d"),18)
	_fit_center(("WIBRACJE: TAK" if language == "pl" else "HAPTICS: ON")
		if feedback.haptics_enabled else ("WIBRACJE: NIE" if language == "pl" else "HAPTICS: OFF"),
		360,1018,23,450,Color.WHITE)

func _draw_level_celebration() -> void:
	var progress: float = 1.0-level_fx_time/3.0
	var alpha: float = clampf(level_fx_time/0.42,0.0,1.0)
	var dy: float = 18.0*sin(progress*PI)
	var center: Vector2 = Vector2(360,508-dy)
	_box(Rect2(center-Vector2(255,100),Vector2(510,200)),Color("#29214c",0.92*alpha),
		33,Color("#ffe29a",0.88*alpha),3)
	draw_circle(center,94.0+6.0*sin(clock*4.0),Color("#ffe4ae",0.12*alpha))
	_fit_center("✦ " + ("NOWY POZIOM!" if language == "pl" else "LEVEL UP!") + " ✦",
		360,center.y-22,29,466,Color(1.0,0.90,0.68,alpha))
	_fit_center(str(level_fx_number),360,center.y+65,80,354,Color(1,1,1,alpha))
	for i in range(24):
		var angle: float = float(i)*TAU/24.0+clock*0.36
		var dist: float = 128.0+progress*186.0
		var at: Vector2 = center+Vector2.from_angle(angle)*dist
		_spark(at,3.0+float(i%4),Color("#ffe6bb"),0.68*alpha*(1.0-progress*0.4))



func _draw_mission_toast() -> void:
	var strength: float = minf(1.0,mission_notice_time/0.24)
	_box(Rect2(166,879,388,56),Color("#162943",0.94*strength),22,
		Color("#f8d99e",0.7*strength),2)
	_fit_center(mission_notice,360,916,24,359,
		Color(1.0,0.91,0.66,strength))

func _draw_profile() -> void:
	draw_rect(Rect2(0,0,720,1280),Color("#030618",0.95))
	_neon_panel(PROFILE_CARD,Color("#b9a0ff"),true)
	_box(Rect2(66,236,588,880),Color("#141b38"),28,Color("#657ab2"),2)
	_fit_center(profile_t("profile"),295,309,39,440,Color.WHITE)
	_box(PROFILE_CLOSE,Color("#414b77"),18,Color("#8d9ed1"),2)
	_fit_center(profile_t("close"),572,301,17,105,Color.WHITE)
	_fit_center("%s %d" % [profile_t("level"), progression.level()],360,384,37,460,Color("#ffe6a2"))
	_fit_center(progression.level_xp_text(),360,417,18,410,Color("#bdcbf4"))
	_box(Rect2(100,433,520,15),Color("#28314f"),8)
	_box(Rect2(100,433,520*progression.level_fraction(),15),Color("#5be3c3"),8)
	_fit_center("%s  %d" % [profile_t("streak"),progression.streak],
		360,488,24,500,Color("#ffb8d8"))
	_fit_center(profile_t("daily"),360,539,25,500,Color("#edecff"))
	for i in range(Progression.MISSIONS.size()):
		var mission: Dictionary = Progression.MISSIONS[i]
		var key: String = str(mission["id"])
		var y: float = 550+float(i)*106
		var complete: bool = bool(progression.claimed.get(key,false))
		_box(Rect2(89,y,542,94),Color("#20394a") if complete else Color("#222a49"),
			18,Color("#5fe7b3") if complete else Color("#546c9e"),2)
		_text(profile_t(key),Vector2(110,y+30),20,
			Color("#ddfff1") if complete else Color.WHITE)
		var value: int = mini(int(progression.daily.get(key,0)),int(mission["target"]))
		var label: String = profile_t("done") if complete else "%d / %d" % [value,int(mission["target"])]
		_fit_center(label,539,y+32,17,154,Color("#d8f6ed") if complete else Color("#cbd6fb"))
		_box(Rect2(110,y+57,500,12),Color("#111c33"),7)
		_box(Rect2(110,y+57,500*progression.mission_ratio(key),12),
			Color("#6ee9cb") if complete else Color("#ffce84"),7)
	_fit_center(profile_t("cosmetics"),360,910,25,500,Color("#eae9ff"))
	for i in range(Progression.SKINS.size()):
		var available: Dictionary = Progression.SKINS[i]
		var id: String = str(available["id"])
		var unlocked: bool = progression.level() >= int(available["level"])
		var chosen: bool = progression.skin == id
		var x: float = 90+float(i)*181
		_box(Rect2(x,975,164,75),Color("#2b625d") if chosen else Color("#29314f"),
			18,Color("#7cfde0") if chosen else Color("#6677a5"),2)
		_fit_center(profile_t(id),x+82,1003,18,146,
			Color("#f0fff8") if unlocked else Color("#9299b4"))
		var caption: String = profile_t("selected") if chosen else (
			"%s %d" % [profile_t("locked"),int(available["level"])] if not unlocked else "✓")
		_fit_center(caption,x+82,1030,15,144,
			Color("#8bf8d8") if chosen else Color("#bac4e4"))
	_fit_center(profile_t("autoclaim"),360,1091,15,508,Color("#99a9ca"))
