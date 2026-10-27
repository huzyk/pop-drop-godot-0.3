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
	"pl":{"score":"WYNIK","best":"REKORD","move":"RUCH","drop":"DOTKNIJ KOLUMNĘ, ABY ZRZUCIĆ","turn":"OBRÓĆ PLANSZĘ LUB GRAJ DALEJ","left":"W LEWO","right":"W PRAWO","skip":"DALEJ","next":"NASTĘPNE","ready":"5 KULEK POŁĄCZONYCH BOKAMI = POP  •  GÓRA = -1 ŻYCIE","over":"KONIEC RUNDY","again":"ZAGRAJ PONOWNIE","rescue":"TEST: +1 ŻYCIE","lost":"STRATA ŻYCIA","rotate_controls":"OBRACAJ PRZYCISKAMI PONIŻEJ","rotate_help":"SPRÓBUJ OBRÓCIĆ PLANSZĘ","charge":"GRUPA","danger":"WYSOKOŚĆ","danger_soon":"UWAGA: GÓRNA LINIA!","overflow":"UTRATA ŻYCIA!","hint":"Wybierz kolumnę dla spadającego kształtu"},
	"en":{"score":"SCORE","best":"BEST","move":"MOVE","drop":"TAP A COLUMN TO DROP","turn":"ROTATE OR KEEP GOING","left":"LEFT","right":"RIGHT","skip":"NEXT","next":"UP NEXT","ready":"5 TOUCHING BALLS = POP  •  TOP = -1 LIFE","over":"GAME OVER","again":"PLAY AGAIN","rescue":"TEST: +1 LIFE","lost":"LIFE LOST","rotate_controls":"ROTATE WITH THE BUTTONS BELOW","rotate_help":"ROTATE TO MAKE ROOM","charge":"GROUP","danger":"HEIGHT","danger_soon":"CAREFUL: TOP ROW!","overflow":"LIFE LOST!","hint":"Choose a column for the falling piece"},
	"es":{"score":"PUNTOS","best":"RÉCORD","move":"JUGADA","drop":"TOCA UNA COLUMNA PARA SOLTAR","turn":"GIRA O CONTINÚA","left":"IZQUIERDA","right":"DERECHA","skip":"SEGUIR","next":"SIGUIENTES","ready":"5 BOLAS CONECTADAS = POP  •  ARRIBA = -1 VIDA","over":"FIN DEL JUEGO","again":"JUGAR OTRA VEZ","rescue":"PRUEBA: +1 VIDA","lost":"VIDA PERDIDA","rotate_controls":"USA LOS BOTONES PARA GIRAR","rotate_help":"GIRA PARA HACER ESPACIO","charge":"GRUPO","danger":"ALTURA","danger_soon":"¡FILA SUPERIOR!","overflow":"¡VIDA PERDIDA!","hint":"Elige una columna para las bolas"},
	"pt":{"score":"PONTOS","best":"RECORDE","move":"JOGADA","drop":"TOQUE NA COLUNA PARA SOLTAR","turn":"GIRE OU CONTINUE","left":"ESQUERDA","right":"DIREITA","skip":"SEGUIR","next":"PRÓXIMAS","ready":"5 BOLAS CONECTADAS = POP  •  TOPO = -1 VIDA","over":"FIM DE JOGO","again":"JOGAR DE NOVO","rescue":"TESTE: +1 VIDA","lost":"VIDA PERDIDA","rotate_controls":"USE OS BOTÕES PARA GIRAR","rotate_help":"GIRE PARA ABRIR ESPAÇO","charge":"GRUPO","danger":"ALTURA","danger_soon":"CUIDADO: TOPO!","overflow":"VIDA PERDIDA!","hint":"Escolha uma coluna para jogar"},
	"de":{"score":"PUNKTE","best":"REKORD","move":"ZUG","drop":"SPALTE ANTIPPEN ZUM FALLEN","turn":"DREHEN ODER WEITER","left":"LINKS","right":"RECHTS","skip":"WEITER","next":"ALS NÄCHSTES","ready":"5 VERBUNDENE KUGELN = POP  •  OBEN = -1 LEBEN","over":"SPIEL VORBEI","again":"NOCHMAL SPIELEN","rescue":"TEST: +1 LEBEN","lost":"LEBEN VERLOREN","rotate_controls":"MIT DEN TASTEN UNTEN DREHEN","rotate_help":"DREHE FÜR MEHR PLATZ","charge":"GRUPPE","danger":"HÖHE","danger_soon":"ACHTUNG: OBERSTE REIHE!","overflow":"LEBEN VERLOREN!","hint":"Wähle eine Spalte zum Einwerfen"},
	"fr":{"score":"SCORE","best":"RECORD","move":"COUP","drop":"TOUCHE UNE COLONNE POUR LÂCHER","turn":"TOURNE OU CONTINUE","left":"GAUCHE","right":"DROITE","skip":"SUITE","next":"À SUIVRE","ready":"5 BILLES CONNECTÉES = POP  •  HAUT = -1 VIE","over":"PARTIE FINIE","again":"REJOUER","rescue":"TEST : +1 VIE","lost":"VIE PERDUE","rotate_controls":"TOURNE AVEC LES BOUTONS","rotate_help":"TOURNE POUR LIBÉRER DE LA PLACE","charge":"GROUPE","danger":"HAUTEUR","danger_soon":"ATTENTION AU SOMMET!","overflow":"VIE PERDUE!","hint":"Choisis une colonne pour les billes"},
	"ru":{"score":"ОЧКИ","best":"РЕКОРД","move":"ХОД","drop":"НАЖМИ СТОЛБЕЦ ДЛЯ СБРОСА","turn":"ПОВЕРНИ ИЛИ ПРОДОЛЖИ","left":"ВЛЕВО","right":"ВПРАВО","skip":"ДАЛЕЕ","next":"СЛЕДУЮЩИЕ","ready":"5 СОЕДИНЁННЫХ ШАРОВ = POP  •  ВЕРХ = -1 ЖИЗНЬ","over":"ИГРА ОКОНЧЕНА","again":"ИГРАТЬ СНОВА","rescue":"ТЕСТ: +1 ЖИЗНЬ","lost":"МИНУС ЖИЗНЬ","rotate_controls":"ПОВОРОТ КНОПКАМИ ВНИЗУ","rotate_help":"ПОВЕРНИ, ЧТОБЫ ОСВОБОДИТЬ МЕСТО","charge":"ГРУППА","danger":"ВЫСОТА","danger_soon":"ВНИМАНИЕ: ВЕРХ!","overflow":"МИНУС ЖИЗНЬ!","hint":"Выбери столбец для шариков"}
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

func _text(value: String, at: Vector2, pt: int, color: Color, bold: bool=true) -> void:
	draw_string(BOLD if bold else FONT,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,pt,color)

func _center(value: String, center_x: float, baseline: float, pt: int, color: Color, bold: bool=true) -> void:
	var font: Font = BOLD if bold else FONT
	var measured: Vector2 = font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,pt)
	draw_string(font,Vector2(center_x-measured.x*0.5,baseline),value,HORIZONTAL_ALIGNMENT_LEFT,-1,pt,color)

func _ball(center: Vector2, radius: float, color_index: int, alpha: float=1.0) -> void:
	var c: Color = COLORS[clampi(color_index,0,COLORS.size()-1)]
	c.a = alpha
	# Soft halo + hard glossy core keep the marbles legible on small phones.
	draw_circle(center,radius+8.0,Color(c.r,c.g,c.b,0.055*alpha))
	draw_circle(center+Vector2(0,5),radius+3,Color(0,0,0,0.26*alpha))
	draw_circle(center,radius,c.darkened(0.30))
	draw_circle(center-Vector2(0,2),maxf(1.0,radius-3),c)
	draw_circle(center+Vector2(-radius*0.30,-radius*0.38),radius*0.29,Color(1,1,1,0.40*alpha))
	draw_arc(center-Vector2(0,1),maxf(2.0,radius-3),0.25,2.95,18,Color(1,1,1,0.20*alpha),2.7,true)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("#0a1026"))
	draw_set_transform(_offset(),0,Vector2.ONE*_scale())
	draw_rect(Rect2(0,0,720,1280),Color("#111d3c"))
	draw_circle(Vector2(145,280),330,Color("#51327b",0.22))
	draw_circle(Vector2(575,940),280,Color("#255f80",0.18))
	# Slow ambient motes, distinct from gameplay sparks.
	for i in range(24):
		var star_pos: Vector2 = Vector2(fmod(float(i*151+37),700.0)+10.0,
			fmod(float(i*239+73)-clock*(4.0+float(i%4)),1230.0)+25.0)
		draw_circle(star_pos,1.6+float(i%3)*0.5,
			Color(0.72,0.85,1.0,0.11+0.07*sin(clock*1.7+float(i))))
	_box(Rect2(35,33,650,116),Color("#1a2a51"),25,Color("#435c86"),2)
	_text("POP",Vector2(66,108),58,Color.WHITE)
	_text("DROP",Vector2(196,108),58,Color("#6ef0d9"))
	_box(Rect2(448,57,112,50),Color("#2a4271"),18)
	_center("GRAVITY",504,89,16,Color("#fbe19b"))
	_box(Rect2(576,53,100,53),Color("#2a4271"),18)
	_center(language.to_upper(),626,88,22,Color.WHITE)
	_box(Rect2(35,166,322,95),Color("#192a50"),20)
	_box(Rect2(372,166,313,95),Color("#192a50"),20)
	_text(t("score"),Vector2(58,198),16,Color("#9cb6de"))
	_text(str(int(round(display_score))),Vector2(58,243),39,Color.WHITE)
	_text(t("best"),Vector2(392,198),16,Color("#9cb6de"))
	_text(str(best),Vector2(392,243),39,Color("#ffe08e"))
	for i in range(3):
		_text("♥",Vector2(574+i*32,196),26,Color("#ff7396") if i<lives else Color("#536083"))
	var shake: Vector2 = Vector2.ZERO
	if shake_time > 0.0:
		var falloff: float = shake_time/0.18
		shake = Vector2(sin(clock*105.0),cos(clock*131.0))*shake_force*falloff*falloff
	draw_set_transform(_offset()+shake*_scale(),0,Vector2.ONE*_scale())
	_draw_board()
	_draw_particles()
	draw_set_transform(_offset(),0,Vector2.ONE*_scale())
	_draw_pieces()
	_draw_buttons()
	if glow > 0.0:
		draw_rect(Rect2(0,0,720,1280),Color(0.77,0.91,1.0,0.08*glow))
	if praise_timer > 0 and phase != "over":
		var enter: float = clampf((praise_length-praise_timer)/0.14,0.0,1.0)
		var bounce: float = 1.0+0.16*sin(enter*PI)
		var panel: Rect2 = Rect2(360.0-199.0*bounce,567.0-51.5*bounce,
			398.0*bounce,103.0*bounce)
		_box(panel,Color("#101d3b",0.84*minf(1.0,praise_timer*5.0)),26,
			Color(praise_color.r,praise_color.g,praise_color.b,0.4),2)
		_center(praise,360,588,roundi(42.0*bounce),praise_color)
	if phase == "over":
		_draw_game_over()
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

func _charged_cells() -> Array:
	if pending_group.is_empty():
		return []
	var count: int = int(pending_group["count"])
	if count < 3 or count >= Rules.POP_THRESHOLD:
		return []
	return pending_group["cells"]

func _draw_board() -> void:
	var rim: Color = Color("#6d8bc6").lerp(Color("#ffda9e"),glow)
	_box(Rect2(24,254,672,672),Color("#74d3fa",0.06+glow*0.12),30)
	_box(Rect2(29,259,662,662),Color("#273a68"),27,rim,3)
	if motion_kind == "spin" and animating:
		var spin_progress: float = clampf(motion_time/motion_duration,0.0,1.0)
		for j in range(4):
			var direction: float = float(j)*TAU/4.0+spin_progress*(PI*0.5 if spin_clockwise else -PI*0.5)
			var corner: Vector2 = BOARD.get_center()+Vector2.from_angle(direction)*385.0
			draw_circle(corner,9.0+4.0*sin(spin_progress*PI),Color("#9defff",0.4))
	var hidden: Dictionary = {}
	if animating:
		for m in motion:
			var dest: Vector2 = m["to"]
			hidden[int(dest.y)*8+int(dest.x)] = true
	for y in range(8):
		for x in range(8):
			var cell: Vector2 = BOARD.position+Vector2(x,y)*CELL
			_box(Rect2(cell+Vector2(3,3),Vector2(CELL-6,CELL-6)),
				Color("#1a2c54") if (x+y)%2==0 else Color("#20345e"),13)
			var center: Vector2 = cell+Vector2(CELL*0.5,CELL*0.5)
			var is_pop: bool = Vector2i(x,y) in flash
			if board[y][x] != Rules.EMPTY and not hidden.has(y*8+x):
				if is_pop and pop_time > 0.0:
					var progress: float = 1.0-pop_time/pop_length
					var swell: float = 1.0+0.27*sin(progress*PI)-0.17*pow(progress,5.0)
					var tint: Color = COLORS[int(board[y][x])]
					draw_circle(center,46.0+14.0*progress,
						Color(tint.r,tint.g,tint.b,0.28*(1.0-progress)))
					draw_circle(center,38.0,Color(1,1,1,0.28*progress))
					_ball(center,CELL*0.36*swell,int(board[y][x]))
				else:
					_ball(center,CELL*0.36,int(board[y][x]))
				# Groups of 3 or 4 are close to POP. Highlight their
				# progress, not 5+ clusters that should already be gone.
				if phase == "drop" and Vector2i(x,y) in _charged_cells():
					var pulse: float = 0.42+0.19*sin(clock*3.2)
					draw_arc(center,CELL*0.40,0.0,TAU,30,
						Color(1.0,0.86,0.49,pulse),2.8,true)
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
			# Temporal echoes give rotation a circular luminous streak.
			for echo in range(3,0,-1):
				var older: float = maxf(0.0,factor-0.045*float(echo))
				var behind: Vector2 = from.lerp(dest,older)
				if motion_kind == "spin":
					var a: float = (PI*0.5 if spin_clockwise else -PI*0.5)*older
					behind = Vector2(3.5,3.5)+(from-Vector2(3.5,3.5)).rotated(a)
				var tail: Vector2 = BOARD.position+(behind+Vector2(0.5,0.5))*CELL
				draw_line(tail,center,Color(tint.r,tint.g,tint.b,0.055+float(echo)*0.02),8.0,true)
			var stretch: float = 1.0+0.10*sin(raw*PI)
			_ball(center,CELL*0.36*stretch,int(m["color"]))
			if raw > 0.75 and motion_kind != "spin":
				draw_arc(center,33.0+7.0*(1.0-raw),0.0,TAU,28,
					Color(tint.r,tint.g,tint.b,0.28*(1.0-raw)),2.5,true)
	elif phase=="drop" and hover_column>=0 and not pieces.is_empty():
		var preview: Dictionary = Rules.drop(board,pieces[0],hover_column)
		if preview.get("valid",false):
			for m in preview.motions:
				var pos: Vector2 = m["to"]
				_ball(BOARD.position+(pos+Vector2(0.5,0.5))*CELL,CELL*0.33,int(m["color"]),0.50)
	# The first row is the loss boundary. Warn before the player fills it.
	var height_used: int = Rules.tallest_column(board)
	var ceiling_color: Color = Color("#ff6480") if height_used >= 6 else Color("#b05c89")
	draw_line(BOARD.position+Vector2(0,2),
		BOARD.position+Vector2(BOARD.size.x,2),
		Color(ceiling_color.r,ceiling_color.g,ceiling_color.b,0.60 if height_used < 6 else 0.95),
		4.0 if height_used < 6 else 6.0,true)
	# Tutorial: column and objective are always obvious without a manual.
	if phase=="drop":
		_center(t("drop"),360,302,15,Color("#def9ee"))

func _draw_particles() -> void:
	for ring in rings:
		var progress: float = 1.0-float(ring.life)/float(ring.max)
		var tint: Color = ring.color
		var strength: float = float(ring.strength)
		var radius: float = 15.0+progress*(55.0+strength*37.0)
		draw_circle(ring.p,13.0+progress*25.0,
			Color(1,1,1,0.13*(1.0-progress)))
		draw_arc(ring.p,radius,0.0,TAU,48,
			Color(tint.r,tint.g,tint.b,0.70*(1.0-progress)*(1.0-progress)),
			5.0+4.0*(1.0-progress),true)
	for p in fx:
		var a: float = clampf(float(p.life)/float(p.max),0.0,1.0)
		var tint: Color = p.color
		if bool(p.streak):
			var direction: Vector2 = p.v.normalized()
			draw_line(p.p-direction*(8.0+17.0*a),p.p+direction*2.0,
				Color(tint.r,tint.g,tint.b,a),float(p.r)*0.85,true)
		else:
			draw_circle(p.p,float(p.r)*a,Color(tint.r,tint.g,tint.b,a))
			draw_circle(p.p,float(p.r)*2.1*a,Color(tint.r,tint.g,tint.b,0.13*a))
	for item in floaters:
		var life_fraction: float = clampf(float(item.life)/float(item.max),0.0,1.0)
		var location: Vector2 = item.p-Vector2(0.0,65.0*(1.0-life_fraction))
		var points: int = 26 if int(item.combo) == 1 else 35
		var label: String = str(item.text)
		var measured: Vector2 = BOLD.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,points)
		var at: Vector2 = location-Vector2(measured.x*0.5,0.0)
		draw_string(BOLD,at+Vector2(1,2),label,HORIZONTAL_ALIGNMENT_LEFT,-1,points,
			Color(0.02,0.07,0.17,0.7*life_fraction))
		draw_string(BOLD,at,label,HORIZONTAL_ALIGNMENT_LEFT,-1,points,
			Color(1.0,0.84,0.43,life_fraction))
		if int(item.combo) > 1:
			var combo_text: String = "×%d" % int(item.combo)
			var combo_width: float = BOLD.get_string_size(combo_text,HORIZONTAL_ALIGNMENT_LEFT,-1,22).x
			draw_string(BOLD,location+Vector2(-combo_width*0.5,27.0),
				combo_text,HORIZONTAL_ALIGNMENT_LEFT,-1,22,
				Color(0.63,0.96,1.0,life_fraction))

func _draw_pieces() -> void:
	_text("%s  %d" % [t("move"),moves+1],Vector2(41,952),18,Color("#b8caec"))
	if not pending_group.is_empty():
		var amount: int = int(pending_group["count"])
		var tint: Color = COLORS[int(pending_group["color"])]
		draw_circle(Vector2(282,947),10.0,tint)
		var value: int = Rules.group_points(amount)
		var next_value: int = Rules.group_points(maxi(Rules.POP_THRESHOLD,amount+1))
		var status: String = ""
		if amount < Rules.POP_THRESHOLD:
			status = "%d/%d  →  +%d" % [amount,Rules.POP_THRESHOLD,Rules.group_points(Rules.POP_THRESHOLD)]
		else:
			status = "%d  +%d    %d  +%d" % [amount,value,amount+1,next_value]
		_text(t("charge")+" "+status,Vector2(301,953),16,Color("#ffe39b"))
	var stack_height: int = Rules.tallest_column(board)
	var warning_color: Color = Color("#ff7b9c") if stack_height >= 6 else Color("#abb9d5")
	_text("%s %d/8" % [t("danger"),stack_height],Vector2(43,979),17,warning_color)
	if stack_height >= 6:
		_text(t("danger_soon"),Vector2(240,979),17,Color("#ff899f"))
	_text(t("next"),Vector2(43,1004),16,Color("#9fb7dc"))
	for i in range(3):
		var rect: Rect2 = Rect2(45+i*216,1017,200,87)
		_box(rect,Color("#344d7e") if i==0 else Color("#1a2d50"),18,
			Color("#80f1d9") if i==0 else Color("#3b5177"),2)
		if i>=pieces.size():
			continue
		var piece: Array = pieces[i]
		var min_x: int = 0
		var max_x: int = 0
		var min_y: int = 0
		var max_y: int = 0
		for b in piece:
			max_x = maxi(max_x,int(b[0]))
			max_y = maxi(max_y,int(b[1]))
		# Keep even the tallest 4-ball towers inside the preview tile.
		var step: float = minf(32.0,minf(55.0/float(maxi(1,max_y)),135.0/float(maxi(1,max_x))))
		var radius: float = minf(15.0,step*0.47)
		var left: float = rect.get_center().x-float(max_x-min_x)*step*0.5
		var top: float = rect.get_center().y-float(max_y-min_y)*step*0.5
		for b in piece:
			_ball(Vector2(left+b[0]*step,top+b[1]*step),radius,int(b[2]))

func _draw_buttons() -> void:
	var enabled: bool = phase == "drop"
	for entry in [
		{"rect":LEFT_RECT,"label":"↶  "+t("left"),"enabled":enabled},
		{"rect":RIGHT_RECT,"label":t("right")+"  ↷","enabled":enabled}
	]:
		var rect: Rect2 = entry.rect
		_box(rect,Color("#ffcd6f") if entry.enabled else Color("#25365e"),
			23,Color("#ffe6ae") if entry.enabled else Color("#354e7a"),2)
		var projected: int = int(preview_left.get("score",0)) if rect == LEFT_RECT else int(preview_right.get("score",0))
		_center(entry.label,rect.get_center().x,rect.get_center().y-3,23,
			Color("#272446") if entry.enabled else Color("#778baa"))
		var payoff: String = "+%d" % projected if projected > 0 else "—"
		_center(payoff,rect.get_center().x,rect.get_center().y+29,19,
			Color("#4e3850") if projected > 0 else Color("#957b55"))
	_center(t("rotate_controls"),360,1115,18,Color("#a9c6ec"))
	_center(t("ready"),360,1251,17,Color("#a9c6ec"))

func _draw_game_over() -> void:
	draw_rect(Rect2(0,0,720,1280),Color(0.02,0.04,0.12,0.82))
	_box(Rect2(69,410,582,548),Color("#21365f"),28,Color("#6581b3"),2)
	_center(t("over"),360,520,45,Color.WHITE)
	_center(str(score),360,623,65,Color("#ffda7e"))
	_center("%s  %d" % [t("best"),best],360,675,20,Color("#c6d7f2"))
	_box(RESTART_RECT,Color("#ffce70"),22)
	_center(t("again"),360,774,27,Color("#2a2540"))
	_box(RESCUE_RECT,Color("#334e7e"),22)
	_center(t("rescue"),360,870,25,Color.WHITE)
	_center("DEMO • NO ADS",360,923,16,Color("#93afd5"))
