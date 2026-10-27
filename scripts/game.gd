extends Control
## POP DROP / original Godot implementation. All adverts are explicitly a TEST mode.
const Rules = preload("res://scripts/rules.gd")
const FONT = preload("res://fonts/ClearSans-Regular.ttf")
const BOLD = preload("res://fonts/ClearSans-Bold.ttf")
const BASE := Vector2(720,1280)
const BOARD := Rect2(40,286,640,640)
const CELL := 80.0
const COLORS := [Color("#ff749c"),Color("#57d7aa"),Color("#67aafb"),Color("#ffc76c")]
const BOOSTERS := ["bomb","spin","hammer","rainbow","laser","undo","star"]
const LOCALES := ["pl","en","es","pt","de","fr","ru"]
const LANGUAGE_LABELS := ["Polski","English","Español","Português BR","Deutsch","Français","Русский"]
const SAVE_FILE := "user://pop_drop_save.json"

var board: Array = []
var tray: Array = []
var rng := RandomNumberGenerator.new()
var translations: Dictionary = {}
var language := "en"
var selected_slot := 0
var score := 0
var best_clean := 0
var best_assisted := 0
var lives := 3
var revives := 0
var played := 0
var modal := ""
var reward_kind := ""
var targeting := ""
var charges: Dictionary = {"bomb":1,"spin":1,"hammer":1,"rainbow":1,"laser":1,"undo":2,"star":1}
var history: Array = []
var star_remaining := 0.0
var praise_time := 0.0
var praise_text := ""
var praise_color := Color.WHITE
var toast_time := 0.0
var toast_text := ""
var particles: Array = []
var regions: Array = []
var down_region := ""
var drag_slot := -1
var pointer := Vector2.ZERO
var down_pointer := Vector2.ZERO
var elapsed := 0.0
var pulse := 0.0
var assist_powers := 0
var style_cache: Dictionary = {}

func _ready() -> void:
 rng.randomize()
 mouse_filter = Control.MOUSE_FILTER_STOP
 var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://localization.json"))
 if parsed is Dictionary:
  translations = parsed
 var detected := OS.get_locale_language().to_lower()
 language = detected if detected in LOCALES else "en"
 _load_save()
 new_game()

func t(key: String) -> String:
 return str(translations.get(language,translations.get("en",{})).get(key,key))

func _load_save() -> void:
 if not FileAccess.file_exists(SAVE_FILE):
  return
 var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_FILE))
 if data is Dictionary:
  best_clean = int(data.get("best_clean",0))
  best_assisted = int(data.get("best_assisted",0))
  var stored_language := str(data.get("language",""))
  if stored_language in LOCALES:
   language = stored_language

func _store_save() -> void:
 var file := FileAccess.open(SAVE_FILE,FileAccess.WRITE)
 if file != null:
  file.store_string(JSON.stringify({"best_clean":best_clean,"best_assisted":best_assisted,"language":language}))

func new_game() -> void:
 board = Rules.empty_board()
 # A gentle, hand-seeded starting position: pairs invite the first easy clears.
 var seeds := [[1,7,0],[2,7,0],[5,7,1],[6,7,1],[3,6,2],[4,6,2],[0,7,1],[7,7,2]]
 for s in seeds:
  board[s[1]][s[0]] = s[2]
 score = 0
 lives = 3
 revives = 0
 played = 0
 assist_powers = 0
 selected_slot = 0
 targeting = ""
 modal = ""
 history.clear()
 particles.clear()
 star_remaining = 0.0
 _refill_tray()
 queue_redraw()

func _refill_tray() -> void:
 tray = Rules.generate_tray(board,rng,3 if played < 36 else 4)
 selected_slot = 0
 _check_stuck()

func _check_stuck() -> void:
 if modal == "gameover":
  return
 for piece in tray:
  if not piece.is_empty() and Rules.any_placement(board,piece):
   return
 _lose_life()

func _lose_life() -> void:
 lives -= 1
 star_remaining = 0.0
 if lives <= 0:
  modal = "gameover"
  _update_record()
 else:
  board = Rules.rescue(board)
  _praise(t("heart_lost"),Color("#ff839d"),1.2)
  if not _any_tray_fit():
   tray = Rules.generate_tray(board,rng,3 if played < 36 else 4)
  selected_slot = 0
 queue_redraw()

func _any_tray_fit() -> bool:
 for piece in tray:
  if not piece.is_empty() and Rules.any_placement(board,piece):
   return true
 return false

func _snapshot() -> void:
 var copy_tray: Array = []
 for p in tray:
  copy_tray.append(p.duplicate(true))
 history.append({"board":Rules.copy_board(board),"tray":copy_tray,"score":score,"played":played,"selected":selected_slot,"lives":lives})
 if history.size() > 8:
  history.pop_front()

func _update_record() -> void:
 if revives == 0:
  best_clean = maxi(best_clean,score)
 else:
  best_assisted = maxi(best_assisted,score)
 _store_save()

func _place(at: Vector2i) -> bool:
 if modal != "" or targeting != "":
  return false
 if selected_slot < 0 or selected_slot >= tray.size():
  return false
 var piece: Array = tray[selected_slot]
 if piece.is_empty():
  return false
 var result: Dictionary = Rules.simulate(board,piece,at,star_remaining > 0.0)
 if not result.valid:
  _toast(t("need_space"))
  return false
 _snapshot()
 board = result.board
 tray[selected_slot] = []
 played += 1
 var removed: int = result.removed
 var chains: int = result.chains
 score += piece.size()*3 + removed * (16 + chains*7) + maxi(0,chains-1)*60
 if removed > 0:
  _spawn_burst(at,removed,chains)
  if chains >= 3 or removed >= 13:
   _praise(t("incredible"),Color("#ffda75"),1.65)
  elif chains >= 2 or removed >= 8:
   _praise(t("amazing"),Color("#ba91ff"),1.35)
  elif removed >= 5:
   _praise(t("great"),Color("#69e3d9"),1.05)
  else:
   _praise(t("pop"),Color("#ffffff"),0.78)
 if tray.all(func(p): return p.is_empty()):
  _refill_tray()
 else:
  for i in range(tray.size()):
   if not tray[i].is_empty():
    selected_slot = i
    break
  _check_stuck()
 _update_record()
 queue_redraw()
 return true

func _praise(message: String, color: Color, seconds: float) -> void:
 praise_text = message
 praise_color = color
 praise_time = seconds
 pulse = 0.65

func _toast(message: String) -> void:
 toast_text = message
 toast_time = 1.3

func _spawn_burst(at: Vector2i, amount: int, chains: int) -> void:
 var center := BOARD.position + (Vector2(at)+Vector2(0.5,0.5))*CELL
 for i in range(mini(45,amount*5)):
  var theta := rng.randf_range(0,TAU)
  var velocity := Vector2.from_angle(theta)*rng.randf_range(80,310+chains*30)
  particles.append({"p":center,"v":velocity,"life":rng.randf_range(0.35,0.9),"max":0.9,"c":COLORS[rng.randi_range(0,2)],"r":rng.randf_range(3,8)})

func _process(delta: float) -> void:
 elapsed += delta
 if modal == "" and star_remaining > 0:
  star_remaining = maxf(0.0,star_remaining-delta)
 praise_time = maxf(0.0,praise_time-delta)
 toast_time = maxf(0.0,toast_time-delta)
 pulse = maxf(0.0,pulse-delta*1.9)
 for i in range(particles.size()-1,-1,-1):
  particles[i].p += particles[i].v * delta
  particles[i].v *= maxf(0.0,1.0-2.2*delta)
  particles[i].life -= delta
  if particles[i].life <= 0:
   particles.remove_at(i)
 queue_redraw()

func _scale() -> float:
 return minf(size.x/BASE.x,size.y/BASE.y)

func _offset() -> Vector2:
 return (size-BASE*_scale())*0.5

func _to_logical(pos: Vector2) -> Vector2:
 return (pos-_offset())/_scale()

func _point_cell(pt: Vector2) -> Vector2i:
 if not BOARD.has_point(pt):
  return Vector2i(-1,-1)
 return Vector2i(int(floor((pt.x-BOARD.position.x)/CELL)),int(floor((pt.y-BOARD.position.y)/CELL)))

func _anchor_for_mouse(pt: Vector2, drag: bool) -> Vector2i:
 var point := pt
 if drag:
  point.y -= 96
 var tile := _point_cell(point)
 if tile.x < 0:
  return tile
 # Anchor around the first top-left bead. The ghost shows the exact placement.
 return tile

func _region_at(pos: Vector2) -> String:
 for i in range(regions.size()-1,-1,-1):
  if regions[i].rect.has_point(pos):
   return regions[i].id
 return ""

func _gui_input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
  var pt := _to_logical(event.position)
  if event.pressed:
   pointer = pt
   down_pointer = pt
   down_region = _region_at(pt)
   if modal == "" and down_region.begins_with("piece:"):
    var slot := int(down_region.get_slice(":",1))
    if not tray[slot].is_empty():
     drag_slot = slot
     selected_slot = slot
   queue_redraw()
  else:
   var moved := (pt-down_pointer).length() > 32.0
   if drag_slot >= 0:
    selected_slot = drag_slot
    drag_slot = -1
    if moved:
     var anchor := _anchor_for_mouse(pt,true)
     if anchor.x >= 0:
      _place(anchor)
   elif down_region == "board" and modal == "":
    var target := _point_cell(pt)
    if target.x >= 0:
     if targeting != "":
      _apply_target(target)
     else:
      _place(target)
   else:
    var release_hit := _region_at(pt)
    if release_hit == down_region or down_region.begins_with("locale:"):
     _handle_ui(down_region)
   down_region = ""
   queue_redraw()
 elif event is InputEventMouseMotion and drag_slot >= 0:
  pointer = _to_logical(event.position)
  queue_redraw()

func _handle_ui(id: String) -> void:
 if id == "":
  return
 if id == "pause":
  modal = "pause"
 elif id == "language":
  modal = "language"
 elif id == "close" or id == "resume" or id == "cancel":
  if modal == "reward" and lives <= 0:
   modal = "gameover"
  else:
   modal = ""
 elif id == "restart" or id == "new_game":
  new_game()
 elif id == "finish":
  modal = "gameover"
 elif id == "revive":
  _request_reward("revive")
 elif id == "grant_reward":
  _grant_test_reward()
 elif id.begins_with("locale:"):
  var next := id.get_slice(":",1)
  if next in LOCALES:
   language = next
   _store_save()
   modal = ""
 elif id.begins_with("booster:"):
  _start_booster(id.get_slice(":",1))
 queue_redraw()

func _start_booster(kind: String) -> void:
 if modal != "" or kind not in BOOSTERS:
  return
 if int(charges.get(kind,0)) <= 0:
  _request_reward(kind)
  return
 targeting = ""
 if kind == "spin":
  charges[kind] -= 1
  tray = Rules.generate_tray(board,rng,3 if played < 36 else 4)
  selected_slot = 0
  _praise("SPIN!",Color("#64dcfc"),1.0)
  _check_stuck()
 elif kind == "undo":
  if history.is_empty():
   _toast("UNDO")
   return
  charges[kind] -= 1
  var old: Dictionary = history.pop_back()
  board = Rules.copy_board(old.board)
  tray = old.tray
  score = old.score
  played = old.played
  lives = old.lives
  selected_slot = old.selected
  _praise("UNDO",Color("#a7e6fb"),0.8)
 elif kind == "star":
  charges[kind] -= 1
  star_remaining = 15.0
  targeting = ""
  _praise(t("star_active"),Color("#ffcd62"),1.3)
 else:
  targeting = kind
  _toast(t("choose_color") if kind == "rainbow" else t("use_tile"))

func _apply_target(at: Vector2i) -> void:
 var kind := targeting
 if kind == "" or charges.get(kind,0) <= 0:
  return
 if kind == "hammer" and board[at.y][at.x] == -1:
  return
 if kind == "rainbow" and board[at.y][at.x] == -1:
  return
 var remove := {}
 if kind == "bomb":
  for y in range(maxi(0,at.y-1),mini(8,at.y+2)):
   for x in range(maxi(0,at.x-1),mini(8,at.x+2)):
    remove[y*8+x] = Vector2i(x,y)
 elif kind == "laser":
  for k in range(8):
   remove[at.y*8+k] = Vector2i(k,at.y)
   remove[k*8+at.x] = Vector2i(at.x,k)
 elif kind == "hammer":
  remove[at.y*8+at.x] = at
 elif kind == "rainbow":
  var c: int = board[at.y][at.x]
  for y in range(8):
   for x in range(8):
    if board[y][x] == c:
     remove[y*8+x] = Vector2i(x,y)
 var count := 0
 for p in remove.values():
  if board[p.y][p.x] != -1:
   count += 1
 # Never consume a booster when the selected area contains no bubbles.
 if count == 0:
  _toast(t("use_tile"))
  return
 charges[kind] -= 1
 targeting = ""
 for p in remove.values():
  board[p.y][p.x] = -1
 var follow: Dictionary = Rules.resolve_after_booster(board)
 board = follow.board
 count += int(follow.removed)
 if count > 0:
  score += count*15
  _spawn_burst(at,count,int(follow.chains)+1)
  _praise(t("great") if count < 7 else t("amazing"),Color("#f6d382"),1.0)
 if not _any_tray_fit():
  _check_stuck()
 _update_record()

func _request_reward(kind: String) -> void:
 reward_kind = kind
 modal = "reward"

func _grant_test_reward() -> void:
 # DEMO ONLY. In release, call this method ONLY from an AdMob earned-reward callback.
 var kind := reward_kind
 modal = ""
 if kind == "revive":
  revives += 1
  lives = 1
  board = Rules.rescue(board)
  if not _any_tray_fit():
   tray = Rules.generate_tray(board,rng,3 if played < 36 else 4)
  selected_slot = 0
  _praise("+1 ♥",Color("#ff819e"),1.3)
 else:
  charges[kind] = int(charges.get(kind,0))+1
  _start_booster(kind)
 _update_record()
 queue_redraw()

func _hit(id: String, rect: Rect2) -> void:
 regions.append({"id":id,"rect":rect})

func _box(rect: Rect2, color: Color, radius: int=16, border: Color = Color.TRANSPARENT, border_width: int=0) -> void:
 var key := "%s|%s|%s|%s" % [color.to_html(true), radius, border.to_html(true), border_width]
 if not style_cache.has(key):
  var sb := StyleBoxFlat.new()
  sb.bg_color = color
  sb.set_corner_radius_all(radius)
  if border_width > 0:
   sb.border_color = border
   sb.set_border_width_all(border_width)
  style_cache[key] = sb
 draw_style_box(style_cache[key],rect)

func _text(label: String, x: float, baseline: float, pt: int, color: Color, align: HorizontalAlignment=HORIZONTAL_ALIGNMENT_LEFT, font: Font=BOLD, width: float=-1) -> void:
 draw_string(font,Vector2(x,baseline),label,align,width,pt,color)

func _ball(center: Vector2, radius: float, color_idx: int, dim: bool=false) -> void:
 var c: Color = COLORS[clampi(color_idx,0,COLORS.size()-1)]
 if dim:
  c = c.darkened(0.52)
 draw_circle(center+Vector2(0,radius*0.15),radius+3,Color(0,0,0,0.22))
 draw_circle(center,radius,c.darkened(0.24))
 draw_circle(center-Vector2(0,2),radius-3,c)
 draw_circle(center+Vector2(-radius*0.32,-radius*0.39),radius*0.27,Color(1,1,1,0.32))
 draw_arc(center-Vector2(0,2),radius-4,0.28,2.88,16,Color(1,1,1,0.19),3.5,true)

func _background() -> void:
 draw_rect(Rect2(Vector2.ZERO,size),Color("#0a1128"))
 draw_set_transform(_offset(),0,Vector2.ONE*_scale())
 draw_rect(Rect2(0,0,720,1280),Color("#101b3c"))
 draw_circle(Vector2(100,220),340,Color("#332563",0.3))
 draw_circle(Vector2(655,815),310,Color("#123c65",0.25))
 draw_circle(Vector2(390,1180),260,Color("#37275c",0.25))
 for i in range(36):
  var xx := float((i*127+51)%700)+10.0
  var yy := float((i*197+81)%1260)+10.0
  draw_circle(Vector2(xx,yy),2.0 if i%5 == 0 else 1.3,Color(1,1,1,0.12))

func _draw() -> void:
 regions.clear()
 _background()
 _draw_hud()
 _draw_board()
 _draw_tray()
 _draw_boosters()
 _draw_fx()
 if modal != "":
  _draw_modal()
 draw_set_transform(Vector2.ZERO)

func _draw_hud() -> void:
 _box(Rect2(40,34,640,94),Color("#19294f",0.95),26,Color("#42527a",0.6),2)
 _text("POP",73,103,55,Color("#ffffff"))
 _text("DROP",205,103,55,Color("#6ee1d3"))
 _box(Rect2(502,58,94,44),Color("#263e68"),22)
 _text(language.to_upper(),549,87,20,Color("#ffffff"),HORIZONTAL_ALIGNMENT_CENTER,BOLD,84)
 _hit("language",Rect2(502,48,94,70))
 _box(Rect2(607,58,55,44),Color("#263e68"),22)
 _text("II",634,88,23,Color("#ffffff"),HORIZONTAL_ALIGNMENT_CENTER,BOLD,40)
 _hit("pause",Rect2(600,48,68,70))
 _box(Rect2(40,146,308,114),Color("#18294a"),22)
 _box(Rect2(366,146,314,114),Color("#18294a"),22)
 _text(t("score"),65,184,17,Color("#9fb3de"))
 _text(_digits(score),65,237,43,Color("#ffffff"))
 _text(t("best"),391,184,17,Color("#9fb3de"))
 _text(_digits(maxi(best_clean,best_assisted)),391,237,43,Color("#ffda7a"))
 for i in range(3):
  var xx := 570+i*33
  _text("♥",xx,180,25,Color("#ff688d") if i<lives else Color("#4a5671"))

func _digits(value: int) -> String:
 var s := str(value)
 var output := ""
 var k := 0
 for i in range(s.length()-1,-1,-1):
  output = s[i] + output
  k += 1
  if k%3 == 0 and i>0:
   output = " " + output
 return output

func _draw_board() -> void:
 _box(Rect2(24,270,672,672),Color("#23345e"),28,Color("#435881",0.65),2)
 for y in range(8):
  for x in range(8):
   var p := BOARD.position+Vector2(x,y)*CELL
   var rect := Rect2(p+Vector2(3,3),Vector2(CELL-6,CELL-6))
   _box(rect,Color("#19284c") if (x+y)%2==0 else Color("#1c2d54"),12)
   if board[y][x] != -1:
    _ball(p+Vector2(40,40),30,int(board[y][x]))
 _hit("board",BOARD)
 if targeting != "":
  _box(BOARD,Color("#a9e3ff",0.08),22,Color("#b1e8ff",0.6),3)
 if drag_slot >= 0 and modal == "":
  var at := _anchor_for_mouse(pointer,true)
  if at.x >= 0 and drag_slot < tray.size():
   var piece: Array = tray[drag_slot]
   var valid: bool = Rules.can_place(board,piece,at)
   for bead in piece:
    var x: int = at.x+bead[0]
    var y: int = at.y+bead[1]
    if x >= 0 and x < 8 and y >= 0 and y < 8:
     var dest := BOARD.position+Vector2(x+0.5,y+0.5)*CELL
     draw_circle(dest,36,Color(0.26,1.0,0.75,0.24) if valid else Color(1.0,0.2,0.4,0.25))
     _ball(dest,27,int(bead[2]),not valid)
 if praise_time > 0.0:
  _box(Rect2(155,515,410,116),Color("#111b36",0.84),30)
  _text(praise_text,360,598,48,praise_color,HORIZONTAL_ALIGNMENT_CENTER,BOLD,390)
 if toast_time > 0.0:
  _box(Rect2(145,803,430,72),Color("#172444",0.95),20)
  _text(toast_text,360,851,25,Color("#f5f6ff"),HORIZONTAL_ALIGNMENT_CENTER,BOLD,412)
 if star_remaining > 0.0:
  _box(Rect2(175,259,370,36),Color("#ffb83d"),18)
  _text("%s  %d s" % [t("star_active"),ceili(star_remaining)],360,283,18,Color("#322442"),HORIZONTAL_ALIGNMENT_CENTER,BOLD,348)

func _draw_tray() -> void:
 _text(t("pieces"),360,973,18,Color("#c4d2f1"),HORIZONTAL_ALIGNMENT_CENTER,BOLD,656)
 for slot in range(3):
  var rect := Rect2(41+slot*218,991,200,107)
  var selected: bool = slot == selected_slot and modal == ""
  _box(rect,Color("#293d6c") if selected else Color("#192a4d"),20,Color("#64dcc8") if selected else Color("#415379"),3 if selected else 1)
  if tray[slot].is_empty():
   _text("OK",rect.get_center().x,1057,28,Color("#536789"),HORIZONTAL_ALIGNMENT_CENTER,BOLD,150)
  else:
   var piece: Array = tray[slot]
   var max_x := 0
   var max_y := 0
   for bead in piece:
    max_x = maxi(max_x,int(bead[0]))
    max_y = maxi(max_y,int(bead[1]))
   var step := 33.0
   var left := rect.get_center().x-(max_x+1)*step/2.0+step/2.0
   var top := rect.get_center().y-(max_y+1)*step/2.0+step/2.0
   for bead in piece:
    _ball(Vector2(left+bead[0]*step,top+bead[1]*step),14.5,int(bead[2]))
  _hit("piece:%d" % slot,rect)

func _booster_symbol(id: String, center: Vector2) -> void:
 var white := Color("#f4f9ff")
 var gold := Color("#ffe28b")
 if id == "bomb":
  draw_circle(center+Vector2(-1,3),13,white)
  draw_line(center+Vector2(6,-9),center+Vector2(12,-18),gold,4,true)
  draw_circle(center+Vector2(14,-19),4,gold)
 elif id == "spin":
  draw_arc(center,15,0.45,5.6,35,white,5,true)
  draw_colored_polygon(PackedVector2Array([center+Vector2(12,-16),center+Vector2(24,-13),center+Vector2(17,-4)]),white)
 elif id == "hammer":
  draw_line(center+Vector2(-9,16),center+Vector2(9,-11),white,7,true)
  draw_line(center+Vector2(-8,-16),center+Vector2(12,-4),gold,11,true)
 elif id == "rainbow":
  for j in range(3):
   draw_arc(center+Vector2(0,12),14+j*6,PI,TAU,24,COLORS[j],5,true)
 elif id == "laser":
  draw_line(center+Vector2(-21,0),center+Vector2(21,0),gold,6,true)
  draw_line(center+Vector2(0,-20),center+Vector2(0,20),white,6,true)
  draw_circle(center,7,Color("#ff9f6d"))
 elif id == "undo":
  draw_arc(center,15,PI*0.5,PI*1.95,30,white,5,true)
  draw_colored_polygon(PackedVector2Array([center+Vector2(-21,7),center+Vector2(-7,10),center+Vector2(-16,-4)]),white)
 elif id == "star":
  var vertices := PackedVector2Array()
  for i in range(10):
   var rad := 21.0 if i%2 == 0 else 9.0
   var theta := -PI/2.0 + i*PI/5.0
   vertices.append(center+Vector2.from_angle(theta)*rad)
  draw_colored_polygon(vertices,gold)

func _draw_boosters() -> void:
 for i in range(BOOSTERS.size()):
  var id := BOOSTERS[i]
  var x := 28+i*96
  var active: bool = targeting == id or (id == "star" and star_remaining>0)
  _box(Rect2(x,1118,86,109),Color("#2d426e") if active else Color("#1d3055"),20,Color("#ffd772") if active else Color("#364e79"),2)
  draw_circle(Vector2(x+43,1154),26,Color("#624d7e") if i%2==0 else Color("#255979"))
  _booster_symbol(id,Vector2(x+43,1154))
  var label := t(id)
  _text(label,x+43,1204,13,Color("#d3e6f9"),HORIZONTAL_ALIGNMENT_CENTER,BOLD,82)
  _box(Rect2(x+59,1122,24,22),Color("#ffb84b"),10)
  _text(str(charges.get(id,0)),x+71,1139,14,Color("#312642"),HORIZONTAL_ALIGNMENT_CENTER,BOLD,24)
  _hit("booster:"+id,Rect2(x,1112,86,119))
 _text(t("gameplay_tip"),360,1258,19,Color("#8ca8d7"),HORIZONTAL_ALIGNMENT_CENTER,FONT,680)

func _draw_fx() -> void:
 for p in particles:
  var alpha: float = clampf(float(p.life)/float(p.max),0.0,1.0)
  draw_circle(p.p,p.r,Color(p.c.r,p.c.g,p.c.b,alpha))

func _modal_shell(height: float) -> Rect2:
 draw_rect(Rect2(0,0,720,1280),Color(0.02,0.04,0.11,0.79))
 var rect := Rect2(58,640-height*0.5,604,height)
 _box(rect,Color("#1d2d54"),28,Color("#5d6b96"),2)
 return rect

func _button(id: String,rect: Rect2,label: String,primary: bool=false) -> void:
 _box(rect,Color("#ffcb68") if primary else Color("#354c77"),24)
 var c := Color("#322344") if primary else Color("#ffffff")
 _text(label,rect.get_center().x,rect.position.y+rect.size.y*0.5+9,23,c,HORIZONTAL_ALIGNMENT_CENTER,BOLD,rect.size.x-20)
 _hit(id,rect)

func _draw_modal() -> void:
 regions.clear()
 if modal == "pause":
  _modal_shell(448)
  _text(t("paused"),360,510,48,Color.WHITE,HORIZONTAL_ALIGNMENT_CENTER,BOLD,560)
  _button("resume",Rect2(116,558,488,74),t("resume"),true)
  _button("language",Rect2(116,654,488,74),t("language"))
  _button("restart",Rect2(116,750,488,74),t("restart"))
 elif modal == "language":
  _modal_shell(706)
  _text(t("language"),360,380,41,Color.WHITE,HORIZONTAL_ALIGNMENT_CENTER,BOLD,560)
  for i in range(7):
   var rect := Rect2(106,417+i*72,508,58)
   _box(rect,Color("#365481") if LOCALES[i] == language else Color("#263a63"),15)
   _text(LANGUAGE_LABELS[i],360,rect.position.y+38,24,Color.WHITE,HORIZONTAL_ALIGNMENT_CENTER,BOLD,488)
   _hit("locale:"+LOCALES[i],rect)
  _button("close",Rect2(120,951,480,69),t("close"))
 elif modal == "gameover":
  _modal_shell(660)
  _text(t("game_over"),360,443,47,Color.WHITE,HORIZONTAL_ALIGNMENT_CENTER,BOLD,540)
  _text(t("your_score"),360,508,21,Color("#a3b8db"),HORIZONTAL_ALIGNMENT_CENTER,BOLD,530)
  _text(_digits(score),360,577,61,Color("#ffd879"),HORIZONTAL_ALIGNMENT_CENTER,BOLD,530)
  _text("%s: %s" % [t("bests_clean"),_digits(best_clean)],360,618,17,Color("#a8bde4"),HORIZONTAL_ALIGNMENT_CENTER,FONT,535)
  _text("%s: %s" % [t("bests_assisted"),_digits(best_assisted)],360,647,17,Color("#a8bde4"),HORIZONTAL_ALIGNMENT_CENTER,FONT,535)
  _text(t("revive_hint"),360,719,19,Color("#d1ddf5"),HORIZONTAL_ALIGNMENT_CENTER,FONT,535)
  _button("revive",Rect2(114,752,492,84),t("revive"),true)
  _button("new_game",Rect2(114,853,492,74),t("restart"))
  _text(t("free_demo"),360,958,19,Color("#8ea5ce"),HORIZONTAL_ALIGNMENT_CENTER,FONT,520)
 elif modal == "reward":
  _modal_shell(535)
  _text(t("free_demo"),360,487,37,Color("#ffd67c"),HORIZONTAL_ALIGNMENT_CENTER,BOLD,560)
  _text(t("ad_unavailable"),360,549,22,Color.WHITE,HORIZONTAL_ALIGNMENT_CENTER,BOLD,550)
  _text(t("test_note"),360,618,18,Color("#b8c8e8"),HORIZONTAL_ALIGNMENT_CENTER,FONT,534)
  _text(t("revive") if reward_kind == "revive" else t("get_boost"),360,691,26,Color.WHITE,HORIZONTAL_ALIGNMENT_CENTER,BOLD,550)
  _button("grant_reward",Rect2(106,742,508,79),t("test_reward"),true)
  _button("cancel",Rect2(106,842,508,77),t("cancel"))
