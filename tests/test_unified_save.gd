extends SceneTree
const Session = preload("res://scripts/gravity_session.gd")
const Shop = preload("res://scripts/gravity_shop.gd")
const Progression = preload("res://scripts/gravity_progression.gd")
const Game = preload("res://scripts/gravity_game.gd")
var preserved: Dictionary = {}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	# Save every touched file before testing real game startup and migration.
	for path in [Session.PATH,Session.BACKUP,Session.TMP,Session.LEGACY_PATH,Shop.PATH,Progression.PATH,Game.SAVE_FILE]:
		preserved[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var legacy_wallet = Shop.new()
	legacy_wallet.credit_bonus("seed",500)
	var legacy_profile = Progression.new()
	legacy_profile.record_drop("old:1")
	var old_wallet: String = FileAccess.get_file_as_string(Shop.PATH)
	var old_profile: String = FileAccess.get_file_as_string(Progression.PATH)
	var game = Game.new()
	root.add_child(game)
	game.set_process(false)
	game.tutorial_open = false
	assert(game.shop.coins == 500)
	assert(game.progression.total_drops == 1)
	assert(not game.shop.persist_enabled and not game.progression.persist_enabled)
	var stable: Dictionary = Session.read_progress()
	assert(stable.wallet.coins == 500)
	assert(stable.profile.total_drops == 1)
	# A callback rewards an unfinished animation: nothing is committed yet.
	game.phase = "anim"
	game.shop.credit_bonus("unfinished",70)
	game.progression.record_drop("unfinished:drop")
	game.score += 320
	game.board[0][0] = 2
	for _frame in range(3):
		await process_frame
	var interrupted: Dictionary = Session.read_progress()
	assert(interrupted.wallet.coins == 500)
	assert(interrupted.profile.total_drops == 1)
	assert(interrupted.score == stable.score)
	assert(interrupted.board == stable.board)
	# Completing the action commits all models together.
	game.phase = "drop"
	game._save_progress()
	var committed: Dictionary = Session.read_progress()
	assert(committed.wallet.coins == 570)
	assert(committed.profile.total_drops == 2)
	assert(committed.score == 320)
	assert(int(committed.board[0][0]) == 2)
	assert(FileAccess.get_file_as_string(Shop.PATH) == old_wallet)
	assert(FileAccess.get_file_as_string(Progression.PATH) == old_profile)
	# Interrupted write is ignored; corrupt primary restores whole previous state.
	var file: FileAccess = FileAccess.open(Session.TMP,FileAccess.WRITE)
	file.store_string("{partial")
	file.close()
	assert(Session.read_progress().wallet.coins == 570)
	file = FileAccess.open(Session.PATH,FileAccess.WRITE)
	file.store_string("{damaged")
	file.close()
	var recovered: Dictionary = Session.read_progress()
	assert(recovered.wallet.coins == 500)
	assert(recovered.score == stable.score)
	assert(recovered.profile.total_drops == 1)
	# Reject partial bundles rather than combining models with legacy files.
	var invalid: Dictionary = committed.duplicate(true)
	invalid.erase("wallet")
	assert(not Session.valid(invalid))
	invalid = committed.duplicate(true)
	invalid.wallet.coins = {}
	assert(not Session.valid(invalid))
	game.queue_free()
	for _frame in range(3):
		await process_frame
	for path in preserved:
		if preserved[path] == null:
			if FileAccess.file_exists(path):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		else:
			file = FileAccess.open(path,FileAccess.WRITE)
			file.store_buffer(preserved[path])
			file.close()
	print("PASS: legacy migration, interrupted action rollback, atomic model commit, backup recovery, no legacy writes")
	quit()
