extends Control
## POP DROP / Studio v2 — standalone, retina-ready presentation.
## Model, economy, touch bounds and persistence stay in gravity_game.gd.
## All live game art is painted here, never in the gameplay script.
const Rules = preload("res://scripts/gravity_rules.gd")
const Shop = preload("res://scripts/gravity_shop.gd")
const SkinArt = preload("res://scripts/gravity_skin_art.gd")
const Progression = preload("res://scripts/gravity_progression.gd")
const WORLD = preload("res://assets/visual_v2/world.svg")
const ORBS = [
	preload("res://assets/visual_v2/orb_peach.svg"),
	preload("res://assets/visual_v2/orb_aqua.svg"),
	preload("res://assets/visual_v2/orb_violet.svg")
]
const FONT = preload("res://fonts/ClearSans-Regular.ttf")
const BOLD = preload("res://fonts/ClearSans-Bold.ttf")
const ICONS = {
	"coins": preload("res://assets/ui/icons/coin.svg"),
	"shop": preload("res://assets/ui/icons/shop.svg"),
	"user": preload("res://assets/ui/icons/profile.svg"),
	"settings": preload("res://assets/ui/icons/settings.svg"),
	"globe": preload("res://assets/ui/icons/globe.svg"),
	"left": preload("res://assets/ui/icons/rotate_left.svg"),
	"right": preload("res://assets/ui/icons/rotate_right.svg"),
	"heart": preload("res://assets/ui/icons/heart.svg"),
	"bomb": preload("res://assets/ui/icons/bomb.svg"),
	"magic": preload("res://assets/ui/icons/magic.svg"),
	"reroll": preload("res://assets/ui/icons/reroll.svg")
}
const BASE := Vector2(720,1280)
const BOARD := Rect2(56,247,608,608)
const CELL := 76.0
const PEACH := Color("#FF6B9A")
const AQUA := Color("#3EDCC5")
const VIOLET := Color("#AAA0FF")
const GOLD := Color("#FFD585")
const INK := Color("#17254C")
const WHITE := Color("#FFFFFF")
const MIST := Color("#B3C7E5")
const ORB_COLORS = [PEACH,AQUA,VIOLET]

var game = null
var styles: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _round(rect: Rect2, color: Color, radius: int=18, stroke: Color=Color.TRANSPARENT, stroke_width: int=0) -> void:
	var key: String = "%s|%d|%s|%d" % [color.to_html(true),radius,stroke.to_html(true),stroke_width]
	if not styles.has(key):
		var s: StyleBoxFlat = StyleBoxFlat.new()
		s.bg_color = color
		s.set_corner_radius_all(radius)
		s.anti_aliasing = true
		s.anti_aliasing_size = 1.5
		if stroke_width > 0:
			s.border_color = stroke
			s.set_border_width_all(stroke_width)
		styles[key] = s
	draw_style_box(styles[key],rect)

func _card(rect: Rect2, color: Color, radius: int=23, lift: int=7) -> void:
	_round(rect.grow(3).translated(Vector2(0,lift)),Color("#060E30",0.22),radius+2)
	_round(rect,color,radius,Color("#FFFFFF",0.13),2)
	_round(Rect2(rect.position+Vector2(17,8),Vector2(maxf(1,rect.size.x-34),3)),
		Color("#FFFFFF",0.16),2)

func _label(value: String, x: float, baseline: float, pt: int, tint: Color=WHITE, bold: bool=true) -> void:
	draw_string(BOLD if bold else FONT,Vector2(x,baseline),value,HORIZONTAL_ALIGNMENT_LEFT,-1,pt,tint)

func _center(value: String, x: float, baseline: float, pt: int, tint: Color=WHITE, width: float=200.0, bold: bool=true) -> void:
	var font: Font = BOLD if bold else FONT
	var sz: int = pt
	while sz>12 and font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,sz).x>width:
		sz -= 1
	var size_px: Vector2 = font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,sz)
	draw_string(font,Vector2(x-size_px.x*0.5,baseline),value,HORIZONTAL_ALIGNMENT_LEFT,-1,sz,tint)

func _icon(id: String, center: Vector2, width: float, alpha: float=1.0) -> void:
	var texture: Texture2D = ICONS[id]
	draw_texture_rect(texture,Rect2(center-Vector2.ONE*width*0.5,Vector2.ONE*width),
		false,Color(1.0,1.0,1.0,alpha))

func _orb(center: Vector2, radius: float, index: int, alpha: float=1.0, squish: Vector2=Vector2.ONE) -> void:
	var skin_id: String = game.preview_skin if not game.preview_skin.is_empty() else game.shop.equipped_skin
	var authored: Texture2D = SkinArt.sprite_for(skin_id,index)
	if authored == null:
		# Unknown IDs are handled safely; every catalog skin is explicitly authored.
		authored = ORBS[clampi(index,0,2)]
	var diameter: Vector2 = Vector2(radius*2.32*squish.x,radius*2.32*squish.y)
	draw_texture_rect(authored,Rect2(center-diameter*0.5,diameter),false,Color(1,1,1,alpha))

func _button(rect: Rect2, fill: Color, base: Color, pressed: bool=false) -> void:
	var push: float = 6.0 if pressed else 0.0
	_round(rect.translated(Vector2(0,11)),base,28)
	_round(rect.translated(Vector2(0,push)),fill,28,Color("#FFFFFF",0.17),2)
	_round(Rect2(rect.position+Vector2(19,10+push),Vector2(rect.size.x-38,12)),
		Color("#FFFFFF",0.14),7)

func _draw() -> void:
	if game == null or game.shop == null:
		return
	draw_rect(Rect2(Vector2.ZERO,size),INK)
	var scale_factor: float = game._scale()
	var at: Vector2 = game._offset()
	draw_set_transform(at,0,Vector2.ONE*scale_factor)
	_draw_world()
	_draw_top()
	_draw_stats()
	var shake: Vector2 = Vector2.ZERO
	if game.shake_time>0:
		var fade: float = game.shake_time/0.18
		shake = Vector2(sin(game.clock*105),cos(game.clock*131))*game.shake_force*fade*fade
	draw_set_transform(at+shake*scale_factor,0,Vector2.ONE*scale_factor)
	_draw_board()
	_draw_fx()
	draw_set_transform(at,0,Vector2.ONE*scale_factor)
	_draw_status()
	_draw_shapes()
	_draw_turns()
	_draw_boosters()
	_draw_drag()
	_draw_aim()
	_draw_feedback()
	if game.phase=="over":
		_draw_game_over()
	if game.settings_open:
		_draw_settings()
	if game.profile_open:
		_draw_profile()
	if game.shop_open:
		_draw_shop()
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

func _draw_world() -> void:
	draw_texture_rect(WORLD,Rect2(Vector2.ZERO,BASE),false)
	# Atmospheric accents are placed on the margins, never under a game token.
	draw_circle(Vector2(694,674),104,Color("#9FA7FF",0.055))
	draw_circle(Vector2(19,1007),98,Color("#FC8AC3",0.045))

func _draw_top() -> void:
	_label("POP",Vector2(27,72).x,72,51,WHITE)
	_label("DROP",145,72,51,PEACH)
	_label("G R A V I T Y",29,104,19,Color("#AFC4E9"))
	var coin_rect: Rect2 = Rect2(296,37,129,55)
	_card(coin_rect,Color("#283762"),26,4)
	draw_circle(Vector2(320,64),19,GOLD)
	_icon("coins",Vector2(320,64),36)
	_center(str(game.shop.coins),382,73,25,WHITE,74)
	var boxes: Array = [Rect2(434,37,54,55),Rect2(500,37,55,55),
		Rect2(565,37,55,55),Rect2(630,37,58,55)]
	var ids: Array = ["shop","user","settings","globe"]
	for i in range(4):
		_card(boxes[i],Color("#283762"),20,4)
		_icon(str(ids[i]),boxes[i].get_center(),37 if i!=3 else 30)
	_center(game.language.to_upper(),659,89,14,GOLD,53)
	_label("ENERGIA" if game.language=="pl" else "ENERGY",38,135,16,MIST)
	_center("%d / %d" % [game.shop.energy,Shop.MAX_ENERGY],235,136,20,GOLD,83)

func _draw_stats() -> void:
	var score_rect: Rect2 = Rect2(22,143,231,86)
	var wave_rect: Rect2 = Rect2(265,143,274,86)
	var life_rect: Rect2 = Rect2(551,143,147,86)
	_card(score_rect,Color("#27375F"),24,6)
	_card(wave_rect,Color("#27375F"),24,6)
	_card(life_rect,Color("#27375F"),24,6)
	_label(game.t("score"),39,168,17,MIST)
	_center(str(int(round(game.display_score))),125,215,44,WHITE,199)
	_center(game.t("best")+": "+str(game.best),204,167,13,GOLD,88)
	_label("FALA" if game.language=="pl" else "WAVE",284,170,18,MIST)
	_center(str(game.wave_number+1),369,213,41,WHITE,150)
	var timer: int = maxi(0,int(ceil(game.wave_time_left)))
	_center("%02d:%02d" % [int(timer/60),timer%60],476,197,29,
		PEACH if timer<=5 else WHITE,102)
	var full: float = maxf(1.0,Rules.wave_interval(game.wave_number))
	_round(Rect2(415,209,103,9),Color("#516185"),5)
	_round(Rect2(415,209,maxf(5.0,103.0*(1.0-clampf(game.wave_time_left/full,0.0,1.0))),9),
		PEACH if timer<=5 else AQUA,5)
	_center(game.t("life"),624,169,16,MIST,119)
	for i in range(3):
		var pos: Vector2 = Vector2(577+i*45,199)
		_icon("heart",pos,38,1.0 if i<game.lives else 0.19)

func _draw_board() -> void:
	# A jewel box rather than a spreadsheet: soft inlaid wells and 3D tokens.
	var surround: Rect2 = BOARD.grow(15)
	_round(surround.translated(Vector2(0,15)),Color("#080F29",0.48),39)
	_round(surround,Color("#ECF0FF"),39)
	_round(BOARD.grow(5),Color("#222C57"),27)
	var hidden: Dictionary = {}
	if game.animating:
		for movement in game.motion:
			var dest: Vector2 = movement["to"]
			hidden[int(dest.y)*8+int(dest.x)] = true
	var charged: Array = game._charged_cells()
	var hovering: int = game.hover_column if game.phase=="drop" else -1
	for y in range(8):
		for x in range(8):
			var tile: Vector2 = BOARD.position+Vector2(x,y)*CELL
			var tile_rect: Rect2 = Rect2(tile+Vector2(2,2),Vector2(72,72))
			var active: bool = x==hovering
			_round(tile_rect,Color("#42517E") if (x+y)%2==0 else Color("#3C4C7A"),
				15,Color("#96A5DA",0.25),1)
			_round(Rect2(tile_rect.position+Vector2(7,6),Vector2(58,3)),
				Color("#FFFFFF",0.07),2)
			if active:
				_round(tile_rect,Color("#79F0DB",0.23),15,Color("#8BFFE7",0.75),2)
			var center: Vector2 = tile+Vector2(38,38)
			if hidden.has(y*8+x):
				continue
			var value: int = int(game.board[y][x])
			if Rules.is_rock(value):
				_draw_rock(center,value)
			elif value>=0 and value<=2:
				if Vector2i(x,y) in game.flash and game.pop_time>0:
					var progress: float = 1.0-game.pop_time/game.pop_length
					draw_circle(center,31+20*progress,Color("#FFFFFF",0.20*(1-progress)))
					_orb(center,32.4*(1.0+0.23*sin(progress*PI)),value)
				else:
					_orb(center,32.4,value)
				if Vector2i(x,y) in charged:
					draw_arc(center,35.0,-PI*.74,PI*1.22,42,
						Color("#FFF0C0",0.56+0.22*sin(game.clock*4.0)),2.7,true)
	if game.animating:
		var raw: float = clampf(game.motion_time/maxf(.001,game.motion_duration),0,1)
		var easing: float = raw*raw*(3-2*raw) if game.motion_kind=="spin" or game.motion_kind=="roll" else 1-pow(1-raw,3.5)
		for movement in game.motion:
			var point: Vector2 = game._motion_position(movement,easing)
			var center: Vector2 = BOARD.position+(point+Vector2(.5,.5))*CELL
			var value: int = int(movement["color"])
			if Rules.is_rock(value):
				_draw_rock(center,value)
				continue
			var old_point: Vector2 = game._motion_position(movement,maxf(0,easing-.065))
			var from: Vector2 = BOARD.position+(old_point+Vector2(.5,.5))*CELL
			var tint: Color = ORB_COLORS[clampi(value,0,2)]
			draw_line(from,center,Color(tint.r,tint.g,tint.b,.26),18,true)
			var impact: float = clampf((raw-.77)/.23,0,1)
			var squash: float = .11*sin(impact*PI) if game.motion_kind=="drop" or game.motion_kind=="roll" else 0.0
			_orb(center,32.4,value,1.0,Vector2(1+squash,1-squash*.75))
	elif hovering>=0 and game.pieces.size()>0:
		var choice: Array = game.pieces[clampi(game.selected_piece,0,game.pieces.size()-1)]
		var trial: Dictionary = Rules.drop(game.board,choice,hovering)
		if bool(trial.get("valid",false)):
			for movement in trial["motions"]:
				var p: Vector2 = movement["to"]
				var center: Vector2 = BOARD.position+(p+Vector2(.5,.5))*CELL
				_orb(center,32.4,int(movement["color"]),0.52)
		else:
			_round(Rect2(BOARD.position+Vector2(hovering*CELL,0),Vector2(CELL,BOARD.size.y)),
				Color("#FF668F",.18),15)
	var height_used: int = Rules.tallest_column(game.board)
	if height_used>=6:
		draw_line(BOARD.position+Vector2(9,4),BOARD.position+Vector2(599,4),
			Color("#FF718E",.78),4.0,true)

func _draw_rock(center: Vector2, value: int) -> void:
	var hp: int = clampi(value-Rules.ROCK_MIN+1,1,3)
	draw_circle(center+Vector2(0,6),31,Color("#111A3E",.33))
	draw_circle(center,31,Color("#8075AE"))
	draw_circle(center+Vector2(-7,-9),24,Color("#C4B5E5"))
	draw_arc(center,27,-PI*.85,-PI*.13,25,Color("#F6ECFF",.85),5.0,true)
	if hp<=2:
		draw_line(center+Vector2(-12,-16),center+Vector2(7,1),Color("#6B518D"),4.0,true)
		draw_line(center+Vector2(7,1),center+Vector2(-2,19),Color("#6B518D"),3.0,true)
	for i in range(3):
		draw_circle(center+Vector2((i-1)*14,23),4.0,
			GOLD if i<hp else Color("#5D568A"))

func _draw_fx() -> void:
	for ring in game.rings:
		var progress: float = 1.0-float(ring.life)/maxf(.001,float(ring.max))
		var tint: Color = ring.color
		draw_arc(ring.p,19+progress*(57+float(ring.strength)*34),0,TAU,48,
			Color(tint.r,tint.g,tint.b,.67*(1-progress)),4,true)
	for particle in game.fx:
		var fade: float = clampf(float(particle.life)/maxf(.001,float(particle.max)),0,1)
		var tint: Color = particle.color
		if bool(particle.streak):
			var velocity: Vector2 = particle.v.normalized()
			draw_line(particle.p-velocity*16,particle.p+velocity*3,
				Color(tint.r,tint.g,tint.b,fade),4,true)
		else:
			draw_circle(particle.p,float(particle.r)*fade,Color(tint.r,tint.g,tint.b,fade))
	for floater in game.floaters:
		var fade: float = clampf(float(floater.life)/maxf(.001,float(floater.max)),0,1)
		var at: Vector2 = floater.p-Vector2(0,60*(1-fade))
		_center(str(floater.text),at.x,at.y,35,Color("#FFF4CE",fade),166)

func _draw_status() -> void:
	_card(Rect2(27,872,666,48),Color("#293660"),22,5)
	_center("%s %d" % [game.t("move"),game.moves+1],106,904,19,WHITE,169)
	var count: int = mini(int(game.pending_group.get("count",0)),Rules.POP_THRESHOLD)
	for i in range(Rules.POP_THRESHOLD):
		draw_circle(Vector2(261+i*34,896),9.5,ORB_COLORS[clampi(int(game.pending_group.get("color",0)),0,2)] if i<count else Color("#647498"))
	_center("%d / %d" % [count,Rules.POP_THRESHOLD],468,904,20,WHITE,83)
	var used: int = Rules.tallest_column(game.board)
	_round(Rect2(525,894,103,9),Color("#52628B"),5)
	_round(Rect2(525,894,maxf(2,103.0*used/8.0),9),PEACH if used>=6 else AQUA,5)
	_center("%d/8" % used,652,904,18,MIST,68)

func _draw_shapes() -> void:
	_card(Rect2(20,925,680,138),Color("#F1F4FF"),29,9)
	_label("WYBIERZ KSZTAŁT" if game.language=="pl" else "CHOOSE YOUR PIECE",
		37,947,18,INK)
	_center("PRZECIĄGNIJ LUB DOTKNIJ" if game.language=="pl" else "DRAG OR TAP",
		555,947,16,Color("#677796"),251)
	for i in range(game.pieces.size()):
		var rect: Rect2 = game._piece_card_rect(i)
		var selected: bool = i==game.selected_piece
		var fill: Color = Color("#FCE9F1") if selected else Color("#E0E7F7")
		_round(rect.translated(Vector2(0,5)),Color("#7887AE",.17),22)
		_round(rect,fill,22,PEACH if selected else Color("#C7D2EA"),3 if selected else 1)
		draw_circle(rect.position+Vector2(23,22),15,PEACH if selected else Color("#9CAAC9"))
		_center(str(i+1),rect.position.x+23,rect.position.y+28,17,WHITE,28)
		var piece: Array = game.pieces[i]
		var span: Vector2i = game._piece_span(piece)
		var step: float = minf(38,minf(70.0/maxf(1,span.y-1),147.0/maxf(1,span.x-1)))
		var radius: float = minf(20,step*.47)
		var origin: Vector2 = rect.get_center()+Vector2(-float(span.x-1)*step*.5,
			4-float(span.y-1)*step*.5)
		for bead in piece:
			_orb(origin+Vector2(float(bead[0]),float(bead[1]))*step,radius,
				int(bead[2]),0.45 if game.dragging_piece and selected else 1.0)
		if selected:
			draw_circle(rect.position+Vector2(rect.size.x-17,19),5,AQUA)

func _draw_turns() -> void:
	for i in range(2):
		var left: bool = i==0
		var rect: Rect2 = Rect2(29,1086,317,86) if left else Rect2(374,1086,317,86)
		var hue: Color = PEACH if left else AQUA
		var base: Color = Color("#AC326B") if left else Color("#198B95")
		var pressed: bool = game.tap_time>0 and rect.has_point(game.tap_point)
		_button(rect,hue if game.phase=="drop" else Color("#8190AE"),base,pressed)
		var icon_at: Vector2 = rect.position+Vector2(52 if left else 265,43)
		draw_circle(icon_at,33,Color("#FFFFFF",.17))
		_icon("left" if left else "right",icon_at,57)
		var center_x: float = rect.position.x+(199 if left else 116)
		_center("OBRÓĆ" if game.language=="pl" else "ROTATE",
			center_x,rect.position.y+34,21,WHITE,180)
		_center(game.t("left") if left else game.t("right"),
			center_x,rect.position.y+63,28,INK,180)
		var preview: Dictionary = game.preview_left if left else game.preview_right
		var hint: int = int(preview.get("score",0))
		_center("+%d" % hint if hint>0 else "90°",center_x,rect.position.y+80,17,
			Color("#FFF5DB") if hint>0 else Color("#E8FFFF"),157)

func _draw_boosters() -> void:
	var names: Array = ["bomb","magic","reroll"]
	var x_positions: Array = [27,254,481]
	var fills: Array = [Color("#FFE1CF"),Color("#EEE4FF"),Color("#DBF8FC")]
	for i in range(3):
		var id: String = str(names[i])
		var rect: Rect2 = Rect2(x_positions[i],1192,211,66)
		var active: bool = (id=="bomb" and game.bomb_aim) or (id=="magic" and game.magic_aim)
		_round(rect.translated(Vector2(0,5)),Color("#050B2D",.23),20)
		_round(rect,fills[i],20,AQUA if active else WHITE,3 if active else 1)
		draw_circle(rect.position+Vector2(35,33),25,WHITE)
		_icon(id,rect.position+Vector2(35,33),46,1.0 if game.shop.stock(id)>0 else .58)
		_center(game.shop_t(id),rect.position.x+129,rect.position.y+40,19,INK,144)
		draw_circle(rect.position+Vector2(rect.size.x-18,rect.size.y-13),15,INK)
		_center(str(game.shop.stock(id)),rect.end.x-18,rect.end.y-8,17,WHITE,28)

func _draw_drag() -> void:
	if not game.dragging_piece or game.phase!="drop" or game.pieces.is_empty():
		return
	var piece: Array = game.pieces[clampi(game.selected_piece,0,game.pieces.size()-1)]
	var span: Vector2i = game._piece_span(piece)
	var extent: Vector2 = Vector2(span)*CELL
	var origin: Vector2 = game.drag_point-Vector2(extent.x*.5,145+extent.y*.5)
	origin.x = clampf(origin.x,16,704-extent.x)
	origin.y = clampf(origin.y,16,1200-extent.y)
	var okay: bool = game.drag_column>=0 and bool(Rules.drop(game.board,piece,game.drag_column).get("valid",false))
	_round(Rect2(origin-Vector2(9,9),extent+Vector2(18,18)),Color("#EDF9FF",.86),
		29,AQUA if okay else PEACH,2)
	for bead in piece:
		var at: Vector2 = origin+(Vector2(float(bead[0]),float(bead[1]))+Vector2(.5,.5))*CELL
		_orb(at,31,int(bead[2]))

func _draw_aim() -> void:
	if not (game.bomb_aim or game.magic_aim) or game.phase!="drop":
		return
	var hover: Vector2i = game.bomb_hover
	if hover.x>=0:
		var range_x: int = 0 if game.magic_aim else 1
		for y in range(maxi(0,hover.y-range_x),mini(8,hover.y+range_x+1)):
			for x in range(maxi(0,hover.x-range_x),mini(8,hover.x+range_x+1)):
				_round(Rect2(BOARD.position+Vector2(x,y)*CELL+Vector2(3,3),Vector2(70,70)),
					Color("#FEC88D",.36) if game.bomb_aim else Color("#C7A4FF",.36),15)
	_card(Rect2(142,824,436,50),Color("#293660"),19,6)
	_center(game.shop_t("aim") if game.bomb_aim else game.shop_t("magic_aim"),
		360,857,18,WHITE,420)

func _draw_feedback() -> void:
	if game.praise_timer>0 and game.phase!="over":
		var opacity: float = minf(1,game.praise_timer*3)
		var progress: float = clampf((game.praise_length-game.praise_timer)/.28,0,1)
		for i in range(16):
			var a: float = float(i)*TAU/16.0
			var center: Vector2 = Vector2(360,552)+Vector2.from_angle(a)*(135+progress*121)
			draw_circle(center,4+i%3,Color(ORB_COLORS[i%3],opacity*(1-progress*.5)))
		_card(Rect2(129,502,462,116),Color("#F9F4FF",opacity),34,10)
		_center(game.praise,360,566,51,Color("#CB417F",opacity),420)
		if game.chain_depth>1:
			_center("COMBO x%d" % game.chain_depth,360,597,22,Color("#238B96",opacity),280)
	if game.shop_notice_time>0 and not game.shop_open and not game.profile_open:
		_card(Rect2(163,748,394,59),Color("#FCF5F8"),24,6)
		_center(game.shop_notice,360,785,24,Color("#B43A78"),372)
	if game.mission_notice_time>0 and not game.profile_open and not game.shop_open:
		_card(Rect2(145,685,430,63),Color("#FFF0D1"),24,7)
		_center(game.mission_notice,360,725,24,INK,402)
	if game.level_fx_time>0 and not game.profile_open and not game.shop_open:
		_card(Rect2(127,389,466,210),Color("#F7F1FF"),31,9)
		_center("NOWY POZIOM!" if game.language=="pl" else "LEVEL UP!",360,449,32,PEACH,430)
		_center(str(game.level_fx_number),360,557,91,INK,300)

func _overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO,BASE),Color("#071128",.84))

func _window(rect: Rect2, title: String, title_y: float, close: Rect2) -> void:
	_overlay()
	_round(rect.translated(Vector2(0,12)),Color("#070F29",.57),36)
	_round(rect,Color("#F4F5FF"),34)
	_round(Rect2(rect.position+Vector2(17,15),Vector2(rect.size.x-34,5)),Color("#FFFFFF",.86),3)
	_center(title,300,title_y,42,INK,364)
	_round(close,Color("#DBE2F4"),17)
	_center("X",close.get_center().x,close.position.y+35,26,INK,90)

func _draw_game_over() -> void:
	_overlay()
	var rect: Rect2 = Rect2(61,370,598,653)
	_card(rect,Color("#F7F6FF"),36,12)
	for i in range(3):
		_orb(Vector2(268+i*91,486+10*sin(game.clock*2+i)),28,i)
	_center(game.t("over"),360,570,49,INK,520)
	_center(game.t("score"),360,607,20,Color("#667697"),420)
	_center(str(game.score),360,687,82,PEACH,495)
	_center("%s  %d" % [game.t("best"),game.best],360,723,23,Color("#617394"),465)
	var restart: Rect2 = Rect2(104,722,512,84)
	_button(restart,AQUA if game.shop.energy>0 else Color("#B4BFCD"),Color("#188A87"))
	_center(game.t("again") if game.shop.energy>0 else game.shop_t("no_energy"),
		360,773,27,INK,450)
	var ad_ok: bool = game.ads!=null and game.ads.rewarded_ready()
	var allowed: bool = game.revives<1 and not game.pieces.is_empty()
	var ad: Rect2 = Rect2(104,821,244,79)
	var coins: Rect2 = Rect2(372,821,244,79)
	_round(ad,Color("#DCE8F9"),22)
	_round(coins,Color("#FFE1AE") if game.shop.coins>=Shop.RESCUE_PRICE and allowed else Color("#DFE4F0"),22)
	_center("REKLAMA" if game.language=="pl" else "WATCH AD",ad.get_center().x,868,
		21,INK if ad_ok and allowed else Color("#9DAAC0"),217)
	_center("%d • %s" % [Shop.RESCUE_PRICE,"DALEJ" if game.language=="pl" else "CONTINUE"],
		coins.get_center().x,868,20,INK if allowed else Color("#9DAAC0"),222)
	_round(Rect2(221,908,278,54),Color("#DFE8F5"),19)
	var seconds: int = game.shop.energy_seconds_remaining()
	_center("ENERGIA %d/5 • %d MIN" % [game.shop.energy,int(ceil(float(seconds)/60.0))] if game.language=="pl"
		else "ENERGY %d/5 • %d MIN" % [game.shop.energy,int(ceil(float(seconds)/60.0))],
		360,942,18,INK,264)
	_center(game.ad_note if not game.ad_note.is_empty() else
		("JEDEN RATUNEK NA RUNDĘ" if game.language=="pl" else "ONE CONTINUE PER ROUND"),
		360,998,16,Color("#70809D"),520)

func _draw_settings() -> void:
	_window(Rect2(72,342,576,735),
		"USTAWIENIA" if game.language=="pl" else "SETTINGS",415,
		Rect2(476,384,118,54))
	_center("ANALITYKA GRY" if game.language=="pl" else "GAME ANALYTICS",
		360,514,23,Color("#6A7797"),440)
	var opts: Array = [
		[Rect2(120,550,480,80),game.telemetry.opted_in,
			"ANALITYKA: WŁ." if game.language=="pl" else "ANALYTICS: ON",
			"ANALITYKA: WYŁ." if game.language=="pl" else "ANALYTICS: OFF"],
		[Rect2(120,886,480,67),game.feedback.sound_enabled,
			"DŹWIĘKI: WŁ." if game.language=="pl" else "SOUND: ON",
			"DŹWIĘKI: WYŁ." if game.language=="pl" else "SOUND: OFF"],
		[Rect2(120,975,480,67),game.feedback.haptics_enabled,
			"WIBRACJE: WŁ." if game.language=="pl" else "HAPTICS: ON",
			"WIBRACJE: WYŁ." if game.language=="pl" else "HAPTICS: OFF"]
	]
	for row in opts:
		var r: Rect2 = row[0]
		var checked: bool = row[1]
		_round(r,AQUA if checked else Color("#D8DEEB"),22)
		_center(str(row[2]) if checked else str(row[3]),r.get_center().x,
			r.position.y+r.size.y*.62,24,INK,440)
	_round(Rect2(120,654,480,74),Color("#FFE2E9"),22)
	_center("USUŃ DANE LOKALNE" if game.language=="pl" else "CLEAR LOCAL DATA",
		360,703,23,Color("#AD3B68"),430)
	_round(Rect2(120,748,480,68),Color("#E1E7F5"),22)
	_center("PRYWATNOŚĆ REKLAM" if game.language=="pl" else "AD PRIVACY",
		360,791,23,INK,430)
	_center("Analityka jest opcjonalna. Reklamy wymagają osobnej zgody."
		if game.language=="pl" else "Analytics is optional. Ads require separate consent.",
		360,854,17,Color("#7582A1"),520)

func _draw_profile() -> void:
	_window(Rect2(54,224,612,906),game.profile_t("profile"),305,
		Rect2(512,265,120,54))
	_center("%s %d" % [game.profile_t("level"),game.progression.level()],
		360,378,43,PEACH,490)
	_center(game.progression.level_xp_text(),360,413,19,Color("#7886A0"),410)
	_round(Rect2(100,429,520,15),Color("#CBD5EA"),8)
	_round(Rect2(100,429,maxf(4,520.0*game.progression.level_fraction()),15),AQUA,8)
	_center("%s %d • %d/%d" % [game.profile_t("streak"),game.progression.streak,
		game.shop.energy,Shop.MAX_ENERGY],360,485,21,INK,530)
	var tabs: Array = [Rect2(92,526,248,51),Rect2(380,526,248,51)]
	for i in range(2):
		var selected: bool = i==game.profile_tab
		_round(tabs[i],PEACH if selected else Color("#DFE6F5"),17)
		var name: String = game.profile_t("daily") if i==0 else game.shop_t("badges")
		_center(name,tabs[i].get_center().x,559,21,WHITE if selected else INK,228)
	if game.profile_tab==0:
		for i in range(Progression.MISSIONS.size()):
			var mission: Dictionary = Progression.MISSIONS[i]
			var id: String = str(mission["id"])
			var y: float = 599+float(i)*102
			var claimed: bool = bool(game.progression.claimed.get(id,false))
			_round(Rect2(89,y,542,92),Color("#D6F7F0") if claimed else Color("#E5EBF7"),19)
			_label(game.profile_t(id),110,y+34,23,INK)
			var value: int = mini(int(game.progression.daily.get(id,0)),int(mission["target"]))
			_center("%d / %d" % [value,int(mission["target"])],530,y+32,20,
				Color("#1B858A"),154)
			_round(Rect2(111,y+59,497,12),Color("#C2D0E4"),7)
			_round(Rect2(111,y+59,maxf(3,497.0*game.progression.mission_ratio(id)),12),
				AQUA if claimed else PEACH,7)
	else:
		for i in range(6):
			var badge: Dictionary = Progression.ACHIEVEMENTS[game.badge_page*6+i]
			var id: String = str(badge["id"])
			var got: bool = bool(game.progression.unlocked_achievements.get(id,false))
			var col: int = i%2
			var row: int = int(i/2)
			var rect: Rect2 = Rect2(89+col*278,599+row*101,263,91)
			_round(rect,Color("#FFF0CB") if got else Color("#E4EAF5"),19)
			draw_circle(rect.position+Vector2(34,45),21,GOLD if got else Color("#B9C3D5"))
			_center("★" if got else "✦",rect.position.x+34,rect.position.y+52,
				23,INK,37)
			var badge_name: String = id.replace("_"," ").capitalize()
			_center(badge_name,rect.position.x+162,rect.position.y+36,17,INK,184)
			_center("%d/%d • +%d" % [mini(game.progression.achievement_progress(id),
				int(badge["target"])),int(badge["target"]),int(badge["coins"])],
				rect.position.x+162,rect.position.y+67,17,Color("#687B98"),190)
		_round(Rect2(104,911,116,46),Color("#DCE4F2"),15)
		_round(Rect2(500,911,116,46),Color("#DCE4F2"),15)
		_center("<",162,942,26,INK,70)
		_center(">",558,942,26,INK,70)
		_center("%d / 2" % [game.badge_page+1],360,942,19,INK,110)
	_center(game.profile_t("cosmetics"),360,965,23,INK,490)
	for i in range(Progression.SKINS.size()):
		var item: Dictionary = Progression.SKINS[i]
		var id: String = str(item["id"])
		var unlocked: bool = game.progression.level()>=int(item["level"])
		var selected: bool = game.progression.skin==id
		var x: float = 90+float(i)*181
		_round(Rect2(x,975,164,75),Color("#D3F8EF") if selected else Color("#E3E9F6"),
			18,AQUA if selected else Color("#CED8E9"),2)
		_center(game.profile_t(id),x+82,1005,20,INK if unlocked else Color("#99A8BF"),146)
		_center(game.profile_t("selected") if selected else
			("POZ. %d" % [int(item["level"])] if not unlocked else "✓"),
			x+82,1032,16,Color("#198C8A") if selected else Color("#7788A5"),140)
	_center(game.profile_t("autoclaim"),360,1092,16,Color("#8390A8"),530)

func _draw_shop() -> void:
	_window(Rect2(54,225,612,863),game.shop_t("shop"),309,
		Rect2(514,266,120,54))
	draw_circle(Vector2(126,288),27,AQUA)
	_icon("shop",Vector2(126,288),47)
	_round(Rect2(98,338,522,51),Color("#FFF1D2"),20)
	_icon("coins",Vector2(372,363),36)
	_center(game.shop_t("coins"),249,372,21,INK,195)
	_center(str(game.shop.coins),489,372,27,INK,180)
	for i in range(2):
		var rect: Rect2 = Rect2(94,410,251,57) if i==0 else Rect2(375,410,251,57)
		var selected: bool = i==game.shop_tab
		_round(rect,PEACH if selected else Color("#E0E7F4"),19)
		_center(game.shop_t("boosts") if i==0 else game.shop_t("skins"),
			rect.get_center().x,447,22,WHITE if selected else INK,222)
	var items: Array = game._shop_items()
	for i in range(items.size()):
		var id: String = str(items[i])
		var rect: Rect2 = game._shop_card(i)
		var special: bool = id==Shop.SPECIAL_SKIN
		var offer: Dictionary = {"kind":"skin","price":0} if id=="default" or special else Shop.item(id)
		var is_skin: bool = str(offer.get("kind",""))=="skin"
		var owned: bool = (id=="default" or game.shop.owns_skin(id)) if is_skin else false
		var equipped: bool = is_skin and game.shop.equipped_skin==id
		var can_buy: bool = game.shop.can_purchase(id)
		_card(rect,Color("#E9EEFA") if i==0 else Color("#F8EAF2"),24,6)
		var orb_place: Vector2 = rect.position+Vector2(82,85)
		draw_circle(orb_place,61,WHITE)
		if is_skin:
			game.preview_skin=id
			_orb(orb_place,39,0)
			game.preview_skin=""
		else:
			_icon(id,orb_place,95)
		_center("JUICY ORBS" if id=="default" else game.shop_t(id),
			rect.position.x+331,rect.position.y+57,27,INK,345)
		var description: String = game.shop_t(id+"_desc")
		if id=="default":
			description = "BAZOWA • GRATIS" if game.language=="pl" else "BASE • FREE"
		elif special:
			description = "NAGRODA ZA 7 DNI" if game.language=="pl" else "PLAY 7 DAYS TO UNLOCK"
		_center(description,rect.position.x+333,rect.position.y+99,17,Color("#687992"),374)
		var enabled: bool = can_buy or owned
		var action: Rect2 = Rect2(rect.position+Vector2(199,134),Vector2(311,61))
		_button(action,AQUA if enabled else Color("#C7D2E2"),Color("#368E95"))
		var wording: String = game.shop_t("active") if equipped else (
			game.shop_t("equip") if owned else
			("7 DNI" if game.language=="pl" else "DAY 7") if special else
			"%s  %d" % [game.shop_t("buy"),int(offer["price"])])
		_center(wording,action.get_center().x,action.position.y+41,22,
			INK if enabled else Color("#65748B"),284)
		if not is_skin:
			_center(game.shop_t("stock")+": "+str(game.shop.stock(id)),
				rect.position.x+82,rect.position.y+180,18,INK,172)
	_round(Rect2(105,970,113,55),Color("#DFE7F5"),16)
	_round(Rect2(502,970,113,55),Color("#DFE7F5"),16)
	_center("<",162,1007,27,INK,85)
	_center(">",558,1007,27,INK,85)
	_center("%s %d / %d" % [game.shop_t("page"),game.shop_page+1,game._shop_pages()],
		360,1007,19,INK,224)
	_center(game.shop_t("tip"),360,1048,18,Color("#677A98"),515)
	if game.shop_notice_time>0:
		_center(game.shop_notice,360,1074,20,PEACH,500)
