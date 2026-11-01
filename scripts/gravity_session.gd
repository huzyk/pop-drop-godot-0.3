extends RefCounted
## Versioned, validated, atomic checkpoint of a stable Gravity turn.
const PATH := "user://gravity_round_v1.json"
const TMP := "user://gravity_round_v1.tmp"
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
	file.close()
	var status: Error = DirAccess.rename_absolute(
		ProjectSettings.globalize_path(TMP),
		ProjectSettings.globalize_path(PATH)
	)
	if status != OK:
		push_warning("POP DROP: checkpoint rename failed: " + str(status))
		return false
	return true

static func read_progress() -> Dictionary:
	if not FileAccess.file_exists(PATH):
		return {}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if not (value is Dictionary) or not valid(value):
		push_warning("POP DROP: ignoring damaged game checkpoint")
		return {}
	if int(value.get("version", 0)) != VERSION:
		return {}
	return value

static func clear_progress() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))

static func _integer(value: Variant, low: int, high: int) -> bool:
	if typeof(value) not in [TYPE_INT,TYPE_FLOAT]:
		return false
	var n: float = float(value)
	return is_finite(n) and n >= low and n <= high and n == floor(n)

static func valid(s: Dictionary) -> bool:
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

