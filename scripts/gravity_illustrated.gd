extends "res://scripts/gravity_studio.gd"
## Illustrated v24: authored vector surfaces with live, localized typography.
## Game rules, analytics, shop, save and event handling are still owned by gravity_game.gd.
## Geometry mirrors the illustration; every gameplay piece is composited dynamically.
const SHELL = preload("res://assets/ui/v24/game_shell.svg")
const STONE = preload("res://assets/illustrated_v7/stone.webp")
const DARK := Color("#17374D")
const CREAM := Color("#FFF8EA")
const BOARD_LIGHT := Color("#C2FFF4")

func _draw_world() -> void:
	draw_texture_rect(SHELL,Rect2(Vector2.ZERO,BASE),false)
	if game.shop != null:
		var world_frame: Texture2D = Themes.frame_for_skin(game.shop.equipped_skin)
		if world_frame != null:
			draw_texture_rect(world_frame,Rect2(Vector2.ZERO,BASE),false)

func _draw_top() -> void:
	# Wordmark, buttons and copy are live; there are no Polish labels in art.
	_label("POP",39,89,78,Color("#176F76"))
	_label("POP",36,84,78,Color("#FFBF67"))
	_label("DROP",39,157,78,Color("#176F76"))
	_label("DROP",36,152,78,Color("#2BACA4"))
	_label("GRAVITY",41,181,17,Color("#396A70"))
	_icon("coins",Vector2(439,46),36)
	_center(str(game.shop.coins),513,55,26,CREAM,124)
	for entry in [["shop",game.SHOP_OPEN,game.shop_t("shop")],
		["user",game.PROFILE_OPEN,game.profile_t("profile")],
		["settings",game.SETTINGS_OPEN,game.ui_t("settings")]]:
		var rect: Rect2 = entry[1]
		_icon(str(entry[0]),rect.get_center(),43)
		_center(str(entry[2]),rect.get_center().x,169,13,DARK,86)
	_round(game.LANG_RECT,Color("#E6F5E8"),16,Color("#87CBBE"),1)
	_icon("globe",game.LANG_RECT.position+Vector2(24,20),22)
	_center(game.language_button_text(),game.LANG_RECT.get_center().x+14,182,15,DARK,65)

func _draw_stats() -> void:
	var seconds: int = maxi(0,int(ceil(game.wave_time_left)))
	var labels: Array = [game.t("score"),game.t("best"),game.live_t("wave"),game.live_t("time"),game.live_t("free")]
	var values: Array = [str(int(round(game.display_score))),str(game.best),str(game.wave_number+1),
		"%02d:%02d" % [int(seconds/60),seconds%60],str(64-Rules.filled(game.board))]
	var centers: Array = [126,272,390,498,612]
	for i in range(5):
		_center(str(labels[i]),centers[i],226,13,Color("#BCEBE0"),93)
		_center(str(values[i]),centers[i],254,25,CREAM,129 if i==0 else 92)

func _orb(center: Vector2, radius: float, index: int, alpha: float=1.0, squish: Vector2=Vector2.ONE) -> void:
	var skin_id: String = game.preview_skin if not game.preview_skin.is_empty() else game.shop.equipped_skin
	if skin_id != "default":
		super._orb(center,radius,index,alpha,squish)
		return
	var art: Texture2D = SkinArt.sprite_for("default",index)
	var bounds: Vector2 = Vector2(radius*2.35*squish.x,radius*2.35*squish.y)
	draw_texture_rect(art,Rect2(center-bounds*.5,bounds),false,Color(1,1,1,alpha))
	# Level rewards decorate the base marbles, preserving their gameplay colours.
	if game.progression.skin == "aurora":
		draw_arc(center,radius*.92,-PI*.85,PI*.15,32,Color(.65,1.0,.9,alpha*.8),2.0,true)
	elif game.progression.skin == "starlight":
		var star: Vector2 = center+Vector2(radius*.45,-radius*.45)
		var reach: float = radius*.22
		draw_line(star-Vector2(reach,0),star+Vector2(reach,0),Color(1,.94,.65,alpha),2.0,true)
		draw_line(star-Vector2(0,reach),star+Vector2(0,reach),Color(1,.94,.65,alpha),2.0,true)

func _draw_rock(center: Vector2, value: int) -> void:
	draw_texture_rect(STONE,Rect2(center-Vector2(39,39),Vector2(78,78)),false)
	var hp: int = Rules.rock_health(value)
	if Rules.is_gold_rock(value):
		var breath: float = 0.5+0.5*sin(game.clock*3.5+center.x*.023)
		draw_circle(center,34.0,Color("#F7C75B",.12+breath*.11))
		draw_arc(center,34.8,0,TAU,48,Color("#FFE797",.49+breath*.41),3.0,true)
		draw_circle(center+Vector2(-20,-17),3.4+breath*2.5,Color("#FFF0AC",.75))
	_draw_rock_damage(center,hp)

func _draw_board() -> void:
	# Habitat art overlays the illustrated empty enamel grid, aligned exactly.
	# This is a full board theme, not merely a recolor of the marbles.
	var habitat: Texture2D = Themes.board_for_skin(game.shop.equipped_skin) if game.shop != null else null
	if habitat != null:
		draw_texture_rect(habitat,BOARD,false)
	var hidden: Dictionary = {}
	if game.animating:
		for movement in game.motion:
			var dest: Vector2 = movement["to"]
			hidden[int(dest.y)*8+int(dest.x)] = true
	var charged: Array = game._charged_cells()
	var hovering: int = game.hover_column if game.phase=="drop" else -1
	for y in range(8):
		for x in range(8):
			var center: Vector2 = BOARD.position+(Vector2(x,y)+Vector2(.5,.5))*CELL
			if x==hovering:
				draw_arc(center,CELL*.46,0,TAU,64,Color("#FFFECC",.85),2.5,true)
			if hidden.has(y*8+x):
				continue
			var value: int = int(game.board[y][x])
			if Rules.is_rock(value):
				_draw_rock(center,value)
			elif value>=0 and value<=2:
				if Vector2i(x,y) in game.flash and game.pop_time>0:
					var progress: float = 1.0-game.pop_time/game.pop_length
					_orb(center,CELL*.468*(1+.20*sin(progress*PI)),value)
				else:
					_orb(center,CELL*.468,value)
				if Vector2i(x,y) in charged:
					draw_arc(center,CELL*.445,-PI*.74,PI*1.22,64,
						Color("#FFE98E",.65+.20*sin(game.clock*4.0)),2.4,true)
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
			var impact: float = clampf((raw-.77)/.23,0,1)
			var squash: float = .12*sin(impact*PI) if game.motion_kind=="drop" or game.motion_kind=="roll" else 0.0
			_orb(center,CELL*.468,value,1.0,Vector2(1+squash,1-squash*.75))
	elif hovering>=0 and not game.pieces.is_empty():
		var piece: Array = game.pieces[clampi(game.selected_piece,0,game.pieces.size()-1)]
		var trial: Dictionary = Rules.drop(game.board,piece,hovering)
		if bool(trial.get("valid",false)):
			for movement in trial["motions"]:
				var p: Vector2 = movement["to"]
				var pt: Vector2 = BOARD.position+(p+Vector2(.5,.5))*CELL
				_orb(pt,CELL*.468,int(movement["color"]),0.55)
		else:
			draw_rect(Rect2(BOARD.position+Vector2(hovering*CELL,0),Vector2(CELL,BOARD.size.y)),Color("#F26275",.11))

func _draw_fx() -> void:
	super._draw_fx()
	if game.pop_impact_time <= 0.0:
		return
	var age: float = 1.0-game.pop_impact_time/game.pop_impact_max
	var fade: float = pow(1.0-age,1.8)
	var center: Vector2 = game.pop_impact_at
	var tint: Color = game.pop_impact_color
	var power: float = game.pop_impact_power
	# Fleeting, softly glowing concentric flashes rather than a blocking card.
	draw_circle(center,14.0+age*(42.0+power*12.0),
		Color(tint.r,tint.g,tint.b,0.12*fade))
	draw_arc(center,35.0+age*(94.0+power*17.0),0,TAU,88,
		Color(1.0,0.98,0.87,0.88*fade),4.5,true)
	draw_arc(center,17.0+age*(63.0+power*15.0),0,TAU,72,
		Color(tint.r,tint.g,tint.b,0.72*fade),3.2,true)
	for ray in range(8):
		var direction: Vector2 = Vector2.from_angle(float(ray)*TAU/8.0+0.13)
		var inner: float = 22.0+age*35.0
		var outer: float = inner+(30.0+power*9.0)*(1.0-age)
		draw_line(center+direction*inner,center+direction*outer,
			Color(1.0,0.97,0.80,fade*0.78),3.0,true)

func _draw_status() -> void:
	# All status values must be live. The concept art showed two earned stars
	# at the beginning of a run; that was misleading, so no baked trophies here.
	var collected: int = mini(int(game.pending_group.get("count",0)),Rules.POP_THRESHOLD)
	var free_cells: int = Rules.SIZE*Rules.SIZE-Rules.filled(game.board)
	var surge_next: bool = Rules.wave_is_surge(game.wave_number+1)
	var flow_active: bool = game.flow_streak > 0 and game.flow_time_left > 0.0
	if flow_active:
		# A compact illuminated timer tells players how long they have
		# to extend their chain without covering the board.
		_center("%s x%d" % [game.fx_t("flow"),game.flow_streak],174,910,22,Color("#FFE89D"),192)
		_round(Rect2(99,919,150,5),Color("#134B58"),3)
		_round(Rect2(99,919,maxf(2.0,150.0*game.flow_time_left/game.FLOW_WINDOW),5),
			Color("#79F4C6") if game.flow_streak<3 else Color("#FFCF78"),3)
	elif surge_next and game.phase == "drop":
		var secs: int = maxi(0,int(ceil(game.wave_time_left)))
		_center(game.fx_t("surge")+" %ds" % secs,
			174,916,19,Color("#FFE39A"),192)
	else:
		_center(game.t("charge")+" %d/%d" % [collected,Rules.POP_THRESHOLD],174,916,20,CREAM,192)
	if surge_next and flow_active:
		_center(game.fx_t("surge"),
			366,916,16,Color("#FFE39A"),178)
	else:
		_center(game.t("move")+" %d" % [game.moves+1],366,916,20,CREAM,178)
	_center(game.live_t("free")+" %d" % free_cells,558,916,19,CREAM,176)

# Layout metrics shared by renderer and tests so even tall pieces
# cannot overlap the labels printed at the foot of each card.
static func preview_metrics(span: Vector2i) -> Vector2:
	var step: float = minf(44.0,minf(80.0/maxf(.86,float(span.y)-1.0+.86),
		142.0/maxf(.86,float(span.x)-1.0+.86)))
	return Vector2(step,minf(22.0,step*.43))

func _draw_shapes() -> void:
	for i in range(game.pieces.size()):
		var rect: Rect2 = game._piece_card_rect(i)
		if i == game.selected_piece:
			_round(rect,Color("#EEFFF1"),25,Color("#37B69F"),3)
		var selected: bool = i==game.selected_piece
		# The tactile card itself is part of the commissioned illustration.
		# The selected state is expressed by the live piece rather than drawn outlines.
		var piece: Array = game.pieces[i]
		var span: Vector2i = game._piece_span(piece)
		var metrics: Vector2 = preview_metrics(span)
		var step: float = metrics.x
		var radius: float = metrics.y
		var origin: Vector2 = Vector2(rect.get_center().x,rect.position.y+55)-Vector2(span.x-1,span.y-1)*step*.5
		for bead in piece:
			var center: Vector2 = origin+Vector2(float(bead[0]),float(bead[1]))*step
			_orb(center,radius,int(bead[2]),.45 if selected and game.dragging_piece else 1.0)
		_center(game.live_t("piece") % [i+1],rect.get_center().x,rect.end.y-16,18,DARK,170)

func _draw_turns() -> void:
	for entry in [[game.LEFT_RECT,"left"],[game.RIGHT_RECT,"right"]]:
		var rect: Rect2 = entry[0]
		var pressed: bool = game.tap_time>0 and rect.has_point(game.tap_point)
		_icon(str(entry[1]),rect.get_center()+Vector2(0,-12 if not pressed else -9),64)
		_center(game.t(str(entry[1])),rect.get_center().x,rect.end.y-19,18,CREAM,rect.size.x-12)

func _draw_boosters() -> void:
	# Two large illustrated buttons; old MAGIC art and red badges are hidden by overlay.
	var ids: Array = ["bomb","reroll"]
	var rects: Array = [game.BOOST_BOMB,game.BOOST_REROLL]
	for i in range(ids.size()):
		var id: String = str(ids[i])
		var r: Rect2 = rects[i]
		var count: int = game.shop.stock(id)
		var at: Vector2 = Vector2(r.get_center().x,r.position.y+48)
		_icon(id,at,60,1.0 if count>0 else .65)
		_center(game.shop_t("bomb") if id=="bomb" else game.live_t("swap"),
			r.get_center().x,r.position.y+96,19,DARK,135)
		var badge: Vector2 = Vector2(r.end.x-21,r.position.y+12)
		draw_circle(badge,17,Color("#008E87"))
		draw_arc(badge,17,0,TAU,36,Color("#E3FFF1"),2,true)
		_center(str(count) if count>0 else "+",badge.x,badge.y+6,17,CREAM,30)
		if id=="bomb" and game.bomb_aim:
			draw_arc(at,40,0,TAU,64,Color("#FFF3B3"),4,true)


