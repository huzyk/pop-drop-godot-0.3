extends Control
## POP DROP Gravity / isolated gameplay experiment. NO real ads in this scene.
const Rules = preload("res://scripts/gravity_rules.gd")
const Session = preload("res://scripts/gravity_session.gd")
const Telemetry = preload("res://scripts/gravity_telemetry.gd")
const Ads = preload("res://scripts/gravity_ads.gd")
const Progression = preload("res://scripts/gravity_progression.gd")
const Feedback = preload("res://scripts/gravity_feedback.gd")
const Shop = preload("res://scripts/gravity_shop.gd")
const SkinArt = preload("res://scripts/gravity_skin_art.gd")
const Studio = preload("res://scripts/gravity_illustrated.gd")
const BACKDROP = preload("res://assets/ui/arcade_backdrop.svg")
const ICON_COIN = preload("res://assets/ui/icons/coin.svg")
const ICON_SHOP = preload("res://assets/ui/icons/shop.svg")
const ICON_PROFILE = preload("res://assets/ui/icons/profile.svg")
const ICON_SETTINGS = preload("res://assets/ui/icons/settings.svg")
const ICON_ROTATE_LEFT = preload("res://assets/ui/icons/rotate_left.svg")
const ICON_ROTATE_RIGHT = preload("res://assets/ui/icons/rotate_right.svg")
const ICON_BOMB = preload("res://assets/ui/icons/bomb.svg")
const ICON_REROLL = preload("res://assets/ui/icons/reroll.svg")
const ICON_HEART = preload("res://assets/ui/icons/heart.svg")
const ICON_GLOBE = preload("res://assets/ui/icons/globe.svg")
const FONT = preload("res://fonts/ClearSans-Regular.ttf")
const BOLD = preload("res://fonts/ClearSans-Bold.ttf")
# Artist-authored vector sprites imported as textures by Godot (no more circle stacks).
const MARBLE_TEXTURES = [
	preload("res://assets/skins/jelly_pals/coral.svg"),
	preload("res://assets/skins/jelly_pals/mint.svg"),
	preload("res://assets/skins/jelly_pals/blue.svg")
]
const LEGACY_MARBLE_TEXTURES = [
	preload("res://assets/marbles/coral.svg"),
	preload("res://assets/marbles/mint.svg"),
	preload("res://assets/marbles/blue.svg")
]
const BASE := Vector2(720,1280)
# 720x1280 reference layout. Visuals AND hit-testing share these rectangles.
# HUD 0..224 / board 247..855 / status 874..918 / cards 952..1054
# / rotation 1086..1172 / boosts 1193..1261.
const BOARD := Rect2(88,292,536,536)
const CELL := 67.0
const HUD_SCORE := Rect2(38,197,142,71)
const HUD_WAVE := Rect2(181,197,285,71)
const HUD_LIVES := Rect2(467,197,209,71)
const COINS_OPEN := Rect2(415,18,173,57)
const SHOP_OPEN := Rect2(414,88,71,66)
const PROFILE_OPEN := Rect2(505,88,71,66)
const SETTINGS_OPEN := Rect2(595,88,71,66)
const LANG_RECT := Rect2(651,159,55,32)
const DOCK_STATUS := Rect2(58,880,596,48)
const DOCK_SHAPES := Rect2(60,931,597,141)
const DOCK_ACTIONS := Rect2(30,1084,653,134)
const COLORS := [Color("#ff7096"),Color("#55dcad"),Color("#62b5ff")]
const SAVE_FILE := "user://pop_drop_gravity.json"
const LOCALES := ["pl","en","es","pt","de","fr","ru"]
const TR := {
	"pl":{"life":"ŻYCIA","tap_short":"DOTKNIJ KOLUMNY","score":"WYNIK","best":"REKORD","move":"RUCH","drop":"DOTKNIJ KOLUMNĘ, ABY ZRZUCIĆ","turn":"OBRÓĆ PLANSZĘ LUB GRAJ DALEJ","left":"W LEWO","right":"W PRAWO","skip":"DALEJ","next":"WYBIERZ KSZTAŁT","ready":"5 KULEK POŁĄCZONYCH BOKAMI = POP  •  BRAK RUCHÓW = KONIEC GRY","over":"KONIEC RUNDY","again":"ZAGRAJ PONOWNIE","rescue":"TEST: +1 ŻYCIE","lost":"STRATA ŻYCIA","rotate_controls":"OBRACAJ PRZYCISKAMI PONIŻEJ","rotate_help":"SPRÓBUJ OBRÓCIĆ PLANSZĘ","charge":"GRUPA","danger":"WYSOKOŚĆ","danger_soon":"UWAGA: GÓRNA LINIA!","overflow":"UTRATA ŻYCIA!","hint":"Wybierz kolumnę dla spadającego kształtu"},
	"en":{"life":"LIVES","tap_short":"TAP A COLUMN","score":"SCORE","best":"BEST","move":"MOVE","drop":"TAP A COLUMN TO DROP","turn":"ROTATE OR KEEP GOING","left":"LEFT","right":"RIGHT","skip":"NEXT","next":"CHOOSE A SHAPE","ready":"5 TOUCHING BALLS = POP  •  NO MOVES = GAME OVER","over":"GAME OVER","again":"PLAY AGAIN","rescue":"TEST: +1 LIFE","lost":"LIFE LOST","rotate_controls":"ROTATE WITH THE BUTTONS BELOW","rotate_help":"ROTATE TO MAKE ROOM","charge":"GROUP","danger":"HEIGHT","danger_soon":"CAREFUL: TOP ROW!","overflow":"LIFE LOST!","hint":"Choose a column for the falling piece"},
	"es":{"life":"VIDAS","tap_short":"TOCA COLUMNA","score":"PUNTOS","best":"RÉCORD","move":"JUGADA","drop":"TOCA UNA COLUMNA PARA SOLTAR","turn":"GIRA O CONTINÚA","left":"IZQUIERDA","right":"DERECHA","skip":"SEGUIR","next":"ELIGE UNA FIGURA","ready":"5 BOLAS CONECTADAS = POP  •  SIN JUGADAS = FIN","over":"FIN DEL JUEGO","again":"JUGAR OTRA VEZ","rescue":"PRUEBA: +1 VIDA","lost":"VIDA PERDIDA","rotate_controls":"USA LOS BOTONES PARA GIRAR","rotate_help":"GIRA PARA HACER ESPACIO","charge":"GRUPO","danger":"ALTURA","danger_soon":"¡FILA SUPERIOR!","overflow":"¡VIDA PERDIDA!","hint":"Elige una columna para las bolas"},
	"pt":{"life":"VIDAS","tap_short":"TOQUE A COLUNA","score":"PONTOS","best":"RECORDE","move":"JOGADA","drop":"TOQUE NA COLUNA PARA SOLTAR","turn":"GIRE OU CONTINUE","left":"ESQUERDA","right":"DIREITA","skip":"SEGUIR","next":"ESCOLHA UMA PEÇA","ready":"5 BOLAS CONECTADAS = POP  •  SEM JOGADAS = FIM","over":"FIM DE JOGO","again":"JOGAR DE NOVO","rescue":"TESTE: +1 VIDA","lost":"VIDA PERDIDA","rotate_controls":"USE OS BOTÕES PARA GIRAR","rotate_help":"GIRE PARA ABRIR ESPAÇO","charge":"GRUPO","danger":"ALTURA","danger_soon":"CUIDADO: TOPO!","overflow":"VIDA PERDIDA!","hint":"Escolha uma coluna para jogar"},
	"de":{"life":"LEBEN","tap_short":"SPALTE TIPPEN","score":"PUNKTE","best":"REKORD","move":"ZUG","drop":"SPALTE ANTIPPEN ZUM FALLEN","turn":"DREHEN ODER WEITER","left":"LINKS","right":"RECHTS","skip":"WEITER","next":"FORM WÄHLEN","ready":"5 VERBUNDENE KUGELN = POP  •  KEINE ZÜGE = ENDE","over":"SPIEL VORBEI","again":"NOCHMAL SPIELEN","rescue":"TEST: +1 LEBEN","lost":"LEBEN VERLOREN","rotate_controls":"MIT DEN TASTEN UNTEN DREHEN","rotate_help":"DREHE FÜR MEHR PLATZ","charge":"GRUPPE","danger":"HÖHE","danger_soon":"ACHTUNG: OBERSTE REIHE!","overflow":"LEBEN VERLOREN!","hint":"Wähle eine Spalte zum Einwerfen"},
	"fr":{"life":"VIES","tap_short":"TOUCHE COLONNE","score":"SCORE","best":"RECORD","move":"COUP","drop":"TOUCHE UNE COLONNE POUR LÂCHER","turn":"TOURNE OU CONTINUE","left":"GAUCHE","right":"DROITE","skip":"SUITE","next":"CHOISIS UNE FORME","ready":"5 BILLES CONNECTÉES = POP  •  AUCUN COUP = FIN","over":"PARTIE FINIE","again":"REJOUER","rescue":"TEST : +1 VIE","lost":"VIE PERDUE","rotate_controls":"TOURNE AVEC LES BOUTONS","rotate_help":"TOURNE POUR LIBÉRER DE LA PLACE","charge":"GROUPE","danger":"HAUTEUR","danger_soon":"ATTENTION AU SOMMET!","overflow":"VIE PERDUE!","hint":"Choisis une colonne pour les billes"},
	"ru":{"life":"ЖИЗНИ","tap_short":"ВЫБЕРИ СТОЛБЕЦ","score":"ОЧКИ","best":"РЕКОРД","move":"ХОД","drop":"НАЖМИ СТОЛБЕЦ ДЛЯ СБРОСА","turn":"ПОВЕРНИ ИЛИ ПРОДОЛЖИ","left":"ВЛЕВО","right":"ВПРАВО","skip":"ДАЛЕЕ","next":"ВЫБЕРИ ФИГУРУ","ready":"5 СОЕДИНЁННЫХ ШАРОВ = POP  •  НЕТ ХОДОВ = КОНЕЦ","over":"ИГРА ОКОНЧЕНА","again":"ИГРАТЬ СНОВА","rescue":"ТЕСТ: +1 ЖИЗНЬ","lost":"МИНУС ЖИЗНЬ","rotate_controls":"ПОВОРОТ КНОПКАМИ ВНИЗУ","rotate_help":"ПОВЕРНИ, ЧТОБЫ ОСВОБОДИТЬ МЕСТО","charge":"ГРУППА","danger":"ВЫСОТА","danger_soon":"ВНИМАНИЕ: ВЕРХ!","overflow":"МИНУС ЖИЗНЬ!","hint":"Выбери столбец для шариков"}
}
const LEFT_RECT := Rect2(30,1085,160,127)
const RIGHT_RECT := Rect2(522,1085,160,127)
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
const BOOST_BOMB := Rect2(203,1100,154,113)
const BOOST_REROLL := Rect2(364,1100,154,113)
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
var studio: Control = null
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
# Incoming waves accelerate while rocks accumulate.
var wave_number: int = 0
var wave_time_left: float = 12.0
var wave_queued: bool = false
var loss_reason: String = "" # Exact reason displayed after the game ends

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
	# Recover daily mission coins after a crash between profile and wallet saves.
	for mission in Progression.MISSIONS:
		var mid: String = str(mission["id"])
		if bool(progression.claimed.get(mid,false)):
			shop.credit_bonus("mission:"+progression.daily_day+":"+mid,_mission_coins(mid))
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
	studio = Studio.new()
	studio.game = self
	add_child(studio)
	studio.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	telemetry.track("session_start", {"restored_round": not previous.is_empty()})

func t(key: String) -> String:
	return str(TR.get(language,TR["en"]).get(key,key))

func profile_t(key: String) -> String:
	return str(PROFILE_TR.get(language,PROFILE_TR["en"]).get(key,key))

const SHOP_PL := {
	"shop":"SKLEP","boosts":"MOCE","skins":"SKÓRKI","close":"ZAMKNIJ",
	"coins":"MONETY","bomb":"BOMBA","reroll":"NOWY ZESTAW",
	"neon":"NEON","gold":"ZŁOTO","donut":"DONUTY","capybara":"KAPIBARY",
	"crystal":"KRYSZTAŁY","cosmos":"KOSMOS","star_capybara":"GWIEZDNA KAPIBARA",
	"buy":"KUP","owned":"KUPIONE","active":"AKTYWNE","equip":"WYBIERZ","stock":"POSIADASZ",
	"poor":"ZA MAŁO MONET","bought":"ZAKUPIONE!","full":"LIMIT ZAPASU",
	"aim":"DOTKNIJ POLA — BOMBA 3×3",
	"tip":"Monety i wynik gry są niezależne","energy":"ENERGIA",
	"bomb_desc":"Usuwa kulki w polu 3×3",
	"reroll_desc":"Losuje trzy nowe kształty",
	"neon_desc":"Elektryczna poświata","gold_desc":"Złota oprawa",
	"donut_desc":"Słodkie lukrowane kulki","capybara_desc":"Kapibary na planszy",
	"crystal_desc":"Błyszczące kryształy","cosmos_desc":"Kosmiczne kulki",
	"page":"STRONA","no_energy":"BRAK ENERGII","badges":"ODZNAKI"
}
const SHOP_EN := {
	"shop":"SHOP","boosts":"POWERS","skins":"SKINS","close":"CLOSE",
	"coins":"COINS","bomb":"BOMB","reroll":"NEW SET",
	"neon":"NEON","gold":"GOLD","donut":"DONUTS","capybara":"CAPYBARAS",
	"crystal":"CRYSTALS","cosmos":"COSMOS","star_capybara":"STAR CAPYBARA",
	"buy":"BUY","owned":"OWNED","active":"ACTIVE","equip":"EQUIP","stock":"OWNED",
	"poor":"NOT ENOUGH COINS","bought":"PURCHASED!","full":"INVENTORY FULL",
	"aim":"TAP CELL — BOMB 3×3",
	"tip":"Coins never affect your score","energy":"ENERGY",
	"bomb_desc":"Clear a 3×3 region",
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
	return ["bomb","reroll"] if shop_tab==0 else [
		"default","neon","gold","donut","capybara","crystal","cosmos","star_capybara"]

func _shop_pages() -> int:
	return int(ceil(float(_shop_catalog().size())/2.0))

func _shop_items() -> Array:
	var items: Array = _shop_catalog()
	var first: int = shop_page*2
	return items.slice(first,mini(first+2,items.size()))

func _shop_activate(id: String) -> void:
	if id == "default":
		shop.equip_skin("default")
		shop_notice = shop_t("active")
		shop_notice_time = 2.0
		telemetry.track("shop_skin_equip",{"skin":"default"})
		queue_redraw()
		return
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
		shop_page = 0
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

func _mission_coins(id: String) -> int:
	match id:
		"drops": return 25
		"pops": return 35
		"points": return 50
	return 0

func _on_mission_completed(mission_id: String, bonus_xp: int) -> void:
	var bonus_coins: int = shop.credit_bonus(
		"mission:"+progression.daily_day+":"+mission_id,_mission_coins(mission_id))
	mission_notice = "%s +%d XP  +%d ◉" % [profile_t("done"),bonus_xp,bonus_coins]
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
	lives = 1 # Legacy checkpoint field, not a multi-life mechanic.
	revives = 0
	loss_reason = ""
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
		"wave_time_left":wave_time_left,
		"loss_reason":loss_reason
	})

func _restore_progress(data: Dictionary) -> void:
	board = Rules.copy_board(data["board"])
	pieces = data["pieces"].duplicate(true)
	phase = str(data["phase"])
	score = int(data["score"])
	moves = int(data["moves"])
	lives = 0 if phase == "over" else 1
	revives = int(data["revives"])
	loss_reason = str(data.get("loss_reason","no_moves" if phase == "over" else ""))
	run_id = str(data.get("run_id","restored"))
	best_at_round_start = int(data.get("best_at_start",best))
	game_over_reported = bool(data.get("over_reported",phase=="over"))
	action_serial = maxi(0,int(data.get("action_serial",0)))
	action_id = ""
	wave_number = maxi(0,int(data.get("wave_number",0)))
	wave_time_left = minf(Rules.wave_interval(wave_number),clampf(float(data.get("wave_time_left",Rules.wave_interval(wave_number))),0.0,45.0))
	wave_queued = false
	bomb_aim = false
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
		"round_number":rounds_played, "cause":loss_reason
	})

func _revive() -> bool:
	if phase != "over" or revives >= 1 or pieces.is_empty():
		return false
	revives += 1
	lives = 1
	board = Rules.rescue_for_continue(board)
	# Guaranteed first move after a continue, even if all other pieces are wide.
	pieces[0] = [[0,0,rng.randi_range(0,Rules.COLOR_COUNT-1)]]
	_remember_shape(pieces[0])
	selected_piece = 0
	phase = "drop"
	ad_note = ""
	loss_reason = ""
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
	if studio != null:
		studio.queue_redraw()

func _scale() -> float:
	return minf(size.x/BASE.x,size.y/BASE.y)

func _offset() -> Vector2:
	return (size-BASE*_scale())*0.5

func _logical(screen: Vector2) -> Vector2:
	return (screen-_offset())/_scale()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pointer: Vector2 = _logical(event.position)
		if bomb_aim:
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
	if BOOST_REROLL.has_point(pt):
		bomb_aim = false
		_use_reroll()
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
	wave_time_left = Rules.wave_interval(wave_number)
	var beads: int = Rules.wave_total_marbles(wave_number)
	var wave: Dictionary = Rules.drop_wave(board,rng,beads)
	if feedback != null:
		feedback.cue("drop")
	if int(wave["added"]) > 0:
		_shock(BOARD.get_center(),1.05,Color("#ffae83"))
	await _animate_to(wave.board,wave.motions,0.31,"wave")
	# A single rock every second wave: sustained pressure, not a sudden wall.
	var rock_added: bool = false
	if wave_number % 2 == 0:
		var rock: Dictionary = Rules.spawn_rock(board,rng)
		if bool(rock.get("spawned",false)):
			board = rock.board
			rock_added = true
			_shock(BOARD.position+(Vector2(rock.cell)+Vector2(0.5,0.5))*CELL,1.2,Color("#ffe0a7"))
	if Rules.wave_is_surge(wave_number):
		_praise("NAWAŁNICA!" if language=="pl" else "SURGE!",Color("#FFE7A2"),1.35)
		_shock(BOARD.get_center(),2.0,Color("#ffb065"))
	telemetry.track("pressure_wave",{
		"run_id":run_id,"wave":wave_number,"marbles":int(wave["added"]),
		"rock_added":rock_added,"surge":Rules.wave_is_surge(wave_number),
		"next_interval":wave_time_left
	})
	chain_depth = 0
	await _resolve_cascades()
	phase = "drop"
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
	return Rules.can_recover_by_rotating(board,pieces)
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
	# The ONLY natural loss condition: no offered piece fits, even after a turn.
	# There are no ceiling deaths, wave-overflow penalties or extra lives.
	loss_reason = "no_moves"
	lives = 0
	phase = "over"
	if feedback != null:
		feedback.cue("fail")
	telemetry.track("life_lost", {
		"run_id":run_id, "cause":loss_reason, "moves":moves,
		"board_filled":Rules.filled(board),"wave":wave_number
	})
	_shock(BOARD.get_center(),2.1,Color("#ff6389"))
	_on_game_over()
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

# All graphics now live in gravity_studio.gd. Root draws nothing.
func _draw() -> void:
	pass

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


func _piece_card_rect(index: int) -> Rect2:
	return Rect2(62+index*198,932,193,139)
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

