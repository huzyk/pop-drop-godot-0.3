extends SceneTree
## Run: godot --headless --path . --script res://tests/drag_selection_test.gd
const Game = preload("res://scripts/gravity_game.gd")
const Rules = preload("res://scripts/gravity_rules.gd")

func _initialize() -> void:
	call_deferred("_exercise")

func _button(pos: Vector2, pressed: bool) -> InputEventMouseButton:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = pos
	return event

func _exercise() -> void:
	var game = Game.new()
	root.add_child(game)
	game.size = Vector2(720,1280)
	assert(game.pieces.size()==3,"Three options must be offered.")
	var first: String = JSON.stringify(game.pieces[0])
	var second: String = JSON.stringify(game.pieces[1])
	var third: Array = game.pieces[2].duplicate(true)
	game._gui_input(_button(Vector2(480,1080),true))
	assert(game.selected_piece==2,"The third card must be selectable.")
	assert(game.dragging_piece,"Pressing a card must lift it.")
	var drag: InputEventMouseMotion = InputEventMouseMotion.new()
	drag.position = Vector2(380,460)
	game._gui_input(drag)
	assert(game.drag_column>=0,"Moving over the board must preview a column.")
	var projected: Dictionary = Rules.drop(game.board,third,game.drag_column)
	assert(projected.valid,"Test placement must be valid.")
	# Cancel without using the shape.
	game._gui_input(_button(Vector2(700,1070),false))
	assert(game.moves==0 and not game.dragging_piece,"Release outside board cancels.")
	assert(JSON.stringify(game.pieces[2])==JSON.stringify(third),"Cancelled piece must remain.")
	# Drag the same card to the board; all other choices must survive.
	game._gui_input(_button(Vector2(480,1080),true))
	game._gui_input(drag)
	game._gui_input(_button(Vector2(380,460),false))
	assert(game.moves==1,"A valid release must commit one move.")
	await create_timer(2.5).timeout
	assert(game.pieces.size()==3,"Using a piece must refill the tray.")
	assert(JSON.stringify(game.pieces[0])==first,"Unselected first option must remain.")
	assert(JSON.stringify(game.pieces[1])==second,"Unselected second option must remain.")
	assert(game.selected_piece==0,"Selection should reset after using a card.")
	# Simple tap selects a card without placing it.
	game._gui_input(_button(Vector2(265,1080),true))
	game._gui_input(_button(Vector2(265,1080),false))
	assert(game.selected_piece==1 and game.moves==1,"Card tap must only select.")
	game.queue_free()
	print("PASS: select any option, preview on drag, cancel, place, refill, tap.")
	quit(0)
