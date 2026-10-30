extends Control
## POP DROP Gravity / isolated gameplay experiment. NO real ads in this scene.
const Rules = preload("res://scripts/gravity_rules.gd")
const Session = preload("res://scripts/gravity_session.gd")
const Telemetry = preload("res://scripts/gravity_telemetry.gd")
const Ads = preload("res://scripts/gravity_ads.gd")
const Progression = preload("res://scripts/gravity_progression.gd")
const Feedback = preload("res://scripts/gravity_feedback.gd")
const Shop = preload("res://scripts/gravity_shop.gd")
const BACKDROP = preload("res://assets/ui/arcade_backdrop.svg")
const ICON_COIN = preload("res://assets/ui/icons/coin.svg")
const ICON_SHOP = preload("res://assets/ui/icons/shop.svg")
const ICON_PROFILE = preload("res://assets/ui/icons/profile.svg")
const ICON_SETTINGS = preload("res://assets/ui/icons/settings.svg")
const ICON_ROTATE_LEFT = preload("res://assets/ui/icons/rotate_left.svg")
const ICON_ROTATE_RIGHT = preload("res://assets/ui/icons/rotate_right.svg")
const ICON_BOMB = preload("res://assets/ui/icons/bomb.svg")
const ICON_MAGIC = preload("res://assets/ui/icons/magic.svg")
const ICON_REROLL = preload("res://assets/ui/icons/reroll.svg")
const ICON_HEART = preload("res://assets/ui/icons/heart.svg")
const ICON_GLOBE = preload("res://assets/ui/icons/globe.svg")
const FONT = preload("res://fonts/ClearSans-Regular.ttf")
const BOLD = preload("res://fonts/ClearSans-Bold.ttf")
# Artist-authored vector sprites imported as textures by Godot (no more circle stacks).
const MARBLE_TEXTURES = [
	preload("res://assets/marbles/coral.svg"),
	preload("res://assets/marbles/mint.svg"),
	preload("res://assets/marbles/blue.svg")
]
const BASE := Vector2(720,1280)
# 720x1280 reference layout. Visuals AND hit-testing share these rectangles.
# HUD 0..224 / board 247..855 / status 874..918 / cards 952..1054
# / rotation 1086..1172 / boosts 1193..1261.
const BOARD := Rect2(56,247,608,608)
const CELL := 76.0
const HUD_SCORE := Rect2(23,133,228,90)
const HUD_WAVE := Rect2(263,133,281,90)
const HUD_LIVES := Rect2(556,133,141,90)
const COINS_OPEN := Rect2(296,37,129,55)
const SHOP_OPEN := Rect2(434,37,54,55)
const PROFILE_OPEN := Rect2(500,37,55,55)
const SETTINGS_OPEN := Rect2(565,37,55,55)
const LANG_RECT := Rect2(630,37,58,55)
const DOCK_STATUS := Rect2(27,874,666,44)
const DOCK_SHAPES := Rect2(20,925,680,138)
const DOCK_ACTIONS := Rect2(20,1078,680,188)
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
const LEFT_RECT := Rect2(29,1086,317,86)
const RIGHT_RECT := Rect2(374,1086,317,86)
const RESTART_RECT := Rect2(104,722,512,84)
const RESCUE_RECT := Rect2(104,821,244,79)
const COIN_RESCUE_RECT := Rect2(372,821,244,79)
const ENERGY_AD_RECT := Rect2(221,908,278,54)
const SETTINGS_CLOSE := Rect2(476,384,118,54)
const SETTINGS_TOGGLE := Rect2(120,550,480,80)
const SETTINGS_ERASE := Rect2(120,654,480,74)
const SETTINGS_AD_PRIVACY := Rect2(120,748,480,68)
const SETTINGS_SOUND := Rect2(114,886,492,67)
const SETTINGS_HAPTICS := Rect2(114,975,492,67)
const PROFILE_CLOSE := Rect2(512,265,120,54)
const PROFILE_CARD := Rect2(54,224,612,906)
const SHOP_CLOSE := Rect2(514,266,120,54)
const SHOP_TAB_BOOST := Rect2(94,410,251,57)
const SHOP_TAB_SKINS := Rect2(375,410,251,57)
const BOOST_BOMB := Rect2(27,1192,211,66)
const BOOST_MAGIC := Rect2(254,1192,211,66)
const BOOST_REROLL := Rect2(481,1192,211,66)
const SHOP_PREV := Rect2(105,970,113,55)
const SHOP_NEXT := Rect2(502,970,113,55)
const PROFILE_DAILY_TAB := Rect2(92,526,248,51)
const PROFILE_BADGE_TAB := Rect2(380,526,248,51)
const PROFILE_PREV := Rect2(104,911,116,46)
const PROFILE_NEXT := Rect2(500,911,116,46)
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
var shop = null
var shop_open: bool = false
var shop_tab: int = 0
var shop_page: int = 0
var profile_tab: int = 0
var badge_page: int = 0
var preview_skin: String = ""
var magic_aim: bool = false
var ad_reward_kind: String = ""
var bomb_aim: bool = false
var bomb_hover: Vector2i = Vector2i(-1,-1)
var shop_notice: String = ""
var shop_notice_time: float = 0.0
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
# The first wave hits quickly; intervals become longer as the board fills.
var wave_number: int = 0
var wave_time_left: float = 15.0
var wave_queued: bool = false

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
	progression.achievement_unlocked.connect(_on_achievement_unlocked)
	shop = Shop.new()
	shop.load_data()
	# Recover a badge payout if the app was interrupted between separate save files.
	for achievement in Progression.ACHIEVEMENTS:
		var badge_id: String = str(achievement["id"])
		if bool(progression.unlocked_achievements.get(badge_id,false)):
			shop.credit_bonus("badge:"+badge_id,int(achievement["coins"]))
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

const SHOP_PL := {
	"shop":"SKLEP","boosts":"MOCE","skins":"SKÓRKI","close":"ZAMKNIJ",
	"coins":"MONETY","bomb":"BOMBA","magic":"MAGICZNY KOLOR","reroll":"NOWY ZESTAW",
	"neon":"NEON","gold":"ZŁOTO","donut":"DONUTY","capybara":"KAPIBARY",
	"crystal":"KRYSZTAŁY","cosmos":"KOSMOS","star_capybara":"GWIEZDNA KAPIBARA",
	"buy":"KUP","owned":"KUPIONE","active":"AKTYWNE","equip":"WYBIERZ","stock":"POSIADASZ",
	"poor":"ZA MAŁO MONET","bought":"ZAKUPIONE!","full":"LIMIT ZAPASU",
	"aim":"DOTKNIJ POLA — BOMBA 3×3","magic_aim":"DOTKNIJ KULKI — ZMIANA KOLORU",
	"tip":"Monety i wynik gry są niezależne","energy":"ENERGIA",
	"bomb_desc":"Usuwa kulki w polu 3×3","magic_desc":"Zmienia kolor wybranej kulki",
	"reroll_desc":"Losuje trzy nowe kształty",
	"neon_desc":"Elektryczna poświata","gold_desc":"Złota oprawa",
	"donut_desc":"Słodkie lukrowane kulki","capybara_desc":"Kapibary na planszy",
	"crystal_desc":"Błyszczące kryształy","cosmos_desc":"Kosmiczne kulki",
	"page":"STRONA","no_energy":"BRAK ENERGII","badges":"ODZNAKI"
}
const SHOP_EN := {
	"shop":"SHOP","boosts":"POWERS","skins":"SKINS","close":"CLOSE",
	"coins":"COINS","bomb":"BOMB","magic":"MAGIC COLOR","reroll":"NEW SET",
	"neon":"NEON","gold":"GOLD","donut":"DONUTS","capybara":"CAPYBARAS",
	"crystal":"CRYSTALS","cosmos":"COSMOS","star_capybara":"STAR CAPYBARA",
	"buy":"BUY","owned":"OWNED","active":"ACTIVE","equip":"EQUIP","stock":"OWNED",
	"poor":"NOT ENOUGH COINS","bought":"PURCHASED!","full":"INVENTORY FULL",
	"aim":"TAP CELL — BOMB 3×3","magic_aim":"TAP A MARBLE TO RECOLOR",
	"tip":"Coins never affect your score","energy":"ENERGY",
	"bomb_desc":"Clear a 3×3 region","magic_desc":"Recolor a chosen marble",
	"reroll_desc":"Roll three fresh shapes",
	"neon_desc":"Electric glowing edges","gold_desc":"Gold outline",
	"donut_desc":"Sweet glazed marbles","capybara_desc":"Capybaras on the board",
	"crystal_desc":"Shimmering crystals","cosmos_desc":"Cosmic marbles",
	"page":"PAGE","no_energy":"NO ENERGY","badges":"BADGES"
}

func shop_t(key: String) -> String:
	return str((SHOP_PL if language=="pl" else SHOP_EN).get(key,key))

func _shop_card(index: int) -> Rect2:
	return Rect2(91,498+index*231,538,213)

func _shop_catalog() -> Array:
	return ["bomb","magic","reroll"] if shop_tab==0 else [
		"neon","gold","donut","capybara","crystal","cosmos","star_capybara"]

func _shop_pages() -> int:
	return int(ceil(float(_shop_catalog().size())/2.0))

func _shop_items() -> Array:
	var items: Array = _shop_catalog()
	var first: int = shop_page*2
	return items.slice(first,mini(first+2,items.size()))

func _shop_activate(id: String) -> void:
	var offer: Dictionary = Shop.item(id)
	if id == Shop.SPECIAL_SKIN:
		if shop.owns_skin(id):
			shop.equip_skin(id)
			shop_notice = shop_t("active")
		else:
			shop_notice = "7 DNI GRY" if language=="pl" else "PLAY 7 DAYS"
		shop_notice_time = 2.0
		queue_redraw()
		return
	if offer.is_empty():
		return
	if str(offer.get("kind",""))=="skin" and shop.owns_skin(id):
		shop.equip_skin(id)
		shop_notice = shop_t("active")
		telemetry.track("shop_skin_equip",{"skin":id})
	elif shop.purchase(id):
		if str(offer["kind"])=="skin":
			shop.equip_skin(id)
		shop_notice = shop_t("bought")
		if feedback != null:
			feedback.cue("mission")
		telemetry.track("shop_purchase",{"item":id,"price_coins":int(offer["price"])})
	else:
		shop_notice = shop_t("poor") if shop.coins < int(offer["price"]) else shop_t("full")
	shop_notice_time = 2.0
	queue_redraw()

func _use_reroll() -> void:
	if phase != "drop":
		return
	if not shop.use_boost("reroll"):
		shop_open = true
		shop_tab = 0
		shop_page = 1
		return
	for i in range(3):
		pieces[i] = Rules.next_piece(rng,board,recent_shapes)
		_remember_shape(pieces[i])
	selected_piece = 0
	_refresh_targets()
	_praise(shop_t("reroll"),Color("#91dbff"),1.2)
	telemetry.track("powerup_used",{"run_id":run_id,"item":"reroll"})
	_check_stuck()
	if phase == "over":
		_on_game_over()
	_save_progress()
	queue_redraw()

func _use_magic(target: Vector2i) -> void:
	if phase != "drop" or not magic_aim:
		return
	if target.x < 0 or target.y < 0 or target.x >= 8 or target.y >= 8:
		return
	var previous: int = int(board[target.y][target.x])
	if previous < 0 or previous > 2:
		shop_notice = shop_t("magic_aim")
		shop_notice_time = 1.4
		return
	var best_color: int = (previous+1)%3
	var best_value: int = -1
	for color in range(3):
		if color == previous:
			continue
		var candidate: Array = Rules.copy_board(board)
		candidate[target.y][target.x] = color
		var power: int = 0
		for group in Rules.find_groups(candidate):
			for cell in group["cells"]:
				if cell == target:
					power = maxi(power,int(group["count"])*10)
					break
		for direction in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var pos: Vector2i = target+direction
			if pos.x >= 0 and pos.x < 8 and pos.y >= 0 and pos.y < 8:
				if int(candidate[pos.y][pos.x]) == color:
					power += 1
		if power > best_value:
			best_value = power
			best_color = color
	if not shop.use_boost("magic"):
		magic_aim = false
		shop_open = true
		shop_tab = 0
		shop_page = 0
		return
	magic_aim = false
	action_serial += 1
	action_id = "action:%s:%d" % [run_id,action_serial]
	board[target.y][target.x] = best_color
	_burst(target,12)
	_shock(BOARD.position+(Vector2(target)+Vector2(0.5,0.5))*CELL,2.3,Color("#c9a0ff"))
	_praise(shop_t("magic"),Color("#e1b9ff"),1.3)
	telemetry.track("powerup_used",{"run_id":run_id,"item":"magic"})
	phase = "anim"
	chain_depth = 0
	await _resolve_cascades()
	phase = "drop"
	_check_ceiling()
	if phase == "drop":
		_refresh_targets()
		_check_stuck()
	if phase == "over":
		_on_game_over()
	_save_progress()
	queue_redraw()


func _use_bomb(target: Vector2i) -> void:
	if phase!="drop" or not bomb_aim:
		return
	var blast: Dictionary = Rules.explode(board,target)
	if not bool(blast.get("valid",false)):
		shop_notice = shop_t("aim")
		shop_notice_time = 1.1
		return
	if not shop.use_boost("bomb"):
		bomb_aim = false
		shop_open = true
		shop_tab = 0
		return
	bomb_aim = false
	magic_aim = false
	bomb_hover = Vector2i(-1,-1)
	phase = "anim"
	action_serial += 1
	action_id = "action:%s:%d" % [run_id,action_serial]
	board = Rules.copy_board(blast.board)
	for y in range(maxi(0,target.y-1),mini(8,target.y+2)):
		for x in range(maxi(0,target.x-1),mini(8,target.x+2)):
			_burst(Vector2i(x,y),6)
	_shock(BOARD.position+(Vector2(target)+Vector2(0.5,0.5))*CELL,3.7,Color("#ffc089"))
	if feedback != null:
		feedback.cue("cascade")
	telemetry.track("powerup_used",{"run_id":run_id,"item":"bomb",
		"removed":int(blast["removed"]),"rocks_hit":int(blast["rocks_hit"])})
	var fallen: Dictionary = Rules.settle(board)
	await _animate_to(fallen.board,fallen.motions,0.23,"fall")
	chain_depth = 0
	await _resolve_cascades()
	phase = "drop"
	_check_ceiling()
	if phase == "drop":
		_refresh_targets()
		_check_stuck()
	if phase == "over":
		_on_game_over()
	_save_progress()
	queue_redraw()


func _on_achievement_unlocked(id: String, reward_coins: int) -> void:
	var gained: int = shop.credit_bonus("badge:"+id,reward_coins)
	if gained <= 0:
		return
	mission_notice = "★ %s  +%d ◉" % [id.replace("_"," ").to_upper(),gained]
	mission_notice_time = 3.5
	glow = 1.0
	if feedback != null:
		feedback.cue("level")
	telemetry.track("achievement_unlocked",{"badge":id,"coins":gained})

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
	if not shop.spend_energy():
		if board.is_empty():
			board = Rules.empty_board()
			pieces = []
			score = 0
			display_score = 0.0
			lives = 0
		phase = "over"
		ad_note = shop_t("no_energy")
		queue_redraw()
		return
	run_id = Crypto.new().generate_random_bytes(8).hex_encode()
	best_at_round_start = best
	game_over_reported = false
	action_serial = 0
	action_id = ""
	mission_notice = ""
	mission_notice_time = 0.0
	shop_notice = ""
	shop_notice_time = 0.0
	shop_open = false
	bomb_aim = false
	bomb_hover = Vector2i(-1,-1)
	level_fx_time = 0.0
	wave_number = 0
	wave_time_left = Rules.wave_interval(0)
	wave_queued = false
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
		"action_serial": action_serial,
		"wave_number":wave_number,
		"wave_time_left":wave_time_left
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
	wave_number = maxi(0,int(data.get("wave_number",0)))
	wave_time_left = clampf(float(data.get("wave_time_left",Rules.wave_interval(wave_number))),0.0,45.0)
	wave_queued = false
	bomb_aim = false
	magic_aim = false
	shop_open = false
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

func _revive() -> bool:
	if phase != "over" or revives >= 1 or pieces.is_empty():
		return false
	revives += 1
	lives = 1
	board = Rules.rescue(board)
	pieces[0] = Rules.next_piece(rng,board,recent_shapes)
	_remember_shape(pieces[0])
	selected_piece = 0
	phase = "drop"
	ad_note = ""
	wave_time_left = Rules.wave_interval(wave_number)
	_refresh_targets()
	_praise("+1 ♥",Color("#ff9bb7"),1.2)
	_save_progress()
	queue_redraw()
	return true

func _request_ad_reward(kind: String) -> void:
	if not ads.request_rewarded():
		ad_reward_kind = ""
		ad_note = "REKLAMA NIEDOSTĘPNA" if language=="pl" else "AD NOT AVAILABLE"
	else:
		ad_reward_kind = kind
		ad_note = "ŁADOWANIE REKLAMY..." if language=="pl" else "LOADING AD..."
	queue_redraw()

func _on_ad_reward(_transaction: int) -> void:
	# Reward is issued only by the real SDK's validated completion callback.
	var kind: String = ad_reward_kind
	ad_reward_kind = ""
	if kind == "energy":
		if shop.reward_energy():
			ad_note = "+1 "+shop_t("energy")
			telemetry.track("ad_reward_earned",{"reward":"energy"})
		return
	if kind == "revive" and _revive():
		telemetry.track("ad_reward_earned",{"run_id":run_id,"reward":"revive"})


func _process(delta: float) -> void:
	clock += delta
	if shop != null and int(clock) % 2 == 0:
		shop.refresh_energy()
	mission_notice_time = maxf(0.0,mission_notice_time-delta)
	shop_notice_time = maxf(0.0,shop_notice_time-delta)
	level_fx_time = maxf(0.0,level_fx_time-delta)
	tap_time = maxf(0.0,tap_time-delta)
	# No countdown during interactions, modal screens, or animated cascades.
	if phase == "drop" and not settings_open and not profile_open and not shop_open and not wave_queued:
		wave_time_left = maxf(0.0,wave_time_left-minf(delta,0.15))
		if wave_time_left <= 0.0:
			wave_queued = true
			call_deferred("_trigger_pressure_wave")
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
		if bomb_aim or magic_aim:
			bomb_hover = _board_cell(pointer)
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
	if shop_open:
		if SHOP_CLOSE.has_point(pt):
			shop_open = false
		elif SHOP_TAB_BOOST.has_point(pt):
			shop_tab = 0
			shop_page = 0
		elif SHOP_TAB_SKINS.has_point(pt):
			shop_tab = 1
			shop_page = 0
		elif SHOP_PREV.has_point(pt):
			shop_page = maxi(0,shop_page-1)
		elif SHOP_NEXT.has_point(pt):
			shop_page = mini(_shop_pages()-1,shop_page+1)
		else:
			var shown: Array = _shop_items()
			for i in range(shown.size()):
				if _shop_card(i).has_point(pt):
					_shop_activate(str(shown[i]))
		queue_redraw()
		return
	if profile_open:
		if PROFILE_CLOSE.has_point(pt):
			profile_open = false
		elif PROFILE_DAILY_TAB.has_point(pt):
			profile_tab = 0
		elif PROFILE_BADGE_TAB.has_point(pt):
			profile_tab = 1
		elif profile_tab==1 and PROFILE_PREV.has_point(pt):
			badge_page = maxi(0,badge_page-1)
		elif profile_tab==1 and PROFILE_NEXT.has_point(pt):
			badge_page = mini(1,badge_page+1)
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
	if (SHOP_OPEN.has_point(pt) or COINS_OPEN.has_point(pt)) and phase != "anim":
		shop_open = true
		shop_tab = 0
		shop_page = 0
		bomb_aim = false
		magic_aim = false
		telemetry.track("shop_open",{"coins":shop.coins})
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
			_request_ad_reward("revive")
		elif COIN_RESCUE_RECT.has_point(pt) and revives < 1:
			if shop.coins >= Shop.RESCUE_PRICE and not pieces.is_empty():
				if shop.spend_coins(Shop.RESCUE_PRICE):
					_revive()
					telemetry.track("coin_revive",{"run_id":run_id,"cost":Shop.RESCUE_PRICE})
			else:
				ad_note = shop_t("poor")
			queue_redraw()
		elif ENERGY_AD_RECT.has_point(pt) and shop.energy < Shop.MAX_ENERGY:
			_request_ad_reward("energy")
		return
	if LANG_RECT.has_point(pt):
		var index: int = LOCALES.find(language)
		language = LOCALES[(index+1)%LOCALES.size()]
		_save()
		queue_redraw()
		return
	if phase!="drop":
		return
	if BOOST_BOMB.has_point(pt):
		magic_aim = false
		if bomb_aim:
			bomb_aim = false
		elif shop.stock("bomb")>0:
			bomb_aim = true
			bomb_hover = Vector2i(-1,-1)
		else:
			shop_open = true
			shop_tab = 0
			shop_page = 0
		queue_redraw()
		return
	if BOOST_MAGIC.has_point(pt):
		bomb_aim = false
		if magic_aim:
			magic_aim = false
		elif shop.stock("magic")>0:
			magic_aim = true
			bomb_hover = Vector2i(-1,-1)
		else:
			shop_open = true
			shop_tab = 0
			shop_page = 0
		queue_redraw()
		return
	if BOOST_REROLL.has_point(pt):
		bomb_aim = false
		magic_aim = false
		_use_reroll()
		return
	if magic_aim and BOARD.has_point(pt):
		_use_magic(_board_cell(pt))
		return
	if magic_aim:
		magic_aim = false
		queue_redraw()
		return
	
	if bomb_aim and BOARD.has_point(pt):
		var chosen: Vector2i = _board_cell(pt)
		if chosen.x>=0:
			_use_bomb(chosen)
		return
	if bomb_aim:
		bomb_aim = false
		queue_redraw()
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
	var daily_bonus: Dictionary = shop.claim_daily()
	if not daily_bonus.is_empty():
		mission_notice = ("DZIEŃ" if language=="pl" else "DAY")+" %d · +%d ◉" % [
			int(daily_bonus["day"]),int(daily_bonus["coins"])]
		if not str(daily_bonus["skin"]).is_empty():
			mission_notice += " ★ "+shop_t("star_capybara")
		mission_notice_time = 3.2
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

func _trigger_pressure_wave() -> void:
	wave_queued = false
	if phase != "drop":
		return
	phase = "anim"
	action_serial += 1
	action_id = "action:%s:%d" % [run_id,action_serial]
	wave_number += 1
	var beads: int = Rules.wave_marble_count(wave_number)
	wave_time_left = Rules.wave_interval(wave_number)
	var wave: Dictionary = Rules.rise_wave(board,rng,beads)
	if bool(wave.get("overflow",false)):
		# An incoming row cannot silently delete occupied top cells.
		lives -= 1
		if feedback != null:
			feedback.cue("fail")
		telemetry.track("life_lost",{"run_id":run_id,"cause":"wave_overflow","wave":wave_number,"lives_left":lives})
		_shock(BOARD.position+Vector2(BOARD.size.x*0.5,CELL*0.5),2.6,Color("#ff678f"))
		if lives <= 0:
			phase = "over"
			_on_game_over()
			_save_progress()
			queue_redraw()
			return
		board = Rules.rescue(board)
		wave = Rules.rise_wave(board,rng,beads)
		if not bool(wave.get("valid",false)):
			phase = "drop"
			_save_progress()
			return
	if feedback != null:
		feedback.cue("rotate")
	_shock(BOARD.get_center(),1.6,Color("#ffae83"))
	await _animate_to(wave.board,wave.motions,0.45,"wave")
	var rock_added: bool = false
	if wave_number % 2 == 0:
		var rock: Dictionary = Rules.spawn_rock(board,rng)
		if bool(rock.get("spawned",false)):
			board = rock.board
			rock_added = true
			_shock(BOARD.position+(Vector2(rock.cell)+Vector2(0.5,0.5))*CELL,1.4,Color("#ffe0a7"))
	telemetry.track("pressure_wave",{
		"run_id":run_id,"wave":wave_number,"marbles":beads,
		"rock_added":rock_added,"next_interval":wave_time_left
	})
	chain_depth = 0
	await _resolve_cascades()
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
			# Preserve hard obstacles during the last-resort clear.
			# Only adjacent POPs / bomb damage may actually destroy rocks.
			board = Rules.clear_marbles(board)
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
		var rocks: Dictionary = Rules.damage_rocks(board,hits)
		board = Rules.erase_matches(rocks.board,hits)
		for cracked_cell in rocks.cracked:
			_burst(cracked_cell,8)
			_shock(BOARD.position+(Vector2(cracked_cell)+Vector2(0.5,0.5))*CELL,
				0.7,Color("#fcdbaa"))
		if not rocks.cracked.is_empty():
			telemetry.track("rock_cracked",{
				"run_id":run_id,"hit_count":rocks.cracked.size(),
				"destroyed":rocks.destroyed.size(),"wave":wave_number
			})
		score += payout
		var earned_coins: int = shop.credit_pop(action_id+":coins:"+str(chain_depth),payout)
		if earned_coins > 0:
			shop_notice = "+%d ◉" % earned_coins
			shop_notice_time = 1.4
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

# SVG sources are imported at 256px and drawn down at mobile touch-icon sizes.
# One pixel-aligned path for all UI glyphs; CanvasItem uses linear filtering.
func _draw_icon(sprite: Texture2D, at: Vector2, size_px: float, opacity: float=1.0) -> void:
	var edge: float = roundf(size_px)
	var top_left: Vector2 = (at-Vector2.ONE*edge*0.5).round()
	draw_texture_rect(sprite,Rect2(top_left,Vector2.ONE*edge),false,
		Color(1.0,1.0,1.0,clampf(opacity,0.0,1.0)))

func _spark(at: Vector2, radius: float, tint: Color, opacity: float=1.0) -> void:
	var c: Color = Color(tint.r,tint.g,tint.b,opacity)
	draw_line(at+Vector2(-radius,0),at+Vector2(radius,0),c,2.2,true)
	draw_line(at+Vector2(0,-radius),at+Vector2(0,radius),c,2.2,true)
	draw_circle(at,2.0,Color(1,1,1,opacity))


func _neon_panel(rect: Rect2, accent: Color, strong: bool=false) -> void:
	# Multi-layer faux glass: shadow, translucent bezel, rim and specular sweep.
	var curve: int = 22 if strong else 18
	var edge: float = 0.75 if strong else 0.52
	_box(Rect2(rect.grow(2).position+Vector2(0,6),rect.grow(2).size),Color("#020617",0.76),curve+2)
	_box(rect.grow(2),Color(accent.r,accent.g,accent.b,0.074),curve+2)
	_box(rect,Color("#101a35",0.97),curve,
		Color(accent.r,accent.g,accent.b,edge),2)
	_box(Rect2(rect.position+Vector2(6,6),
		Vector2(rect.size.x-12,minf(31,rect.size.y*0.34))),
		Color("#d4eaff",0.065),maxi(7,curve-7))
	draw_line(rect.position+Vector2(17,4),
		rect.position+Vector2(rect.size.x-17,4),
		Color(accent.r,accent.g,accent.b,0.80 if strong else 0.50),
		2.2,true)
	draw_line(rect.position+Vector2(21,rect.size.y-5),
		rect.position+Vector2(rect.size.x-21,rect.size.y-5),
		Color("#c0d8ff",0.15),1.2,true)
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
	# High-resolution candy-glass sprite with a lit rim and subtle physical halo.
	var marble: Texture2D = MARBLE_TEXTURES[clampi(color_index,0,2)]
	var tint: Color = COLORS[clampi(color_index,0,2)]
	draw_circle(center,radius*1.24,
		Color(tint.r,tint.g,tint.b,0.11*alpha))
	var half_width: float = radius*1.255*stretch.x
	var half_height: float = radius*1.255*stretch.y
	var box: Rect2 = Rect2(center-Vector2(half_width,half_height),
		Vector2(half_width*2.0,half_height*2.0))
	if progression != null and progression.skin == "aurora":
		draw_circle(center,radius*1.16,Color(tint.r,tint.g,tint.b,0.13*alpha))
	draw_texture_rect(marble,box,false,Color(1.0,1.0,1.0,alpha))
	draw_arc(center,radius*0.992,0,TAU,40,
		Color(tint.r,tint.g,tint.b,0.48*alpha),1.8,true)
	draw_arc(center,radius*0.83,-PI*0.79,-PI*0.24,22,
		Color("#ecfaff",0.47*alpha),1.5,true)
	if shop != null and shop.equipped_skin == "neon":
		var tint_neon: Color = COLORS[clampi(color_index,0,2)]
		draw_arc(center,radius*1.07,0,TAU,42,
			Color(tint_neon.r,tint_neon.g,tint_neon.b,0.83*alpha),3.0,true)
		draw_arc(center,radius*0.79,-PI*0.82,-PI*0.17,19,Color("#ffffff",0.84*alpha),2.8,true)
	elif shop != null and shop.equipped_skin == "gold":
		draw_arc(center,radius*1.06,0,TAU,46,Color("#ffd37e",0.96*alpha),3.4,true)
		draw_circle(center+Vector2(-radius*0.35,-radius*0.49),radius*0.14,
			Color("#fff4cc",0.74*alpha))
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
	# This is a real vector art layer, not a few procedural flat gradients.
	draw_texture_rect(BACKDROP,Rect2(Vector2.ZERO,BASE),false)
	# Slow non-distracting glints above the scenic planet and beside the board.
	for i in range(7):
		var px: float = 14.0+float(i*113%692)
		var py: float = 235.0+float(i*137%647)
		var alpha: float = 0.12+0.13*(0.5+0.5*sin(clock*0.9+float(i)*2.1))
		_spark(Vector2(px,py),2.4+float(i%3),Color("#b6dfff"),alpha)
	# Raised shape tray and secondary button deck, with separate light rims.
	_box(Rect2(DOCK_SHAPES.grow(3).position+Vector2(0,7),DOCK_SHAPES.grow(3).size),
		Color("#030817",0.81),29)
	_box(DOCK_SHAPES.grow(3),Color("#131e3e",0.97),27,
		Color("#6c89d0",0.68),2)
	_box(Rect2(DOCK_SHAPES.position+Vector2(7,7),
		Vector2(DOCK_SHAPES.size.x-14,21)),Color("#b9caff",0.058),12)
	draw_line(Vector2(54,DOCK_SHAPES.position.y+4),
		Vector2(659,DOCK_SHAPES.position.y+4),
		Color("#99c4ff",0.51),1.8,true)
	_box(Rect2(DOCK_ACTIONS.grow(3).position+Vector2(0,7),DOCK_ACTIONS.grow(3).size),
		Color("#030716",0.88),28)
	_box(DOCK_ACTIONS.grow(3),Color("#101a35",0.96),28,
		Color("#6d67b6",0.54),2)
	draw_line(Vector2(57,DOCK_ACTIONS.position.y+4),
		Vector2(660,DOCK_ACTIONS.position.y+4),
		Color("#ba92f8",0.28),1.8,true)
func _draw_header() -> void:
	# Brand sign has ambient chromatic edge-light rather than plain white text.
	_text("POP",Vector2(25,71),51,Color("#334aaf",0.32))
	_text("DROP",Vector2(137,71),51,Color("#20c6bc",0.25))
	_text("POP",Vector2(24,69),50,Color("#fffaff"))
	_text("DROP",Vector2(133,69),50,Color("#a5fff2"))
	_text("G R A V I T Y",Vector2(29,104),18,Color("#aacaff"))
	draw_line(Vector2(26,111),Vector2(100,111),Color("#ff79ba"),3.2,true)
	draw_line(Vector2(107,111),Vector2(228,111),Color("#5ff8e6"),3.2,true)
	# Distinctive orbital accent beside the title.
	draw_arc(Vector2(274,59),20,PI*0.8,PI*1.97,27,Color("#fa6fb3",0.53),2.6,true)
	draw_arc(Vector2(274,59),24,-PI*0.07,PI*0.62,14,Color("#7ceeff",0.55),2.2,true)
	_spark(Vector2(291,45),3.2,Color("#f8daff"),0.78)
	_neon_panel(COINS_OPEN,Color("#f7c879"))
	_draw_icon(ICON_COIN,COINS_OPEN.position+Vector2(24,27),40)
	_fit_center(str(shop.coins),COINS_OPEN.position.x+88,COINS_OPEN.position.y+36,23,66,Color("#fff4df"))
	_neon_panel(SHOP_OPEN,Color("#ffd390"))
	_draw_icon(ICON_SHOP,SHOP_OPEN.get_center(),37)
	_neon_panel(PROFILE_OPEN,Color("#9bcaed"))
	_draw_icon(ICON_PROFILE,PROFILE_OPEN.get_center(),37)
	_neon_panel(SETTINGS_OPEN,Color("#a7b2f2"))
	_draw_icon(ICON_SETTINGS,SETTINGS_OPEN.get_center(),37)
	_neon_panel(LANG_RECT,Color("#8496d7"))
	_draw_icon(ICON_GLOBE,Vector2(LANG_RECT.get_center().x,LANG_RECT.position.y+20),24)
	_fit_center(language.to_upper(),LANG_RECT.get_center().x,LANG_RECT.position.y+46,
		14,LANG_RECT.size.x-8,Color("#f2f4ff"))
	_fit_center("⚡ %d/%d" % [shop.energy,Shop.MAX_ENERGY],253,110,15,90,Color("#ffdf98"))
func _draw_hud() -> void:
	# The information hierarchy: score / upcoming wave / lives.
	_neon_panel(HUD_SCORE,Color("#da7dab"))
	_text(t("score").to_upper(),Vector2(39,158),14,Color("#bdadd4"))
	_fit_center(str(int(round(display_score))),HUD_SCORE.position.x+86,HUD_SCORE.position.y+72,
		37,177,Color("#ffffff"))
	_fit_center(t("best")+": "+str(best),HUD_SCORE.position.x+150,HUD_SCORE.position.y+24,
		12,125,Color("#f0cd91"))
	_neon_panel(HUD_WAVE,Color("#ba91fa"))
	_fit_center(("FALA" if language=="pl" else "WAVE")+" %d" % (wave_number+1),
		HUD_WAVE.position.x+70,HUD_WAVE.position.y+30,19,123,Color("#b9dcff"))
	var warning: bool = wave_time_left<=5.0
	_fit_center("%02d:%02d" % [int(wave_time_left)/60,int(ceil(wave_time_left))%60],
		HUD_WAVE.position.x+220,HUD_WAVE.position.y+33,25,96,
		Color("#ffb1b8") if warning else Color("#ffffff"))
	var interval: float = maxf(1.0,Rules.wave_interval(wave_number))
	var progress: float = 1.0-clampf(wave_time_left/interval,0.0,1.0)
	_box(Rect2(HUD_WAVE.position+Vector2(19,54),Vector2(243,13)),Color("#070f25"),7,
		Color("#4e4c86"),1)
	_box(Rect2(HUD_WAVE.position+Vector2(23,58),Vector2(maxf(1.0,235.0*progress),5)),
		Color("#ff819f") if warning else Color("#bb86fb"),4)
	if warning:
		_spark(HUD_WAVE.position+Vector2(255,63),4,Color("#ffd6af"),0.6+0.4*sin(clock*9.0))
	_neon_panel(HUD_LIVES,Color("#fb8fb6"))
	_fit_center(t("life").to_upper(),HUD_LIVES.get_center().x,HUD_LIVES.position.y+24,
		14,119,Color("#dec2d4"))
	for i in range(3):
		var alive: bool = i<lives
		var position: Vector2 = Vector2(HUD_LIVES.position.x+29+i*43,HUD_LIVES.position.y+64)
		_draw_icon(ICON_HEART,position,38,1.0 if alive else 0.24)
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
	_draw_wave_timer()
	_draw_pieces()
	_draw_buttons()
	_draw_boost_controls()
	_draw_drag_overlay()
	_draw_tap_ripple()
	if (bomb_aim or magic_aim) and phase == "drop":
		_draw_bomb_target()
	if glow > 0.0:
		draw_rect(Rect2(0,0,720,1280),Color(0.8,0.94,1.0,0.055*glow))
	if praise_timer > 0.0 and phase != "over":
		_draw_praise()
	if phase == "over":
		_draw_game_over()
		# Keep the same familiar shop/profile/settings positions on the end screen.
		_draw_header()
	if shop_notice_time > 0 and not settings_open and not profile_open and not shop_open:
		_draw_shop_notice()
	if mission_notice_time > 0 and not settings_open and not profile_open:
		_draw_mission_toast()
	if level_fx_time > 0 and not settings_open and not profile_open:
		_draw_level_celebration()
	if settings_open:
		_draw_settings()
	if profile_open:
		_draw_profile()
	if shop_open:
		_draw_shop()
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

func _draw_rock(center: Vector2, stone: int, alpha: float = 1.0) -> void:
	var hp: int = clampi(stone-Rules.ROCK_MIN+1,1,3)
	var rim: Color = Color("#e2b879") if hp == 1 else Color("#a8a5bc")
	draw_circle(center,38.0,Color(0.03,0.06,0.14,0.6*alpha))
	_box(Rect2(center-Vector2(32,32),Vector2(64,64)),
		Color(0.16,0.18,0.26,alpha),13,Color(rim.r,rim.g,rim.b,alpha),3)
	draw_colored_polygon(PackedVector2Array([
		center+Vector2(-24,-22),center+Vector2(15,-27),
		center+Vector2(27,-11),center+Vector2(11,14),
		center+Vector2(-21,19),center+Vector2(-28,2)
	]),Color(0.35,0.38,0.47,0.65*alpha))
	draw_line(center+Vector2(-22,-13),center+Vector2(10,-21),
		Color(0.78,0.81,0.91,0.68*alpha),2.4,true)
	if hp <= 2:
		draw_line(center+Vector2(-8,-17),center+Vector2(9,1),
			Color(0.04,0.07,0.14,0.94*alpha),3.6,true)
		draw_line(center+Vector2(9,1),center+Vector2(-3,23),
			Color(0.04,0.07,0.14,0.94*alpha),3.4,true)
	if hp == 1:
		draw_line(center+Vector2(9,1),center+Vector2(24,-8),
			Color(0.04,0.07,0.14,0.94*alpha),3.6,true)
	for n in range(3):
		var pos: Vector2 = center+Vector2(-16+float(n)*16,25)
		draw_circle(pos,4.3,Color("#ffdc94",alpha) if n < hp else Color(0.05,0.07,0.14,0.86*alpha))

func _draw_board() -> void:
	# Cabinet-depth border, four illuminated corners, and a living light rail.
	# Premium board cabinet: restrained luminous bezel, focus on marbles.
	var frame: Rect2 = BOARD.grow(12)
	draw_circle(BOARD.get_center(),BOARD.size.x*0.61,Color("#346fdb",0.038))
	_box(frame.grow(5),Color("#030816",0.86),29)
	_box(frame,Color("#1c2b4f"),24,Color("#667fcb",0.65),2)
	_box(BOARD.grow(4),Color("#080f26"),16,Color("#304975"),2)
	var rail: float = 0.67+0.21*sin(clock*1.6)
	draw_line(frame.position+Vector2(27,4),
		frame.position+Vector2(frame.size.x*0.49,4),
		Color("#f681d1",rail),2.7,true)
	draw_line(frame.position+Vector2(frame.size.x*0.54,frame.size.y-4),
		frame.position+Vector2(frame.size.x-27,frame.size.y-4),
		Color("#78e5ff",rail),2.7,true)
	draw_arc(frame.get_center(),frame.size.x*0.54,PI*0.93,PI*1.14,24,
		Color("#6fe8ff",0.10),2.0,true)
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
			_box(Rect2(tile+Vector2(2,2),Vector2(CELL-4.0,CELL-4.0)),
				Color("#101c38") if (x+y)%2==0 else Color("#15223e"),11,
				Color("#405583",0.69),1)
			draw_line(tile+Vector2(14,6),tile+Vector2(CELL-14,6),
				Color("#b6caff",0.13),1.4,true)
			if phase=="drop" and x==hover_column:
				draw_rect(Rect2(tile+Vector2(4,4),Vector2(CELL-8.0,CELL-8.0)),
					Color("#9df7e8",0.085))
			var center: Vector2 = tile+Vector2(CELL*0.5,CELL*0.5)
			draw_circle(center,CELL*0.32,Color("#050b1c",0.78))
			draw_arc(center,CELL*0.32,-PI*0.86,-PI*0.12,22,
				Color("#9bb5ff",0.12),1.4,true)
			var occupied: bool = board[y][x] != Rules.EMPTY
			if occupied and not hidden.has(y*8+x) and Rules.is_rock(int(board[y][x])):
				_draw_rock(center,int(board[y][x]))
			elif occupied and not hidden.has(y*8+x):
				var is_pop: bool = Vector2i(x,y) in flash
				if is_pop and pop_time > 0.0:
					var progress: float = 1.0-pop_time/pop_length
					var swell: float = 1.0+0.30*sin(progress*PI)
					var tint: Color = COLORS[int(board[y][x])]
					draw_circle(center,CELL*0.54+19.0*progress,
						Color(tint.r,tint.g,tint.b,0.28*(1.0-progress)))
					_ball(center,CELL*0.367*swell,int(board[y][x]))
					_spark(center,13.0+progress*23.0,Color.WHITE,progress*0.8)
				else:
					_ball(center,CELL*0.367,int(board[y][x]))
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
			var at: Vector2 = BOARD.get_center()+Vector2.from_angle(angle)*(BOARD.size.x*0.5+26.0)
			_spark(at,7+6*sin(step*PI),Color("#adf8ff"),0.54)
	if animating:
		var raw: float = clampf(motion_time/motion_duration,0.0,1.0)
		var factor: float = raw*raw*(3.0-2.0*raw) if motion_kind=="spin" or motion_kind=="roll" else 1.0-pow(1.0-raw,3.4)
		for m in motion:
			var at: Vector2 = _motion_position(m,factor)
			var center: Vector2 = BOARD.position+(at+Vector2(0.5,0.5))*CELL
			if Rules.is_rock(int(m["color"])):
				_draw_rock(center,int(m["color"]))
				continue
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
	# Single compact status line gives shapes room; no second full HUD.
	_neon_panel(DOCK_STATUS,Color("#607da6"))
	_fit_center("%s %02d" % [t("move"),moves+1],109,904,17,147,Color("#f4f6ff"))
	draw_line(Vector2(202,882),Vector2(202,909),Color("#637292",0.48),1.1,true)
	var actual: int = mini(int(pending_group.get("count",0)),Rules.POP_THRESHOLD)
	var bead_color: Color = COLORS[clampi(int(pending_group.get("color",0)),0,2)]
	_fit_center(t("charge").to_upper(),266,892,12,100,Color("#9daccc"))
	for i in range(Rules.POP_THRESHOLD):
		var center: Vector2 = Vector2(237+float(i)*31,902)
		var lit: bool = i<actual
		draw_circle(center,10.1,Color("#0b142a"))
		draw_circle(center,7.7,bead_color if lit else Color("#394663"))
		if lit:
			draw_circle(center+Vector2(-2,-2),2.1,Color(1,1,1,0.65))
	_fit_center("%d/5" % actual,436,905,18,69,Color("#ffe7c3"))
	draw_line(Vector2(478,882),Vector2(478,909),Color("#637292",0.48),1.1,true)
	var height_used: int = Rules.tallest_column(board)
	var warning: bool = height_used>=6
	var accent: Color = Color("#ff819f") if warning else Color("#86e8ce")
	_fit_center(t("danger").to_upper(),556,889,12,126,Color("#9cafd1"))
	_box(Rect2(502,896,130,8),Color("#090e22"),5)
	_box(Rect2(504,898,126.0*float(height_used)/8.0,4),accent,3)
	_fit_center("%d/8" % height_used,657,906,16,55,accent)
func _draw_wave_timer() -> void:
	# Integrated into the HUD; keep a single timer instead of duplicate strips.
	pass
func _piece_card_rect(index: int) -> Rect2:
	return Rect2(29+index*229,953,205,101)
func _piece_span(piece: Array) -> Vector2i:
	var largest: Vector2i = Vector2i.ZERO
	for bead in piece:
		largest.x = maxi(largest.x,int(bead[0]))
		largest.y = maxi(largest.y,int(bead[1]))
	return largest+Vector2i.ONE

func _board_cell(pt: Vector2) -> Vector2i:
	if not BOARD.has_point(pt):
		return Vector2i(-1,-1)
	return Vector2i(
		clampi(int((pt.x-BOARD.position.x)/CELL),0,7),
		clampi(int((pt.y-BOARD.position.y)/CELL),0,7)
	)

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
	_text(t("next").to_upper(),Vector2(39,944),15,Color("#d0dafa"))
	var instruction: String = "DOTKNIJ LUB PRZECIĄGNIJ" if language=="pl" else "TAP OR DRAG"
	_fit_center(instruction,577,944,12,218,Color("#a2b4d6"))
	for i in range(pieces.size()):
		var rect: Rect2 = _piece_card_rect(i)
		var selected: bool = selected_piece==i
		var tint: Color = Color("#63f3ef") if selected else Color("#7e8fc2")
		var pulsing: float = 0.76+0.20*sin(clock*3.6)
		_box(Rect2(rect.position+Vector2(0,6),rect.size),Color("#030819",0.90),21)
		if selected:
			_box(rect.grow(4),Color("#38d7f1",0.105),23)
		_box(rect,Color("#0d334f") if selected else Color("#17223e"),19,
			Color(tint.r,tint.g,tint.b,pulsing if selected else 0.52),
			3 if selected else 2)
		_box(Rect2(rect.position+Vector2(7,7),Vector2(rect.size.x-14,25)),
			Color("#b6ffff",0.13) if selected else Color("#c4d4ff",0.07),12)
		draw_line(rect.position+Vector2(23,rect.size.y-6),
			rect.position+Vector2(rect.size.x-23,rect.size.y-6),
			Color("#7afbfc",0.78) if selected else Color("#a4c7ff",0.16),
			2.2,true)
		# Fine micro-grid implies a physical capsule rather than a flat UI box.
		for gx in range(3):
			for gy in range(2):
				draw_circle(rect.position+Vector2(72+gx*29,42+gy*28),
					0.95,Color("#9acafb",0.12))
		var medallion: Vector2 = rect.position+Vector2(23,20)
		draw_circle(medallion,17,Color("#19abc3") if selected else Color("#343f69"))
		draw_arc(medallion,17,0,TAU,32,tint,2,true)
		_center(str(i+1),medallion.x,medallion.y+6,17,Color.WHITE)
		var piece: Array = pieces[i]
		var span: Vector2i = _piece_span(piece)
		var step: float = minf(36.0,minf(72.0/float(maxi(1,span.y-1)),
			151.0/float(maxi(1,span.x-1))))
		var radius: float = minf(19.5,step*0.48)
		var center_x: float = rect.get_center().x-float(span.x-1)*step*0.5
		var center_y: float = rect.get_center().y+3.0-float(span.y-1)*step*0.5
		for bead in piece:
			var position: Vector2 = Vector2(
				center_x+float(bead[0])*step,center_y+float(bead[1])*step)
			var color: Color = COLORS[int(bead[2])]
			if selected:
				draw_circle(position,radius*1.48,
					Color(color.r,color.g,color.b,0.11))
			_ball(position,radius,int(bead[2]),
				0.43 if dragging_piece and selected else 1.0)
func _draw_buttons() -> void:
	# Primary actions live beneath the selector with a true 32px touch gap.
	var enabled: bool = phase=="drop"
	for i in range(2):
		var left: bool = i==0
		var rect: Rect2 = LEFT_RECT if left else RIGHT_RECT
		var accent: Color = Color("#f875c1") if left else Color("#4fe1eb")
		var bright: Color = Color("#ffe0f3") if left else Color("#dbffff")
		var base: Color = Color("#653166") if left else Color("#13586e")
		var score_hint: int = int(preview_left.get("score",0)) if left else int(preview_right.get("score",0))
		var pressed: bool = enabled and tap_time>0.0 and rect.has_point(tap_point)
		_box(Rect2(rect.position+Vector2(0,7),rect.size),Color("#020719",0.82),23)
		_box(rect,base if enabled else Color("#303a53"),23,
			Color(accent.r,accent.g,accent.b,0.95) if enabled else Color("#60708e"),3)
		_box(Rect2(rect.position+Vector2(7,7),Vector2(rect.size.x-14,28)),
			Color("#fff7ff",0.10 if enabled else 0.035),14)
		var disc: Vector2 = rect.position+Vector2(50 if left else rect.size.x-50,42)
		draw_circle(disc,32,Color("#10152d",0.39))
		_draw_icon(ICON_ROTATE_LEFT if left else ICON_ROTATE_RIGHT,
			disc,59,1.0 if enabled else 0.38)
		var txt_x: float = rect.position.x+(195 if left else 121)
		_fit_center("OBRÓĆ" if language=="pl" else "ROTATE",txt_x,
			rect.position.y+31,20,166,Color("#fff6fa") if enabled else Color("#99a5be"))
		_fit_center(t("left") if left else t("right"),txt_x,
			rect.position.y+57,24,170,Color.WHITE if enabled else Color("#97a4bf"))
		var note: String = "+%d  ★" % score_hint if score_hint>0 else "90°"
		_fit_center(note,txt_x,rect.position.y+77,15,144,
			Color("#fff3b8") if score_hint>0 else Color("#bfdaea"))
		if pressed:
			_box(Rect2(rect.position+Vector2(6,6),rect.size-Vector2(12,12)),
				Color(1,1,1,0.11),18)
		if score_hint>0 and enabled:
			_spark(rect.position+Vector2(rect.size.x-22 if left else 21,13),
				4.5,bright,0.66)
func _draw_game_over() -> void:
	draw_rect(Rect2(0,0,720,1280),Color("#030618",0.91))
	var center: Vector2 = Vector2(360,596)
	draw_circle(center,360,Color("#69287e",0.18))
	draw_circle(center,274,Color("#18a9ca",0.10))
	for i in range(16):
		var a: float = float(i)*TAU/16.0+clock*0.14
		var where: Vector2 = center+Vector2.from_angle(a)*(304.0+9.0*sin(clock+float(i)))
		_spark(where,5.0+float(i%4),Color("#ffdfac"),0.32+0.10*sin(clock*2.0+float(i)))
	_neon_panel(Rect2(64,375,592,640),Color("#bd95ff"),true)
	_box(Rect2(78,389,564,615),Color("#211b3d"),26,Color("#7161a4"),1)
	draw_arc(Vector2(360,484),62,PI*0.1,PI*1.9,60,Color("#e4b7ff",0.62),3.0,true)
	for i in range(3):
		var angle: float = clock*0.34+TAU*float(i)/3.0
		_ball(Vector2(360,480)+Vector2.from_angle(angle)*54.0,18.0,i)
	_fit_center(t("over"),360,567,51,520,Color.WHITE)
	_fit_center(t("score"),360,604,18,420,Color("#b6c5e6"))
	_fit_center(str(score),360,681,83,490,Color("#ffe5a9"))
	_fit_center(t("best")+"  "+str(best),360,718,23,460,Color("#ddc9ff"))
	_box(Rect2(RESTART_RECT.position+Vector2(0,7),RESTART_RECT.size),Color("#04091a"),25)
	_box(RESTART_RECT,Color("#50e6c9") if shop.energy>0 else Color("#60677c"),
		25,Color("#b8fff0") if shop.energy>0 else Color("#798ca5"),3)
	_fit_center(t("again") if shop.energy>0 else shop_t("no_energy"),360,777,27,462,
		Color("#102846") if shop.energy>0 else Color.WHITE)
	var ad_ready: bool = ads != null and ads.rewarded_ready()
	var can_revive: bool = revives<1 and not pieces.is_empty()
	_box(RESCUE_RECT,Color("#334c69"),21,Color("#85bdf5"),2)
	_fit_center(("REKLAMA" if language=="pl" else "WATCH AD")
		if ad_ready and can_revive else ("BRAK REKLAMY" if language=="pl" else "NO AD"),
		RESCUE_RECT.get_center().x,RESCUE_RECT.position.y+48,19,222,
		Color.WHITE if ad_ready and can_revive else Color("#9ca8be"))
	_box(COIN_RESCUE_RECT,Color("#55405e") if shop.coins>=Shop.RESCUE_PRICE and can_revive
		else Color("#32314c"),21,Color("#efc17d") if can_revive else Color("#756b8a"),2)
	_fit_center("220 ◉  "+("GRAJ DALEJ" if language=="pl" else "CONTINUE"),
		COIN_RESCUE_RECT.get_center().x,COIN_RESCUE_RECT.position.y+48,
		19,222,Color.WHITE if shop.coins>=Shop.RESCUE_PRICE and can_revive else Color("#9490ab"))
	_box(ENERGY_AD_RECT,Color("#233d58"),14,Color("#608cab"),1)
	var sec: int = shop.energy_seconds_remaining()
	var min_left: int = int(ceil(float(sec)/60.0))
	_fit_center("⚡ %d/5  •  +1 / %d MIN" % [shop.energy,min_left] if shop.energy < Shop.MAX_ENERGY
		else "⚡ 5/5  •  MAX",360,944,16,255,Color("#d6e8ff"))
	_fit_center(ad_note if not ad_note.is_empty() else (
		"RATUNEK: RAZ NA RUNDĘ • REKLAMA = +1 ENERGII"
		if language=="pl" else "ONE CONTINUE PER RUN • AD = +1 ENERGY"),
		360,993,15,520,Color("#c0b5d8"))

func _draw_settings() -> void:
	draw_rect(Rect2(0,0,720,1280),Color("#030618",0.94))
	_neon_panel(Rect2(72,342,576,735),Color("#8bbde0"),true)
	_fit_center("USTAWIENIA" if language == "pl" else "SETTINGS",304,414,38,390,Color.WHITE)
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
	_box(Rect2(166,755,388,56),Color("#162943",0.94*strength),22,
		Color("#f8d99e",0.7*strength),2)
	_fit_center(mission_notice,360,792,24,359,
		Color(1.0,0.91,0.66,strength))

func _draw_profile() -> void:
	draw_rect(Rect2(0,0,720,1280),Color("#030618",0.95))
	_neon_panel(PROFILE_CARD,Color("#9bb9ed"),true)
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

func _draw_shop_notice() -> void:
	var alpha: float = minf(1.0,shop_notice_time/0.25)
	_box(Rect2(198,739,324,56),Color("#252740",0.94*alpha),19,
		Color("#f9dba4",0.73*alpha),2)
	_fit_center(shop_notice,360,774,23,303,Color(1,0.93,0.72,alpha))

func _draw_boost_controls() -> void:
	if phase=="over":
		return
	var powers: Array = ["bomb","magic","reroll"]
	var boxes: Array = [BOOST_BOMB,BOOST_MAGIC,BOOST_REROLL]
	var icons: Array = [ICON_BOMB,ICON_MAGIC,ICON_REROLL]
	for i in range(3):
		var id: String = str(powers[i])
		var rect: Rect2 = boxes[i]
		var stock: int = shop.stock(id)
		var accent: Color = Color("#f9c276") if i==0 else (
			Color("#d5a4ff") if i==1 else Color("#79c8fa"))
		var usable: bool = phase=="drop" and stock>0
		var selected: bool = (i==0 and bomb_aim) or (i==1 and magic_aim)
		_box(Rect2(rect.position+Vector2(0,5),rect.size),Color("#060a1a",0.78),18)
		_box(rect,Color("#624443") if selected else Color("#2c345c"),
			18,accent if usable or selected else Color("#5a6a87"),2)
		_box(Rect2(rect.position+Vector2(6,6),Vector2(rect.size.x-12,22)),Color(1,1,1,0.085),11)
		var at: Vector2 = rect.position+Vector2(34,33)
		draw_circle(at,26,Color(accent.r,accent.g,accent.b,0.10))
		_draw_icon(icons[i],at,50,1.0 if usable or selected else 0.48)
		_fit_center(shop_t(id),rect.position.x+121,rect.position.y+40,18,136,Color.WHITE)
		draw_circle(rect.position+Vector2(rect.size.x-17,rect.size.y-14),15,Color("#09162b"))
		_center(str(stock),rect.position.x+rect.size.x-17,rect.position.y+rect.size.y-8,16,
			Color("#ffe5bc") if stock>0 else Color("#8294aa"))

func _draw_bomb_target() -> void:
	if bomb_hover.x >= 0:
		if magic_aim:
			var rect: Rect2 = Rect2(BOARD.position+Vector2(bomb_hover)*CELL,Vector2(CELL,CELL))
			draw_rect(rect,Color("#c9a2ff",0.25+0.11*sin(clock*9.0)))
			draw_rect(rect,Color("#e3caff",0.9),false,2.8)
		else:
			for y in range(maxi(0,bomb_hover.y-1),mini(8,bomb_hover.y+2)):
				for x in range(maxi(0,bomb_hover.x-1),mini(8,bomb_hover.x+2)):
					var rect: Rect2 = Rect2(BOARD.position+Vector2(x,y)*CELL,Vector2(CELL,CELL))
					draw_rect(rect,Color("#ffa777",0.25+0.11*sin(clock*9.0)))
					draw_rect(rect,Color("#ffd1a4",0.68),false,2.3)
	_box(Rect2(147,828,426,51),Color("#624152",0.97),16,Color("#ffc18f"),2)
	_fit_center(shop_t("magic_aim") if magic_aim else shop_t("aim"),360,862,18,407,Color("#fff2d9"))

func _draw_shop() -> void:
	draw_rect(Rect2(0,0,720,1280),Color("#050819",0.96))
	_neon_panel(Rect2(54,225,612,863),Color("#f1cb91"),true)
	_box(Rect2(67,238,586,837),Color("#191d38"),27,Color("#7c679d"),2)
	_draw_icon(ICON_SHOP,Vector2(129,288),46)
	_fit_center(shop_t("shop"),324,313,43,324,Color("#fff1d9"))
	_box(SHOP_CLOSE,Color("#474a70"),18,Color("#9eadd0"),2)
	_fit_center(shop_t("close"),574,301,17,108,Color.WHITE)
	_neon_panel(Rect2(98,338,522,51),Color("#ffd487"))
	_fit_center(shop_t("coins"),253,371,22,187,Color("#ffe8b3"))
	_draw_icon(ICON_COIN,Vector2(387,361),37)
	_fit_center(str(shop.coins),494,371,25,192,Color("#ffe8b3"))
	for tab in range(2):
		var rect: Rect2 = SHOP_TAB_BOOST if tab==0 else SHOP_TAB_SKINS
		var selected: bool = shop_tab==tab
		_box(rect,Color("#266259") if selected else Color("#262b4d"),
			19,Color("#86f0d8") if selected else Color("#6475a6"),2)
		_fit_center(shop_t("boosts") if tab==0 else shop_t("skins"),
			rect.get_center().x,447,22,225,Color.WHITE if selected else Color("#bac4d9"))
	var shown: Array = _shop_items()
	for i in range(shown.size()):
		var id: String = str(shown[i])
		var special: bool = id==Shop.SPECIAL_SKIN
		var product: Dictionary = {"kind":"skin","price":0} if special else Shop.item(id)
		var is_skin: bool = str(product["kind"])=="skin"
		var is_owned: bool = shop.owns_skin(id) if is_skin else false
		var is_active: bool = is_skin and shop.equipped_skin==id
		var purchasable: bool = shop.can_purchase(id)
		var rect: Rect2 = _shop_card(i)
		var accent: Color = Color("#ffcc91") if i==0 else Color("#91e5ed")
		_box(rect,Color("#252d49"),22,Color("#82efd5") if is_active else Color("#687397"),2)
		var at: Vector2 = rect.position+Vector2(80,86)
		draw_circle(at,54,Color(accent.r,accent.g,accent.b,0.1))
		if not is_skin:
			_draw_icon(ICON_BOMB if id=="bomb" else ICON_MAGIC if id=="magic"
				else ICON_REROLL,at,92)
		else:
			preview_skin = id
			_ball(at,38,0)
			preview_skin = ""
		_fit_center(shop_t(id),rect.position.x+339,rect.position.y+58,26,346,Color.WHITE)
		_fit_center(shop_t(id+"_desc") if not special else (
			"NAGRODA ZA 7 DNI GRY" if language=="pl" else "PLAY 7 DAYS TO UNLOCK"),
			rect.position.x+333,rect.position.y+99,16,381,Color("#cbd3e8"))
		var label: String = shop_t("active") if is_active else (
			shop_t("equip") if is_owned else ("7 DNI" if language=="pl" else "DAY 7") if special
			else shop_t("buy")+"  "+str(product["price"]))
		var available: bool = purchasable or is_owned
		_box(Rect2(rect.position+Vector2(199,131),Vector2(311,60)),
			Color("#296157") if available else Color("#46445d"),
			17,Color("#8bf3d8") if available else Color("#74708b"),2)
		if not is_owned and not special:
			_draw_icon(ICON_COIN,rect.position+Vector2(232,162),25,1.0 if purchasable else 0.45)
		_fit_center(label,rect.position.x+370,rect.position.y+172,21,256,
			Color.WHITE if available else Color("#b6b5c8"))
		if not is_skin:
			_fit_center(shop_t("stock")+": "+str(shop.stock(id)),
				rect.position.x+85,rect.position.y+175,15,166,Color("#d7d9e9"))
	_box(SHOP_PREV,Color("#2d375c"),14)
	_box(SHOP_NEXT,Color("#2d375c"),14)
	_fit_center("◀",SHOP_PREV.get_center().x,1007,23,100,Color.WHITE)
	_fit_center("▶",SHOP_NEXT.get_center().x,1007,23,100,Color.WHITE)
	_fit_center("%s %d / %d" % [shop_t("page"),shop_page+1,_shop_pages()],
		360,1007,17,230,Color("#dfe3ff"))
	_fit_center(shop_t("tip"),360,1046,17,522,Color("#b9c7e0"))
	if shop_notice_time>0:
		_fit_center(shop_notice,360,1075,18,526,Color("#ffe6b5"))
