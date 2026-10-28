extends Control
## POP DROP Gravity / isolated gameplay experiment. NO real ads in this scene.
const Rules = preload("res://scripts/gravity_rules.gd")
const FONT = preload("res://fonts/ClearSans-Regular.ttf")
const BOLD = preload("res://fonts/ClearSans-Bold.ttf")
const BASE := Vector2(720,1280)
const BOARD := Rect2(44,274,632,632)
const CELL := 79.0
const COLORS := [Color("#ff7096"),Color("#55dcad"),Color("#62b5ff")]
const SAVE_FILE := "user://pop_drop_gravity.json"
const LOCALES := ["pl","en","es","pt","de","fr","ru"]
const TR := {
	"pl":{"life":"ŻYCIA","tap_short":"DOTKNIJ KOLUMNY","score":"WYNIK","best":"REKORD","move":"RUCH","drop":"DOTKNIJ KOLUMNĘ, ABY ZRZUCIĆ","turn":"OBRÓĆ PLANSZĘ LUB GRAJ DALEJ","left":"W LEWO","right":"W PRAWO","skip":"DALEJ","next":"NASTĘPNE","ready":"5 KULEK POŁĄCZONYCH BOKAMI = POP  •  GÓRA = -1 ŻYCIE","over":"KONIEC RUNDY","again":"ZAGRAJ PONOWNIE","rescue":"TEST: +1 ŻYCIE","lost":"STRATA ŻYCIA","rotate_controls":"OBRACAJ PRZYCISKAMI PONIŻEJ","rotate_help":"SPRÓBUJ OBRÓCIĆ PLANSZĘ","charge":"GRUPA","danger":"WYSOKOŚĆ","danger_soon":"UWAGA: GÓRNA LINIA!","overflow":"UTRATA ŻYCIA!","hint":"Wybierz kolumnę dla spadającego kształtu"},
	"en":{"life":"LIVES","tap_short":"TAP A COLUMN","score":"SCORE","best":"BEST","move":"MOVE","drop":"TAP A COLUMN TO DROP","turn":"ROTATE OR KEEP GOING","left":"LEFT","right":"RIGHT","skip":"NEXT","next":"UP NEXT","ready":"5 TOUCHING BALLS = POP  •  TOP = -1 LIFE","over":"GAME OVER","again":"PLAY AGAIN","rescue":"TEST: +1 LIFE","lost":"LIFE LOST","rotate_controls":"ROTATE WITH THE BUTTONS BELOW","rotate_help":"ROTATE TO MAKE ROOM","charge":"GROUP","danger":"HEIGHT","danger_soon":"CAREFUL: TOP ROW!","overflow":"LIFE LOST!","hint":"Choose a column for the falling piece"},
	"es":{"life":"VIDAS","tap_short":"TOCA COLUMNA","score":"PUNTOS","best":"RÉCORD","move":"JUGADA","drop":"TOCA UNA COLUMNA PARA SOLTAR","turn":"GIRA O CONTINÚA","left":"IZQUIERDA","right":"DERECHA","skip":"SEGUIR","next":"SIGUIENTES","ready":"5 BOLAS CONECTADAS = POP  •  ARRIBA = -1 VIDA","over":"FIN DEL JUEGO","again":"JUGAR OTRA VEZ","rescue":"PRUEBA: +1 VIDA","lost":"VIDA PERDIDA","rotate_controls":"USA LOS BOTONES PARA GIRAR","rotate_help":"GIRA PARA HACER ESPACIO","charge":"GRUPO","danger":"ALTURA","danger_soon":"¡FILA SUPERIOR!","overflow":"¡VIDA PERDIDA!","hint":"Elige una columna para las bolas"},
	"pt":{"life":"VIDAS","tap_short":"TOQUE A COLUNA","score":"PONTOS","best":"RECORDE","move":"JOGADA","drop":"TOQUE NA COLUNA PARA SOLTAR","turn":"GIRE OU CONTINUE","left":"ESQUERDA","right":"DIREITA","skip":"SEGUIR","next":"PRÓXIMAS","ready":"5 BOLAS CONECTADAS = POP  •  TOPO = -1 VIDA","over":"FIM DE JOGO","again":"JOGAR DE NOVO","rescue":"TESTE: +1 VIDA","lost":"VIDA PERDIDA","rotate_controls":"USE OS BOTÕES PARA GIRAR","rotate_help":"GIRE PARA ABRIR ESPAÇO","charge":"GRUPO","danger":"ALTURA","danger_soon":"CUIDADO: TOPO!","overflow":"VIDA PERDIDA!","hint":"Escolha uma coluna para jogar"},
	"de":{"life":"LEBEN","tap_short":"SPALTE TIPPEN","score":"PUNKTE","best":"REKORD","move":"ZUG","drop":"SPALTE ANTIPPEN ZUM FALLEN","turn":"DREHEN ODER WEITER","left":"LINKS","right":"RECHTS","skip":"WEITER","next":"ALS NÄCHSTES","ready":"5 VERBUNDENE KUGELN = POP  •  OBEN = -1 LEBEN","over":"SPIEL VORBEI","again":"NOCHMAL SPIELEN","rescue":"TEST: +1 LEBEN","lost":"LEBEN VERLOREN","rotate_controls":"MIT DEN TASTEN UNTEN DREHEN","rotate_help":"DREHE FÜR MEHR PLATZ","charge":"GRUPPE","danger":"HÖHE","danger_soon":"ACHTUNG: OBERSTE REIHE!","overflow":"LEBEN VERLOREN!","hint":"Wähle eine Spalte zum Einwerfen"},
	"fr":{"life":"VIES","tap_short":"TOUCHE COLONNE","score":"SCORE","best":"RECORD","move":"COUP","drop":"TOUCHE UNE COLONNE POUR LÂCHER","turn":"TOURNE OU CONTINUE","left":"GAUCHE","right":"DROITE","skip":"SUITE","next":"À SUIVRE","ready":"5 BILLES CONNECTÉES = POP  •  HAUT = -1 VIE","over":"PARTIE FINIE","again":"REJOUER","rescue":"TEST : +1 VIE","lost":"VIE PERDUE","rotate_controls":"TOURNE AVEC LES BOUTONS","rotate_help":"TOURNE POUR LIBÉRER DE LA PLACE","charge":"GROUPE","danger":"HAUTEUR","danger_soon":"ATTENTION AU SOMMET!","overflow":"VIE PERDUE!","hint":"Choisis une colonne pour les billes"},
	"ru":{"life":"ЖИЗНИ","tap_short":"ВЫБЕРИ СТОЛБЕЦ","score":"ОЧКИ","best":"РЕКОРД","move":"ХОД","drop":"НАЖМИ СТОЛБЕЦ ДЛЯ СБРОСА","turn":"ПОВЕРНИ ИЛИ ПРОДОЛЖИ","left":"ВЛЕВО","right":"ВПРАВО","skip":"ДАЛЕЕ","next":"СЛЕДУЮЩИЕ","ready":"5 СОЕДИНЁННЫХ ШАРОВ = POP  •  ВЕРХ = -1 ЖИЗНЬ","over":"ИГРА ОКОНЧЕНА","again":"ИГРАТЬ СНОВА","rescue":"ТЕСТ: +1 ЖИЗНЬ","lost":"МИНУС ЖИЗНЬ","rotate_controls":"ПОВОРОТ КНОПКАМИ ВНИЗУ","rotate_help":"ПОВЕРНИ, ЧТОБЫ ОСВОБОДИТЬ МЕСТО","charge":"ГРУППА","danger":"ВЫСОТА","danger_soon":"ВНИМАНИЕ: ВЕРХ!","overflow":"МИНУС ЖИЗНЬ!","hint":"Выбери столбец для шариков"}
}
const LEFT_RECT := Rect2(35,1123,285,92)
const RIGHT_RECT := Rect2(400,1123,285,92)
const RESTART_RECT := Rect2(104,722,512,84)
const RESCUE_RECT := Rect2(104,821,512,79)

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

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	rng.randomize()
	var detected: String = OS.get_locale_language().to_lower()
	language = detected if detected in LOCALES else "en"
	if FileAccess.file_exists(SAVE_FILE):
		var saved = JSON.parse_string(FileAccess.get_file_as_string(SAVE_FILE))
		if saved is Dictionary:
			best = int(saved.get("best",0))
			var remembered: String = str(saved.get("language",language))
			if remembered in LOCALES:
				language = remembered
	new_game()

func t(key: String) -> String:
	return str(TR.get(language,TR["en"]).get(key,key))

func _save() -> void:
	var f: FileAccess = FileAccess.open(SAVE_FILE,FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"best":best,"language":language}))

func new_game() -> void:
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
	queue_redraw()

func _process(delta: float) -> void:
	clock += delta
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
		var pt: Vector2 = _logical(event.position)
		hover_column = -1
		if BOARD.has_point(pt):
			hover_column = int((pt.x-BOARD.position.x)/CELL)
		queue_redraw()
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	var pt: Vector2 = _logical(event.position)
	tap_point = pt
	tap_time = 0.42
	if phase == "anim":
		# Buffer one action instead of making rapid taps feel unresponsive.
		if LEFT_RECT.has_point(pt):
			queued_action = "left"
		elif RIGHT_RECT.has_point(pt):
			queued_action = "right"
		elif BOARD.has_point(pt):
			queued_action = "drop"
			queued_column = int((pt.x-BOARD.position.x)/CELL)
		return
	if phase == "over":
		if RESTART_RECT.has_point(pt):
			new_game()
		elif RESCUE_RECT.has_point(pt):
			revives += 1 # Explicit test reward, NOT an ad callback.
			lives = 1
			board = Rules.rescue(board)
			pieces[0] = Rules.next_piece(rng,board,recent_shapes)
			_remember_shape(pieces[0])
			phase = "drop"
			_refresh_targets()
			_praise("+1 ♥",Color("#ff9bb7"),1.2)
			queue_redraw()
		return
	if Rect2(576,53,100,53).has_point(pt):
		var index: int = LOCALES.find(language)
		language = LOCALES[(index+1)%LOCALES.size()]
		_save()
		queue_redraw()
		return
	if phase != "drop":
		return
	if LEFT_RECT.has_point(pt):
		_rotate_board(false)
	elif RIGHT_RECT.has_point(pt):
		_rotate_board(true)
	elif BOARD.has_point(pt):
		_play_drop(int((pt.x-BOARD.position.x)/CELL))

func _play_drop(column: int) -> void:
	if phase != "drop":
		return
	var result: Dictionary = Rules.drop(board,pieces[0],column)
	if not result.get("valid",false):
		_praise(t("hint"),Color("#ff8ba8"),0.8)
		return
	phase = "anim"
	moves += 1
	chain_depth = 0
	await _animate_to(result.board,result.motions,0.23,"drop")
	# Matching 5+ touching balls POP immediately after any successful drop.
	# Resolve every resulting cascade BEFORE checking overflow or advancing.
	await _resolve_cascades()
	# No Next button: the next shape is ready immediately after this drop.
	_advance_piece()
	phase = "drop"
	_check_ceiling()
	if phase == "drop":
		_refresh_targets()
		_check_stuck()
	_flush_queued_input()
	queue_redraw()

func _rotate_board(clockwise: bool) -> void:
	if phase != "drop":
		return
	phase = "anim"
	chain_depth = 0 # Each action has its own independent cascade multiplier.
	spin_clockwise = clockwise
	var turned: Dictionary = Rules.rotate(board,clockwise)
	_shock(BOARD.get_center(),1.15,Color("#78d9ff"))
	await _animate_to(turned.board,turned.motions,0.27,"spin")
	var gravity: Dictionary = Rules.settle(board)
	await _animate_to(gravity.board,gravity.motions,0.19,"fall")
	await _resolve_cascades()
	phase = "drop"
	_check_ceiling()
	if phase == "drop":
		_refresh_targets()
		_check_stuck()
	_flush_queued_input()
	queue_redraw()

func _flush_queued_input() -> void:
	var action: String = queued_action
	var column: int = queued_column
	queued_action = ""
	queued_column = -1
	if phase != "drop":
		return
	if action == "left":
		call_deferred("_rotate_board",false)
	elif action == "right":
		call_deferred("_rotate_board",true)
	elif action == "drop" and column >= 0:
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

func _advance_piece() -> void:
	pieces.pop_front()
	var next: Array = Rules.next_piece(rng,board,recent_shapes)
	pieces.append(next)
	_remember_shape(next)

func _could_recover_by_rotating(piece: Array) -> bool:
	# A player may rotate without dropping. Do not take a life if
	# there is still a viable path to place the currently offered piece.
	for clockwise in [false,true]:
		var virtual: Array = Rules.copy_board(board)
		for quarter in range(4):
			virtual = Rules.rotate(virtual,clockwise).board
			virtual = Rules.settle(virtual).board
			for cascade in range(20):
				var hits: Array = Rules.find_matches(virtual)
				if hits.is_empty():
					break
				virtual = Rules.settle(Rules.erase_matches(virtual,hits)).board
			if Rules.any_drop(virtual,piece):
				return true
	return false

func _check_ceiling() -> void:
	# Reaching the clearly highlighted top row costs one life, even if there
	# are other empty columns. Rotating can prevent the loss beforehand.
	if not Rules.ceiling_reached(board):
		return
	lives -= 1
	_praise(t("overflow"),Color("#ff879d"),1.3)
	_shock(BOARD.position+Vector2(BOARD.size.x*0.5,CELL*0.5),2.5,Color("#ff6389"))
	if lives <= 0:
		phase = "over"
	else:
		# Remove the highest two occupied rows, settle and keep playing.
		board = Rules.rescue(board)
	queue_redraw()

func _check_stuck() -> void:
	if phase != "drop" or pieces.is_empty():
		return
	if Rules.any_drop(board,pieces[0]):
		return
	if _could_recover_by_rotating(pieces[0]):
		_praise(t("rotate_help"),Color("#ffe49c"),1.1)
		return
	lives -= 1
	_praise(t("lost"),Color("#ff8ca4"),1.2)
	if lives <= 0:
		phase = "over"
	else:
		board = Rules.rescue(board)
		pieces[0] = Rules.next_piece(rng,board,recent_shapes)
		_remember_shape(pieces[0])
		if not Rules.any_drop(board,pieces[0]):
			# Let the next input recover the board; no recursive losses.
			board = Rules.empty_board()
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
	if kind != "spin":
		_shock(BOARD.get_center(),0.38 if kind == "fall" else 0.58,Color("#a2e9ff"))
	queue_redraw()

func _resolve_cascades() -> void:
	# Called after both a successful drop and a board rotation.
	for depth in range(20):
		var groups: Array = Rules.find_groups(board)
		if groups.is_empty():
			return
		chain_depth += 1
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
		best = maxi(best,score)
		_save()
		flash.clear()
		pop_time = 0.0
		queue_redraw()
		var gravity: Dictionary = Rules.settle(board)
		await _animate_to(gravity.board,gravity.motions,0.20,"fall")

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

func _ball(center: Vector2, radius: float, color_index: int, alpha: float=1.0) -> void:
	var base: Color = COLORS[clampi(color_index,0,COLORS.size()-1)]
	var light: Color = base.lightened(0.40)
	# Multi-layer candy gem: bloom, contact shadow, metallic rim, coloured glass.
	draw_circle(center+Vector2(1.8,7.0),radius+5.5,Color("#030714",0.49*alpha))
	draw_circle(center,radius+11.0,Color(base.r,base.g,base.b,0.055*alpha))
	draw_circle(center,radius+6.4,Color(base.r,base.g,base.b,0.13*alpha))
	draw_circle(center,radius+1.8,Color(0.91,0.94,1.0,0.63*alpha))
	draw_circle(center,radius,Color(base.r*0.47,base.g*0.47,base.b*0.53,alpha))
	draw_circle(center-Vector2(0.6,2.0),radius-2.8,Color(base.r,base.g,base.b,alpha))
	draw_circle(center+Vector2(radius*0.1,radius*0.29),radius*0.66,
		Color(base.r*0.48,base.g*0.49,base.b*0.57,0.38*alpha))
	draw_circle(center-Vector2(radius*0.19,radius*0.25),radius*0.56,
		Color(light.r,light.g,light.b,0.24*alpha))
	draw_circle(center-Vector2(radius*0.27,radius*0.35),radius*0.32,
		Color(1,1,1,0.38*alpha))
	draw_circle(center-Vector2(radius*0.40,radius*0.47),radius*0.105,
		Color(1,1,1,0.91*alpha))
	draw_arc(center-Vector2(0.3,1.2),radius-4.3,3.45,5.53,18,
		Color(1,1,1,0.47*alpha),2.7,true)
	draw_arc(center+Vector2(0.3,0.8),radius-3.8,0.20,1.39,14,
		Color(1,1,1,0.27*alpha),2.5,true)
	# A tiny accent highlight travels around the rim, without a shader.
	if radius >= 22.0:
		var orbit: float = clock*0.76+float(color_index)*2.2
		var spot: Vector2 = center+Vector2.from_angle(orbit)*radius*0.74
		draw_circle(spot,2.2,Color(1,1,1,(0.16+0.14*sin(clock*2.0))*alpha))

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
	_draw_tap_ripple()
	if glow > 0.0:
		draw_rect(Rect2(0,0,720,1280),Color(0.8,0.94,1.0,0.055*glow))
	if praise_timer > 0.0 and phase != "over":
		_draw_praise()
	if phase == "over":
		_draw_game_over()
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
		var factor: float = raw*raw*(3.0-2.0*raw) if motion_kind=="spin" else 1.0-pow(1.0-raw,3.4)
		for m in motion:
			var from: Vector2 = m["from"]
			var dest: Vector2 = m["to"]
			var at: Vector2 = from.lerp(dest,factor)
			if motion_kind == "spin":
				var angle: float = (PI*0.5 if spin_clockwise else -PI*0.5)*factor
				at = Vector2(3.5,3.5)+(from-Vector2(3.5,3.5)).rotated(angle)
			var center: Vector2 = BOARD.position+(at+Vector2(0.5,0.5))*CELL
			var tint: Color = COLORS[int(m["color"])]
			for echo in range(3,0,-1):
				var older: float = maxf(0.0,factor-0.043*float(echo))
				var behind: Vector2 = from.lerp(dest,older)
				if motion_kind == "spin":
					var a: float = (PI*0.5 if spin_clockwise else -PI*0.5)*older
					behind = Vector2(3.5,3.5)+(from-Vector2(3.5,3.5)).rotated(a)
				var tail: Vector2 = BOARD.position+(behind+Vector2(0.5,0.5))*CELL
				draw_line(tail,center,Color(tint.r,tint.g,tint.b,0.07+float(echo)*0.02),
					6.0+float(echo)*1.5,true)
			_ball(center,CELL*0.365*(1.0+0.10*sin(raw*PI)),int(m["color"]))
	elif phase=="drop" and hover_column>=0 and not pieces.is_empty():
		var preview: Dictionary = Rules.drop(board,pieces[0],hover_column)
		if preview.get("valid",false):
			for m in preview.motions:
				var pos: Vector2 = m["to"]
				_ball(BOARD.position+(pos+Vector2(0.5,0.5))*CELL,
					CELL*0.33,int(m["color"]),0.52)
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

func _draw_pieces() -> void:
	_text(t("next"),Vector2(47,1033),16,Color("#e6dcff"))
	for i in range(3):
		var rect: Rect2 = Rect2(35+i*219,1042,207,71)
		var active: bool = i==0
		var accent: Color = Color("#a1fff1") if active else Color("#7388b7")
		_neon_panel(rect,accent,active)
		if active:
			draw_rect(Rect2(rect.position+Vector2(8,8),Vector2(5,rect.size.y-16)),
				Color("#9af4e5"))
			_spark(rect.position+Vector2(rect.size.x-17,16),4,
				Color("#fff3bf"),0.4+0.4*sin(clock*3.0))
		_fit_center("%02d" % (i+1),rect.position.x+23,
			rect.position.y+27,16,35,
			Color("#d7fff5") if active else Color("#9ba9cc"))
		if i>=pieces.size():
			continue
		var piece: Array = pieces[i]
		var max_x: int = 0
		var max_y: int = 0
		for bead in piece:
			max_x = maxi(max_x,int(bead[0]))
			max_y = maxi(max_y,int(bead[1]))
		var step: float = minf(29.0,minf(46.0/float(maxi(1,max_y)),
			136.0/float(maxi(1,max_x))))
		var radius: float = minf(16.0,step*0.45)
		var left: float = rect.get_center().x+12.0-float(max_x)*step*0.5
		var top: float = rect.get_center().y-float(max_y)*step*0.5
		for bead in piece:
			_ball(Vector2(left+float(bead[0])*step,
				top+float(bead[1])*step),radius,int(bead[2]))
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
	_fit_center(t("rescue"),360,870,26,468,Color("#f3eaff"))
	_center("DEMO · NO ADS",360,941,15,Color("#c0b5d8"))
