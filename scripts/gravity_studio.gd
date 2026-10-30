extends Control
## POP DROP / Studio v4 — unified midnight jelly arcade.
## Model, economy, touch bounds and persistence stay in gravity_game.gd.
## All live game art is painted here, never in the gameplay script.
const Rules = preload("res://scripts/gravity_rules.gd")
const Shop = preload("res://scripts/gravity_shop.gd")
const SkinArt = preload("res://scripts/gravity_skin_art.gd")
const Progression = preload("res://scripts/gravity_progression.gd")
const WORLD = preload("res://assets/atelier_v6/world.svg")
const TURN_PINK = preload("res://assets/atelier_v6/turn_left.svg")
const TURN_TEAL = preload("res://assets/atelier_v6/turn_right.svg")
const BOARD_SHELL = preload("res://assets/atelier_v6/board.svg")
const SOCKET = preload("res://assets/atelier_v6/socket.svg")
const PIECE_ACTIVE = preload("res://assets/atelier_v6/piece_active.svg")
const PIECE_IDLE = preload("res://assets/atelier_v6/piece_idle.svg")
const BOOST_ART = [
	preload("res://assets/atelier_v6/boost_bomb.svg"),
	preload("res://assets/atelier_v6/boost_magic.svg"),
	preload("res://assets/atelier_v6/boost_reroll.svg")
]
const ORBS = [
	preload("res://assets/atelier_v6/orb_coral.svg"),
	preload("res://assets/atelier_v6/orb_mint.svg"),
	preload("res://assets/atelier_v6/orb_violet.svg")
]
const HUD_ART = preload("res://assets/atelier_v6/hud.svg")
const STATUS_ART = preload("res://assets/atelier_v6/status.svg")
const COIN_CHIP = preload("res://assets/atelier_v6/coin_chip.svg")
const UTILITY_ART = preload("res://assets/atelier_v6/utility.svg")
const ENERGY_ON = preload("res://assets/atelier_v6/energy_on.svg")
const ENERGY_OFF = preload("res://assets/atelier_v6/energy_off.svg")
const CTA_MINT = preload("res://assets/atelier_v6/cta_mint.svg")
const CTA_MUTED = preload("res://assets/atelier_v6/cta_muted.svg")
const ROCK_ART = preload("res://assets/atelier_v6/rock.svg")
const PANEL_ART = preload("res://assets/atelier_v6/panel.svg")
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
const PEACH := Color("#FA7A72")
const AQUA := Color("#65DDBF")
const VIOLET := Color("#B3A1FB")
const GOLD := Color("#EFA75E")
const INK := Color("#26364D")
const WHITE := Color("#FFFFFF")
const MIST := Color("#846E76")
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

func _moved(rect: Rect2, distance: Vector2) -> Rect2:
	return Rect2(rect.position+distance,rect.size)

func _nine_panel(rect: Rect2, tint: Color, radius: float=27.0) -> void:
	# Author-designed material with 9-slice stretching: round corners never become rectangles.
	var c: float = minf(radius,minf(rect.size.x,rect.size.y)*.46)
	var src: Array = [0.0,64.0,192.0,256.0]
	var dx: Array = [rect.position.x,rect.position.x+c,rect.end.x-c,rect.end.x]
	var dy: Array = [rect.position.y,rect.position.y+c,rect.end.y-c,rect.end.y]
	for y in range(3):
		for x in range(3):
			var to_rect: Rect2 = Rect2(
				Vector2(float(dx[x]),float(dy[y])),
				Vector2(float(dx[x+1])-float(dx[x]),float(dy[y+1])-float(dy[y])))
			var from_rect: Rect2 = Rect2(
				Vector2(float(src[x]),float(src[y])),
				Vector2(float(src[x+1])-float(src[x]),float(src[y+1])-float(src[y])))
			draw_texture_rect_region(PANEL_ART,to_rect,from_rect,tint)

func _round(rect: Rect2, color: Color, radius: int=18, stroke: Color=Color.TRANSPARENT, stroke_width: int=0) -> void:
	# Large opaque controls use authored nine-sliced artwork; only micro geometry stays procedural.
	if stroke_width==0 and radius>=15 and rect.size.x>=70 and rect.size.y>=42 and color.a>=.83:
		_nine_panel(rect,color,float(radius))
		return
	# Explicit radius: no automatic pill conversion of large cards or sheets.
	var smooth: int = maxi(0,radius)
	var key: String = "%s|%d|%s|%d" % [color.to_html(true),smooth,stroke.to_html(true),stroke_width]
	if not styles.has(key):
		var s: StyleBoxFlat = StyleBoxFlat.new()
		s.bg_color = color
		s.set_corner_radius_all(smooth)
		s.anti_aliasing = true
		s.anti_aliasing_size = 2.0
		if stroke_width>0:
			s.border_color = stroke
			s.set_border_width_all(stroke_width)
		styles[key] = s
	draw_style_box(styles[key],rect)

func _card(rect: Rect2, color: Color, radius: int=23, _lift: int=7) -> void:
	_nine_panel(rect,color,float(radius))

func _bubble(center: Vector2, radius: float, fill: Color, edge: Color, shadow: bool=true) -> void:
	if shadow:
		draw_circle(center+Vector2(0,5),radius+2,Color("#07102F",0.23))
	draw_circle(center,radius,fill)
	draw_arc(center,radius-2,-PI*0.93,-PI*0.20,32,edge,3.3,true)

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

func _button(rect: Rect2, fill: Color, _base: Color, pressed: bool=false) -> void:
	# A complete, authored glossy sprite — no procedural rectangle stack.
	var art: Texture2D = CTA_MINT if fill == AQUA else CTA_MUTED
	var down: Vector2 = Vector2(0,5) if pressed else Vector2.ZERO
	draw_texture_rect(art,Rect2(rect.position+down,rect.size),false)

func _draw() -> void:
	if game == null or game.shop == null:
		return
	draw_rect(Rect2(Vector2.ZERO,size),Color("#FFF1E3"))
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
		_draw_top()
	if game.settings_open:
		_draw_settings()
	if game.profile_open:
		_draw_profile()
	if game.shop_open:
		_draw_shop()
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)

func _draw_world() -> void:
	draw_texture_rect(WORLD,Rect2(Vector2.ZERO,BASE),false)

func _draw_top() -> void:
	# New warm, high-contrast title hierarchy.
	_label("POP",29,73,52,INK)
	_label("DROP",148,73,52,Color("#F57173"))
	_label("G R A V I T Y",34,100,15,Color("#9B6A6B"))
	var coin_rect: Rect2 = Rect2(292,35,125,51)
	draw_texture_rect(COIN_CHIP,coin_rect.grow(3),false)
	_icon("coins",Vector2(320,60),34)
	_center(str(game.shop.coins),380,69,24,INK,65)
	var boxes: Array = [Rect2(430,35,54,54),Rect2(498,35,54,54),
		Rect2(566,35,54,54),Rect2(634,35,54,54)]
	var ids: Array = ["shop","user","settings","globe"]
	for i in range(4):
		draw_texture_rect(UTILITY_ART,boxes[i].grow(3),false)
		_icon(str(ids[i]),boxes[i].get_center(),34 if i!=3 else 29)
	_center(game.language.to_upper(),662,93,13,INK,54)
	_label("ENERGIA" if game.language=="pl" else "ENERGY",37,126,15,Color("#9B6A6B"))
	for i in range(Shop.MAX_ENERGY):
		var p: Vector2 = Vector2(137+i*27,120)
		var art: Texture2D = ENERGY_ON if i<game.shop.energy else ENERGY_OFF
		draw_texture_rect(art,Rect2(p-Vector2(11,11),Vector2(22,22)),false)
	_center("%d/%d" % [game.shop.energy,Shop.MAX_ENERGY],305,127,16,INK,73)

func _draw_stats() -> void:
	draw_texture_rect(HUD_ART,Rect2(24,144,672,83),false)
	_label(game.t("score"),53,169,16,Color("#9C777B"))
	_center(str(int(round(game.display_score))),123,214,48,INK,185)
	_center(game.t("best")+": "+str(game.best),179,171,14,Color("#A37A75"),83)
	_label("FALA" if game.language=="pl" else "WAVE",253,169,16,Color("#9C777B"))
	_center(str(game.wave_number+1),293,211,42,INK,98)
	var timer: int = maxi(0,int(ceil(game.wave_time_left)))
	_center("%02d:%02d" % [int(timer/60),timer%60],437,210,37,
		Color("#DE6276") if timer<=5 else INK,132)
	var full: float = maxf(1.0,Rules.wave_interval(game.wave_number))
	_round(Rect2(366,217,132,4),Color("#F1D8CC"),2)
	_round(Rect2(366,217,maxf(4.0,132.0*(1.0-clampf(game.wave_time_left/full,0.0,1.0))),4),
		PEACH if timer<=5 else AQUA,2)
	_center(game.t("life"),604,169,16,Color("#9C777B"),147)
	for i in range(3):
		_icon("heart",Vector2(554+i*48,198),40,1.0 if i<game.lives else .22)

func _draw_board() -> void:
	# A jewel box rather than a spreadsheet: soft inlaid wells and 3D tokens.
	# Freeform, molded frame aligned with the 608px gameplay grid.
	draw_texture_rect(BOARD_SHELL,BOARD.grow(24),false)
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
			var center: Vector2 = tile+Vector2(38,38)

			# One individually designed soft-well asset per cell; no runtime circles.
			draw_texture_rect(SOCKET,Rect2(center-Vector2(20,20),Vector2(40,40)),false)
			if x==hovering:
				draw_circle(center,32.0,Color("#D5FFF0",0.20))
				draw_arc(center,33.0,0.0,TAU,48,Color("#C7FFEC",0.72),3.0,true)
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
	draw_texture_rect(ROCK_ART,Rect2(center-Vector2(36,36),Vector2(72,72)),false)
	for i in range(3):
		var art: Texture2D = ENERGY_ON if i<hp else ENERGY_OFF
		var p: Vector2 = center+Vector2((i-1)*15,24)
		draw_texture_rect(art,Rect2(p-Vector2(5,5),Vector2(10,10)),false)

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
	var r: Rect2 = Rect2(30,872,660,47)
	draw_texture_rect(STATUS_ART,r,false)
	_label("%s %d" % [game.t("move"),game.moves+1],56,902,19,INK)
	var count: int = mini(int(game.pending_group.get("count",0)),Rules.POP_THRESHOLD)
	for i in range(Rules.POP_THRESHOLD):
		var point: Vector2 = Vector2(252+i*33,894)
		var art: Texture2D = ENERGY_ON if i<count else ENERGY_OFF
		draw_texture_rect(art,Rect2(point-Vector2(11,11),Vector2(22,22)),false)
	_center("%d/%d" % [count,Rules.POP_THRESHOLD],455,902,20,INK,77)
	var used: int = Rules.tallest_column(game.board)
	_round(Rect2(536,891,108,8),Color("#E9CFC5"),4)
	_round(Rect2(536,891,maxf(3,108.0*used/8.0),8),PEACH if used>=6 else AQUA,4)
	_center("%d/8" % used,657,902,16,Color("#9E7773"),54)

func _draw_shapes() -> void:
	_label("WYBIERZ KSZTAŁT" if game.language=="pl" else "CHOOSE A PIECE",
		38,947,19,INK)
	_label("PRZECIĄGNIJ NA PLANSZĘ" if game.language=="pl" else "DRAG TO THE BOARD",
		437,947,16,Color("#9A7778"),false)
	for i in range(game.pieces.size()):
		var r: Rect2 = game._piece_card_rect(i)
		var selected: bool = i==game.selected_piece
		var art: Texture2D = PIECE_ACTIVE if selected else PIECE_IDLE
		draw_texture_rect(art,r.grow(4),false)
		# No badge numbers: shapes, not tiny UI decorations, are the focus.
		var piece: Array = game.pieces[i]
		var span: Vector2i = game._piece_span(piece)
		var step: float = minf(42,minf(75.0/maxf(1,span.y-1),150.0/maxf(1,span.x-1)))
		var radius: float = minf(23,step*.48)
		var origin: Vector2 = r.get_center()+Vector2(-float(span.x-1)*step*.5,
			6-float(span.y-1)*step*.5)
		for bead in piece:
			_orb(origin+Vector2(float(bead[0]),float(bead[1]))*step,radius,
				int(bead[2]),0.45 if game.dragging_piece and selected else 1.0)

func _draw_turns() -> void:
	for i in range(2):
		var left: bool = i==0
		var r: Rect2 = Rect2(29,1086,317,86) if left else Rect2(374,1086,317,86)
		var pressed: bool = game.tap_time>0 and r.has_point(game.tap_point)
		var art: Texture2D = TURN_PINK if left else TURN_TEAL
		draw_texture_rect(art,Rect2(r.position+Vector2(0,4 if pressed else 0),r.size),false)
		var icon_at: Vector2 = r.position+Vector2(49,41)
		_icon("left" if left else "right",icon_at,51)
		var label: String = ("OBRÓĆ " if game.language=="pl" else "ROTATE ") + (
			game.t("left") if left else game.t("right"))
		_center(label,r.position.x+201,r.position.y+53,27,INK,219)
		var preview: Dictionary = game.preview_left if left else game.preview_right
		var hint: int = int(preview.get("score",0))
		_center("+%d" % hint if hint>0 else "90°",r.position.x+201,r.position.y+75,17,
			Color("#6E6872"),210)

func _draw_boosters() -> void:
	var names: Array = ["bomb","magic","reroll"]
	var x_positions: Array = [27,254,481]
	for i in range(3):
		var id: String = str(names[i])
		var r: Rect2 = Rect2(x_positions[i],1192,211,66)
		var active: bool = (id=="bomb" and game.bomb_aim) or (id=="magic" and game.magic_aim)
		var art: Texture2D = BOOST_ART[i]
		draw_texture_rect(art,r,false,Color(1,1,1,1.0 if game.shop.stock(id)>0 else .66))
		if active:
			draw_arc(r.get_center(),28,0,TAU,32,Color("#218E86",.6),3,true)
		_icon(id,r.position+Vector2(35,33),42,1.0 if game.shop.stock(id)>0 else .52)
		_center(game.shop_t(id),r.position.x+130,r.position.y+39,18,INK,139)
		var badge_center: Vector2 = r.position+Vector2(r.size.x-18,r.size.y-13)
		draw_texture_rect(UTILITY_ART,Rect2(badge_center-Vector2(15,15),Vector2(30,30)),false)
		_center(str(game.shop.stock(id)),badge_center.x,badge_center.y+6,16,INK,28)

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
	for bead in piece:
		var halo_at: Vector2 = origin+(Vector2(float(bead[0]),float(bead[1]))+Vector2(.5,.5))*CELL
		draw_circle(halo_at,37.0,Color("#92FFEC",0.26) if okay else Color("#FF99BB",0.23))
		draw_arc(halo_at,36.0,0,TAU,36,AQUA if okay else PEACH,2.2,true)
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
	_nine_panel(rect,Color("#F4F3FE"),44.0)
	_center(title,300,title_y,42,INK,364)
	_round(close,Color("#DBE2F4"),17)
	_center("X",close.get_center().x,close.position.y+35,26,INK,90)

func _draw_game_over() -> void:
	_overlay()
	var rect: Rect2 = Rect2(61,370,598,653)
	_card(rect,Color("#F7F6FF"),36,12)
	for i in range(3):
		_orb(Vector2(268+i*91,486+10*sin(game.clock*2+i)),28,i)
	_center(game.t("over"),360,548,49,INK,520)
	_center(game.t("score"),360,582,20,Color("#667697"),420)
	_center(str(game.score),360,664,82,PEACH,495)
	_center("%s  %d" % [game.t("best"),game.best],360,705,23,Color("#617394"),465)
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
