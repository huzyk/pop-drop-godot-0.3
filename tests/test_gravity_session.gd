extends SceneTree
const Session = preload("res://scripts/gravity_session.gd")
const Game = preload("res://scripts/gravity_game.gd")

func _initialize() -> void:
	# Importing Game also parses all its core dependencies.
	var instance = Game.new()
	assert(instance != null)
	instance.free()
	var board: Array = []
	for y in range(8):
		var row: Array = []
		for x in range(8):
			row.append(-1)
		board.append(row)
	board[7][1] = 0
	var piece: Array = [[0,0,0],[1,0,1]]
	var original: Dictionary = {
		"board":board,"pieces":[piece.duplicate(true),piece.duplicate(true),piece.duplicate(true)],
		"phase":"drop","score":320,"moves":2,"lives":2,"revives":0
	}
	assert(Session.valid(original))
	var invalid: Dictionary = original.duplicate(true)
	invalid["board"][7][1] = 99
	assert(not Session.valid(invalid))
	invalid = original.duplicate(true)
	invalid["lives"] = 17
	assert(not Session.valid(invalid))
	# Preserve any local player state when this is run on a development machine.
	var existed: bool = FileAccess.file_exists(Session.PATH)
	var previous: String = FileAccess.get_file_as_string(Session.PATH) if existed else ""
	assert(Session.write_progress(original))
	var loaded: Dictionary = Session.read_progress()
	assert(loaded.size() > 0)
	assert(int(loaded["score"]) == 320)
	assert(int(loaded["lives"]) == 2)
	assert(int(loaded["board"][7][1]) == 0)
	if existed:
		var file: FileAccess = FileAccess.open(Session.PATH,FileAccess.WRITE)
		assert(file != null)
		file.store_string(previous)
		file.close()
	else:
		Session.clear_progress()
	print("PASS: Gravity scene dependencies parse and stable checkpoint round-trips")
	quit()
