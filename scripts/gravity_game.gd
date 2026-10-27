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
	"pl":{"score":"WYNIK","best":"REKORD","move":"RUCH","drop":"DOTKNIJ KOLUMNY","turn":"OBRÓĆ PLANSZĘ LUB GRAJ DALEJ","left":"W LEWO","right":"W PRAWO","skip":"DALEJ","next":"NASTĘPNE","ready":"3 TEGO SAMEGO KOLORU = POP!","over":"KONIEC RUNDY","again":"ZAGRAJ PONOWNIE","rescue":"TEST: +1 ŻYCIE","lost":"STRATA ŻYCIA","hint":"Wybierz kolumnę dla spadającego kształtu"},
	"en":{"score":"SCORE","best":"BEST","move":"MOVE","drop":"TAP A COLUMN","turn":"ROTATE OR KEEP GOING","left":"LEFT","right":"RIGHT","skip":"NEXT","next":"UP NEXT","ready":"3 SAME-COLOUR BALLS = POP!","over":"GAME OVER","again":"PLAY AGAIN","rescue":"TEST: +1 LIFE","lost":"LIFE LOST","hint":"Choose a column for the falling piece"},
	"es":{"score":"PUNTOS","best":"RÉCORD","move":"JUGADA","drop":"TOCA UNA COLUMNA","turn":"GIRA O CONTINÚA","left":"IZQUIERDA","right":"DERECHA","skip":"SEGUIR","next":"SIGUIENTES","ready":"3 BOLAS DEL MISMO COLOR = POP!","over":"FIN DEL JUEGO","again":"JUGAR OTRA VEZ","rescue":"PRUEBA: +1 VIDA","lost":"VIDA PERDIDA","hint":"Elige una columna para las bolas"},
	"pt":{"score":"PONTOS","best":"RECORDE","move":"JOGADA","drop":"TOQUE NA COLUNA","turn":"GIRE OU CONTINUE","left":"ESQUERDA","right":"DIREITA","skip":"SEGUIR","next":"PRÓXIMAS","ready":"3 BOLAS DA MESMA COR = POP!","over":"FIM DE JOGO","again":"JOGAR DE NOVO","rescue":"TESTE: +1 VIDA","lost":"VIDA PERDIDA","hint":"Escolha uma coluna para jogar"},
	"de":{"score":"PUNKTE","best":"REKORD","move":"ZUG","drop":"SPALTE ANTIPPEN","turn":"DREHEN ODER WEITER","left":"LINKS","right":"RECHTS","skip":"WEITER","next":"ALS NÄCHSTES","ready":"3 GLEICHE FARBEN = POP!","over":"SPIEL VORBEI","again":"NOCHMAL SPIELEN","rescue":"TEST: +1 LEBEN","lost":"LEBEN VERLOREN","hint":"Wähle eine Spalte zum Einwerfen"},
	"fr":{"score":"SCORE","best":"RECORD","move":"COUP","drop":"TOUCHE UNE COLONNE","turn":"TOURNE OU CONTINUE","left":"GAUCHE","right":"DROITE","skip":"SUITE","next":"À SUIVRE","ready":"3 BILLES IDENTIQUES = POP!","over":"PARTIE FINIE","again":"REJOUER","rescue":"TEST : +1 VIE","lost":"VIE PERDUE","hint":"Choisis une colonne pour les billes"},
	"ru":{"score":"ОЧКИ","best":"РЕКОРД","move":"ХОД","drop":"ВЫБЕРИ СТОЛБЕЦ","turn":"ПОВЕРНИ ИЛИ ПРОДОЛЖИ","left":"ВЛЕВО","right":"ВПРАВО","skip":"ДАЛЕЕ","next":"СЛЕДУЮЩИЕ","ready":"3 ОДНОГО ЦВЕТА = POP!","over":"ИГРА ОКОНЧЕНА","again":"ИГРАТЬ СНОВА","rescue":"ТЕСТ: +1 ЖИЗНЬ","lost":"МИНУС ЖИЗНЬ","hint":"Выбери столбец для шариков"}
}
const LEFT_RECT := Rect2(34,1123,204,92)
const SKIP_RECT := Rect2(258,1123,204,92)
const RIGHT_RECT := Rect2(482,1123,204,92)
const RESTART_RECT := Rect2(104,722,512,84)
const RESCUE_RECT := Rect2(104,821,512,79)

var board: Array = []
var pieces: Array = []
var rng := RandomNumberGenerator.new()
var language: String = "en"
var phase: String = "drop" # drop, rotate, anim, over
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
var animating: bool = false
var flash: Array = []
var fx: Array = []
var praise: String = ""
var praise_timer: float = 0.0
var hint_timer: float = 0.0
var style_cache: Dictionary = {}

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
	# Pairs already on the board make a deliberate first POP possible.
	for bead in [[1,7,0],[2,7,0],[5,7,1],[6,7,1],[3,6,2],[4,6,2]]:
		board[bead[1]][bead[0]] = bead[2]
	score = 0
	moves = 0
	lives = 3
	revives = 0
	chain_depth = 0
	pieces = []
	motion.clear()
	flash.clear()
	fx.clear()
	praise = ""
	animating = false
	phase = "drop"
	for i in range(3):
		pieces.append(Rules.next_piece(rng,board))
	queue_redraw()

func _process(delta: float) -> void:
	if animating:
		motion_time = minf(motion_duration,motion_time+delta)
	praise_timer = maxf(0.0,praise_timer-delta)
	hint_timer = maxf(0.0,hint_timer-delta)
	for i in range(fx.size()-1,-1,-1):
		var particle: Dictionary = fx[i]
		particle.p += particle.v * delta
		particle.v *= maxf(0.0,1.0-2.7*delta)
		particle.life -= delta
		fx[i] = particle
		if particle.life <= 0.0:
			fx.remove_at(i)
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
	if Rect2(576,53,100,53).has_point(pt) and phase != "anim":
		var index: int = LOCALES.find(language)
		language = LOCALES[(index+1)%LOCALES.size()]
		_save()
		queue_redraw()
		return
	if phase == "over":
		if RESTART_RECT.has_point(pt):
			new_game()
		elif RESCUE_RECT.has_point(pt):
			revives += 1 # Explicit test reward, NOT an ad callback.
			lives = 1
			board = Rules.rescue(board)
			pieces[0] = Rules.next_piece(rng,board)
			phase = "drop"
			_praise("+1 ♥",Color("#ff9bb7"),1.2)
			queue_redraw()
		return
	if phase == "drop" and BOARD.has_point(pt):
		var col: int = int((pt.x-BOARD.position.x)/CELL)
		_play_drop(col)
	elif phase == "rotate":
		if LEFT_RECT.has_point(pt):
			_rotate_board(false)
		elif RIGHT_RECT.has_point(pt):
			_rotate_board(true)
		elif SKIP_RECT.has_point(pt):
			_finish_turn()

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
	await _animate_to(result.board,result.motions,0.40,"fall")
	await _resolve_cascades()
	phase = "rotate"
	queue_redraw()

func _rotate_board(clockwise: bool) -> void:
	if phase != "rotate":
		return
	phase = "anim"
	var turned: Dictionary = Rules.rotate(board,clockwise)
	await _animate_to(turned.board,turned.motions,0.43,"spin")
	var gravity: Dictionary = Rules.settle(board)
	await _animate_to(gravity.board,gravity.motions,0.42,"fall")
	await _resolve_cascades()
	_finish_turn()

func _finish_turn() -> void:
	if phase == "anim":
		return
	pieces.pop_front()
	pieces.append(Rules.next_piece(rng,board))
	phase = "drop"
	if not Rules.any_drop(board,pieces[0]):
		lives -= 1
		_praise(t("lost"),Color("#ff8ca4"),1.2)
		if lives <= 0:
			phase = "over"
		else:
			board = Rules.rescue(board)
			pieces[0] = Rules.next_piece(rng,board)
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
	queue_redraw()

func _resolve_cascades() -> void:
	for depth in range(20):
		var hits: Array = Rules.find_matches(board)
		if hits.is_empty():
			return
		chain_depth += 1
		flash = hits
		if chain_depth >= 3:
			_praise("AMAZING!",Color("#ffe58c"),1.35)
		elif chain_depth >= 2 or hits.size() >= 6:
			_praise("GREAT!",Color("#92f2e2"),1.0)
		else:
			_praise("POP!",Color("#ffffff"),0.72)
		await get_tree().create_timer(0.17).timeout
		for pt in hits:
			_burst(pt,4)
		board = Rules.erase_matches(board,hits)
		score += hits.size() * 35 * chain_depth
		best = maxi(best,score)
		_save()
		flash.clear()
		queue_redraw()
		await get_tree().create_timer(0.14).timeout
		var gravity: Dictionary = Rules.settle(board)
		await _animate_to(gravity.board,gravity.motions,0.29,"fall")

func _burst(cell: Vector2i, count: int) -> void:
	var center: Vector2 = BOARD.position+(Vector2(cell)+Vector2(0.5,0.5))*CELL
	for i in range(count):
		var angle: float = rng.randf_range(0.0,TAU)
		var speed: float = rng.randf_range(90.0,250.0)
		fx.append({"p":center,"v":Vector2.from_angle(angle)*speed,
			"life":0.70,"max":0.70,"color":COLORS[rng.randi_range(0,2)],"r":rng.randf_range(3.0,8.0)})

func _praise(value: String, color: Color, length: float) -> void:
	praise = value
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
	draw_circle(center+Vector2(0,5),radius+3,Color(0,0,0,0.22*alpha))
	draw_circle(center,radius,c.darkened(0.22))
	draw_circle(center-Vector2(0,2),radius-3,c)
	draw_circle(center+Vector2(-radius*0.30,-radius*0.36),radius*0.28,Color(1,1,1,0.35*alpha))

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("#0a1026"))
	draw_set_transform(_offset(),0,Vector2.ONE*_scale())
	draw_rect(Rect2(0,0,720,1280),Color("#111d3c"))
	draw_circle(Vector2(145,280),330,Color("#51327b",0.22))
	draw_circle(Vector2(575,940),280,Color("#255f80",0.18))
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
	_text(str(score),Vector2(58,243),39,Color.WHITE)
	_text(t("best"),Vector2(392,198),16,Color("#9cb6de"))
	_text(str(best),Vector2(392,243),39,Color("#ffe08e"))
	for i in range(3):
		_text("♥",Vector2(574+i*32,196),26,Color("#ff7396") if i<lives else Color("#536083"))
	_draw_board()
	_draw_pieces()
	_draw_buttons()
	for p in fx:
		var a: float = clampf(float(p.life)/float(p.max),0.0,1.0)
		draw_circle(p.p,p.r,Color(p.color.r,p.color.g,p.color.b,a))
	if praise_timer > 0 and phase != "over":
		_box(Rect2(161,516,398,103),Color("#101d3b",0.88),26)
		_center(praise,360,588,42,Color("#ffe49c"))
	if phase == "over":
		_draw_game_over()
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

func _draw_board() -> void:
	_box(Rect2(29,259,662,662),Color("#273a68"),27,Color("#536894"),2)
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
			if board[y][x] != Rules.EMPTY and not hidden.has(y*8+x):
				_ball(cell+Vector2(CELL*0.5,CELL*0.5),CELL*0.36,board[y][x])
			if Vector2i(x,y) in flash:
				draw_circle(cell+Vector2(CELL*0.5,CELL*0.5),CELL*0.40,Color(1,1,1,0.32))
	if animating:
		var factor: float = clampf(motion_time/motion_duration,0.0,1.0)
		factor = factor*factor*(3.0-2.0*factor) if motion_kind=="spin" else 1.0-pow(1.0-factor,3.0)
		for m in motion:
			var from: Vector2 = m["from"]
			var dest: Vector2 = m["to"]
			var at: Vector2 = from.lerp(dest,factor)
			_ball(BOARD.position+(at+Vector2(0.5,0.5))*CELL,
				CELL*0.36,int(m["color"]))
	elif phase=="drop" and hover_column>=0 and not pieces.is_empty():
		var preview: Dictionary = Rules.drop(board,pieces[0],hover_column)
		if preview.get("valid",false):
			for m in preview.motions:
				var pos: Vector2 = m["to"]
				_ball(BOARD.position+(pos+Vector2(0.5,0.5))*CELL,CELL*0.33,int(m["color"]),0.50)
	# Tutorial: column and objective are always obvious without a manual.
	if phase=="drop":
		_center(t("drop"),360,302,15,Color("#def9ee"))
	elif phase=="rotate":
		_center(t("turn"),360,302,15,Color("#ffe191"))

func _draw_pieces() -> void:
	_text("%s  %d" % [t("move"),moves+1],Vector2(41,952),18,Color("#b8caec"))
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
		var step: float = 30.0
		var left: float = rect.get_center().x-float(max_x-min_x)*step*0.5
		var top: float = rect.get_center().y-float(max_y-min_y)*step*0.5
		for b in piece:
			_ball(Vector2(left+b[0]*step,top+b[1]*step),15.5,int(b[2]))

func _draw_buttons() -> void:
	var enabled: bool = phase == "rotate"
	for entry in [
		{"rect":LEFT_RECT,"label":"↶  "+t("left"),"enabled":enabled},
		{"rect":SKIP_RECT,"label":t("skip"),"enabled":enabled},
		{"rect":RIGHT_RECT,"label":t("right")+"  ↷","enabled":enabled}
	]:
		var rect: Rect2 = entry.rect
		_box(rect,Color("#ffcd6f") if entry.enabled else Color("#25365e"),
			23,Color("#ffe6ae") if entry.enabled else Color("#354e7a"),2)
		_center(entry.label,rect.get_center().x,rect.get_center().y+8,20,
			Color("#272446") if entry.enabled else Color("#778baa"))
	_center(t("ready"),360,1251,18,Color("#a9c6ec"))

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
