extends "res://scripts/gravity_studio.gd"
## Illustrated Edition v7 — the exact commissioned scene as an asset, not a procedural approximation.
## Game rules, analytics, shop, save and event handling are still owned by gravity_game.gd.
## Geometry mirrors the illustration; every gameplay piece is composited dynamically.
const SCENE_ART = preload("res://assets/illustrated_v7/illustrated_scene.webp")
const SELECTED_CARD = preload("res://assets/illustrated_v7/selected_card.png")
const GLASS_PINK = preload("res://assets/illustrated_v7/orb_pink.webp")
const GLASS_GREEN = preload("res://assets/illustrated_v7/orb_green.webp")
const GLASS_BLUE = preload("res://assets/illustrated_v7/orb_blue.webp")
const STONE = preload("res://assets/illustrated_v7/stone.webp")
const TOKENS = [GLASS_PINK,GLASS_GREEN,GLASS_BLUE]
const DARK := Color("#17374D")
const CREAM := Color("#FFF8EA")
const BOARD_LIGHT := Color("#C2FFF4")

func _draw_world() -> void:
	# One artist-made source scene. Textures are imported by Godot and sampled linearly.
	draw_texture_rect(SCENE_ART,Rect2(Vector2.ZERO,BASE),false)

func _draw_top() -> void:
	# The title and shop/profile/settings buttons are already clean high-resolution artwork.
	# Only game data are drawn at runtime; nothing bakes wallet values into the scene.
	_center(str(game.shop.coins),508,51,26,CREAM,87)

func _draw_stats() -> void:
	# Labels and artwork are designed once. These are the live values.
	_center(str(int(round(game.display_score))),131,257,28,CREAM,88)
	_center(str(game.best),256,257,28,CREAM,94)
	_center(str(game.wave_number+1),383,257,28,CREAM,70)
	var seconds: int = maxi(0,int(ceil(game.wave_time_left)))
	_center("%02d:%02d" % [int(seconds/60),seconds%60],513,257,27,CREAM,90)
	# Three illustrated hearts are present in the underlying art. Dim any lost ones.
	for i in range(clampi(game.lives,0,3),3):
		var center: Vector2 = Vector2(600+i*29,246)
		draw_circle(center,13.0,Color("#133D50",0.67))

func _orb(center: Vector2, radius: float, index: int, alpha: float=1.0, squish: Vector2=Vector2.ONE) -> void:
	var skin_id: String = game.preview_skin if not game.preview_skin.is_empty() else game.shop.equipped_skin
	if skin_id != "default":
		super._orb(center,radius,index,alpha,squish)
		return
	var art: Texture2D = TOKENS[clampi(index,0,2)]
	var bounds: Vector2 = Vector2(radius*2.35*squish.x,radius*2.35*squish.y)
	draw_texture_rect(art,Rect2(center-bounds*.5,bounds),false,Color(1,1,1,alpha))

func _draw_rock(center: Vector2, value: int) -> void:
	draw_texture_rect(STONE,Rect2(center-Vector2(39,39),Vector2(78,78)),false)
	var hp: int = clampi(value-Rules.ROCK_MIN+1,1,3)
	if hp<3:
		_center(str(hp),center.x+23,center.y+25,16,CREAM,24)

func _draw_board() -> void:
	# The full illustrated enamel frame and blank 8x8 ceramic grid are in SCENE_ART.
	# Every actual ball/rock comes from the model, so rotation and gravity remain real.
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
	if Rules.tallest_column(game.board)>=6:
		draw_line(BOARD.position+Vector2(7,1),BOARD.position+Vector2(BOARD.size.x-7,1),Color("#FF7887",.92),3.0,true)

func _draw_status() -> void:
	# All status values must be live. The concept art showed two earned stars
	# at the beginning of a run; that was misleading, so no baked trophies here.
	var collected: int = mini(int(game.pending_group.get("count",0)),Rules.POP_THRESHOLD)
	var height_used: int = Rules.tallest_column(game.board)
	_center("GRUPA %d/%d" % [collected,Rules.POP_THRESHOLD] if game.language=="pl" else
		"GROUP %d/%d" % [collected,Rules.POP_THRESHOLD],174,916,20,CREAM,192)
	_center("RUCH %d" % [game.moves+1] if game.language=="pl" else
		"MOVE %d" % [game.moves+1],366,916,20,CREAM,178)
	_center("WYS. %d/8" % height_used if game.language=="pl" else
		"HEIGHT %d/8" % height_used,558,916,19,CREAM,176)

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
			draw_texture_rect(SELECTED_CARD,rect,false)
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
		_center(("Kolejny %d" if game.language=="pl" else "Next %d") % [i+1],rect.get_center().x,rect.end.y-16,18,DARK,170)

func _draw_turns() -> void:
	# Full illustration already provides the smooth, professional rotate arrows and captions.
	# Subtle press feedback is deliberately the only runtime effect here.
	if game.tap_time>0:
		var r: Rect2 = game.LEFT_RECT if game.LEFT_RECT.has_point(game.tap_point) else game.RIGHT_RECT
		if r.has_point(game.tap_point):
			draw_arc(r.get_center(),52,PI*.2,PI*.8,28,Color("#FFFFFF",.65),3.0,true)

func _draw_boosters() -> void:
	var ids: Array = ["bomb","magic","reroll"]
	var centers: Array = [Vector2(283,1115),Vector2(385,1115),Vector2(490,1115)]
	for i in range(3):
		# Repaint the live counter over the number printed in the original concept illustration.
		var count: int = game.shop.stock(str(ids[i]))
		var p: Vector2 = centers[i]
		draw_circle(p,13,Color("#F65358"))
		_center(str(count) if count>0 else "+",p.x,p.y+6,16,CREAM,28)
		if (ids[i]=="bomb" and game.bomb_aim) or (ids[i]=="magic" and game.magic_aim):
			var r: Rect2 = [game.BOOST_BOMB,game.BOOST_MAGIC,game.BOOST_REROLL][i]
			draw_arc(r.get_center(),r.size.x*.48,0,TAU,64,Color("#FFEB94"),4,true)
