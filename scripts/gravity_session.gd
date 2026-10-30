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

static func valid(s: Dictionary) -> bool:
	var grid: Variant = s.get("board")
	var tray: Variant = s.get("pieces")
	if not (grid is Array) or grid.size() != 8:
		return false
	for row in grid:
		if not (row is Array) or row.size() != 8:
			return false
		for bead in row:
			if typeof(bead) != TYPE_FLOAT and typeof(bead) != TYPE_INT:
				return false
			if int(bead) < -1 or int(bead) > 5 or float(bead) != float(int(bead)):
				return false
	if not (tray is Array) or tray.size() != 3:
		return false
	for piece in tray:
		if not (piece is Array) or piece.size() < 1 or piece.size() > 4:
			return false
		for bead in piece:
			if not (bead is Array) or bead.size() != 3:
				return false
			for n in bead:
				if typeof(n) != TYPE_INT and typeof(n) != TYPE_FLOAT:
					return false
			if int(bead[0]) < 0 or int(bead[0]) > 3:
				return false
			if int(bead[1]) < 0 or int(bead[1]) > 3:
				return false
			if int(bead[2]) < 0 or int(bead[2]) > 2:
				return false
	for key in ["score", "moves", "lives", "revives"]:
		var n: int = int(s.get(key, -1))
		if n < 0 or n > 1000000000:
			return false
	if int(s.get("lives", -1)) > 3:
		return false
	if str(s.get("phase", "")) not in ["drop", "over"]:
		return false
	# Fields absent in legacy 0.6 checkpoints use safe starting defaults.
	if "loss_reason" in s and not (s["loss_reason"] is String):
		return false
	if "wave_number" in s:
		if typeof(s["wave_number"]) not in [TYPE_INT,TYPE_FLOAT]:
			return false
		if int(s["wave_number"]) < 0 or int(s["wave_number"]) > 1000000:
			return false
	if "wave_time_left" in s:
		if typeof(s["wave_time_left"]) not in [TYPE_INT,TYPE_FLOAT]:
			return false
		var remaining: float = float(s["wave_time_left"])
		if not is_finite(remaining) or remaining < 0.0 or remaining > 45.0:
			return false
	return true
