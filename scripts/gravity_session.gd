extends RefCounted
## Versioned, validated, atomic checkpoint of a stable Gravity turn.
const LEGACY_PATH := "user://gravity_round_v1.json"
const PATH := "user://gravity_state_v2.json"
const BACKUP := "user://gravity_state_v2.bak"
const TMP := "user://gravity_state_v2.tmp"
const VERSION := 1

static func write_progress(state: Dictionary) -> bool:
	if not valid(state):
		push_warning("POP DROP: refused invalid game checkpoint")
		return false
	var data: Dictionary = state.duplicate(true)
	data["version"] = VERSION
	var file: FileAccess = FileAccess.open(TMP, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.flush()
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		return false
	# Keep the previous valid generation. Never back up a damaged primary.
	if not _read_path(PATH).is_empty():
		var backup_error: Error = DirAccess.copy_absolute(
			ProjectSettings.globalize_path(PATH),ProjectSettings.globalize_path(BACKUP))
		if backup_error != OK:
			return false
	var status: Error = DirAccess.rename_absolute(
		ProjectSettings.globalize_path(TMP),
		ProjectSettings.globalize_path(PATH)
	)
	if status != OK:
		push_warning("POP DROP: checkpoint rename failed: " + str(status))
		return false
	return true

static func has_current_storage() -> bool:
	return FileAccess.file_exists(PATH) or FileAccess.file_exists(BACKUP)

static func read_progress() -> Dictionary:
	var current: Dictionary = _read_path(PATH)
	if not current.is_empty():
		return current
	var backup: Dictionary = _read_path(BACKUP)
	if not backup.is_empty():
		push_warning("POP DROP: recovered previous complete save")
		return backup
	# Do not resurrect stale legacy balances after migration if both files fail.
	if FileAccess.file_exists(PATH) or FileAccess.file_exists(BACKUP):
		return {}
	return _read_path(LEGACY_PATH)

static func _read_path(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (value is Dictionary) or not valid(value):
		return {}
	if not _integer(value.get("version"),VERSION,VERSION):
		return {}
	return value

static func clear_progress() -> void:
	for path in [PATH,BACKUP,TMP,LEGACY_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

static func _integer(value: Variant, low: int, high: int) -> bool:
	if typeof(value) not in [TYPE_INT,TYPE_FLOAT]:
		return false
	var n: float = float(value)
	return is_finite(n) and n >= low and n <= high and n == floor(n)

static func _model_valid(data: Variant, numeric: Array, texts: Array, maps: Array, lists: Array) -> bool:
	if not (data is Dictionary) or data.is_empty():
		return false
	for key in numeric:
		if key in data and not _integer(data[key],0,2000000000):
			return false
	for key in texts:
		if key in data and not (data[key] is String):
			return false
	for key in maps:
		if not (data.get(key,{}) is Dictionary):
			return false
		for value in data.get(key,{}).values():
			if typeof(value) not in [TYPE_BOOL,TYPE_INT,TYPE_FLOAT]:
				return false
	for key in lists:
		if not (data.get(key,[]) is Array):
			return false
	return true

static func valid(s: Dictionary) -> bool:
	if s.has("wallet") or s.has("profile") or s.has("meta"):
		if not _model_valid(s.get("wallet"),
			["version","coins","total_earned","total_spent","energy","energy_anchor","daily_streak"],
			["equipped_skin","daily_last_claim"],["inventory","owned_skins","paid_badges"],
			["seen_pop_ids","seen_bonus_ids"]):
			return false
		if not _model_valid(s.get("profile"),
			["version","xp","streak","total_drops","total_pops","total_rounds","best_chain","total_pop_points"],
			["last_play_day","daily_day","skin"],["daily","claimed","unlocked_achievements"],["recent_event_ids"]):
			return false
		if not _model_valid(s.get("meta"),["best","rounds_played"],["language"],[],[]):
			return false
	var grid: Variant = s.get("board")
	var tray: Variant = s.get("pieces")
	if not (grid is Array) or grid.size() != 8:
		return false
	for row in grid:
		if not (row is Array) or row.size() != 8:
			return false
		for bead in row:
			if not _integer(bead,-1,8):
				return false
	if not (tray is Array) or tray.size() != 3:
		return false
	for piece in tray:
		if not (piece is Array) or piece.size() < 1 or piece.size() > 4:
			return false
		var occupied: Dictionary = {}
		for bead in piece:
			if not (bead is Array) or bead.size() != 3:
				return false
			if not _integer(bead[0],0,3) or not _integer(bead[1],0,3) or not _integer(bead[2],0,2):
				return false
			var cell: int = int(bead[1])*4+int(bead[0])
			if occupied.has(cell):
				return false
			occupied[cell] = true
	for key in ["score", "moves", "lives", "revives"]:
		if not _integer(s.get(key),0,1000000000):
			return false
	if int(s.get("lives", -1)) > 3:
		return false
	if str(s.get("phase", "")) not in ["drop", "over"]:
		return false
	# Fields absent in legacy 0.6 checkpoints use safe starting defaults.
	if "loss_reason" in s and not (s["loss_reason"] is String):
		return false
	for key in ["wave_number","action_serial","best_at_start"]:
		if key in s and not _integer(s[key],0,1000000000):
			return false
	if "first_pop_move" in s and not _integer(s["first_pop_move"],-1,1000000000):
		return false
	if "run_id" in s and (not (s["run_id"] is String) or s["run_id"].is_empty()):
		return false
	if "over_reported" in s and not (s["over_reported"] is bool):
		return false
	if "round_active_seconds" in s:
		var elapsed: Variant = s["round_active_seconds"]
		if typeof(elapsed) not in [TYPE_INT,TYPE_FLOAT]:
			return false
		if not is_finite(float(elapsed)) or float(elapsed) < 0.0:
			return false
	if "wave_time_left" in s:
		if typeof(s["wave_time_left"]) not in [TYPE_INT,TYPE_FLOAT]:
			return false
		var remaining: float = float(s["wave_time_left"])
		if not is_finite(remaining) or remaining < 0.0 or remaining > 45.0:
			return false
	if "flow_streak" in s:
		if typeof(s["flow_streak"]) not in [TYPE_INT,TYPE_FLOAT]:
			return false
		if float(s["flow_streak"]) != float(int(s["flow_streak"])):
			return false
		if int(s["flow_streak"]) < 0 or int(s["flow_streak"]) > 4:
			return false
	if "flow_time_left" in s:
		if typeof(s["flow_time_left"]) not in [TYPE_INT,TYPE_FLOAT]:
			return false
		var flow_remaining: float = float(s["flow_time_left"])
		if not is_finite(flow_remaining) or flow_remaining < 0.0 or flow_remaining > 8.0:
			return false
	return true


