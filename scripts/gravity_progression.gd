extends RefCounted
## Offline-only player progression. No login, device identifier, network or ads.
## All progression is cosmetic; neither rewarded ads nor paid purchases give XP.
signal mission_completed(mission_id: String, bonus_xp: int)
signal level_reached(new_level: int)
signal streak_updated(days: int)

const PATH := "user://gravity_profile_v1.json"
const TEMP := "user://gravity_profile_v1.tmp"
const VERSION := 1
const MAX_XP := 200000000
const MISSIONS := [
	{"id":"drops", "target":10, "reward":60},
	{"id":"pops", "target":3, "reward":90},
	{"id":"points", "target":1800, "reward":120}
]
const SKINS := [
	{"id":"classic", "level":1},
	{"id":"aurora", "level":3},
	{"id":"starlight", "level":6}
]

var persist_enabled: bool = true
var xp: int = 0
var last_play_day: String = ""
var streak: int = 0
var daily_day: String = ""
var daily: Dictionary = {"drops":0,"pops":0,"points":0}
var claimed: Dictionary = {"drops":false,"pops":false,"points":false}
var skin: String = "classic"
var total_drops: int = 0
var total_pops: int = 0
var total_rounds: int = 0
var best_chain: int = 0
var recent_event_ids: Array = []

static func xp_to_level(level: int) -> int:
	var n: int = maxi(1, level)
	return 60 * (n - 1) * n

func level() -> int:
	var result: int = 1
	while result < 1000 and xp >= xp_to_level(result + 1):
		result += 1
	return result

func level_fraction() -> float:
	var low: int = xp_to_level(level())
	var high: int = xp_to_level(level() + 1)
	return clampf(float(xp - low) / float(maxi(1, high - low)), 0.0, 1.0)

func level_xp_text() -> String:
	return "%d / %d XP" % [xp-xp_to_level(level()), xp_to_level(level()+1)-xp_to_level(level())]

func skin_unlock_level(skin_id: String) -> int:
	for entry in SKINS:
		if str(entry["id"]) == skin_id:
			return int(entry["level"])
	return 1000000

func select_skin(skin_id: String) -> bool:
	if level() < skin_unlock_level(skin_id):
		return false
	if skin == skin_id:
		return true
	skin = skin_id
	_save()
	return true

func load_data() -> void:
	if FileAccess.file_exists(PATH):
		var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if raw is Dictionary and int(raw.get("version", 0)) == VERSION:
			xp = clampi(int(raw.get("xp", 0)), 0, MAX_XP)
			last_play_day = str(raw.get("last_play_day", ""))
			streak = clampi(int(raw.get("streak", 0)), 0, 100000)
			daily_day = str(raw.get("daily_day", ""))
			var counts: Variant = raw.get("daily", {})
			var flags: Variant = raw.get("claimed", {})
			if counts is Dictionary:
				for mission in MISSIONS:
					var key: String = mission["id"]
					daily[key] = clampi(int(counts.get(key, 0)), 0, 100000000)
			if flags is Dictionary:
				for mission in MISSIONS:
					claimed[mission["id"]] = bool(flags.get(mission["id"], false))
			total_drops = clampi(int(raw.get("total_drops", 0)), 0, 100000000)
			total_pops = clampi(int(raw.get("total_pops", 0)), 0, 100000000)
			total_rounds = clampi(int(raw.get("total_rounds", 0)), 0, 100000000)
			best_chain = clampi(int(raw.get("best_chain", 0)), 0, 20)
			var ids: Variant = raw.get("recent_event_ids", [])
			if ids is Array:
				for value in ids.slice(maxi(0, ids.size()-128)):
					recent_event_ids.append(str(value))
			var selected: String = str(raw.get("skin", "classic"))
			skin = selected if level() >= skin_unlock_level(selected) else "classic"
	ensure_day()

func ensure_day(day_override: String = "") -> void:
	var today: String = day_override if not day_override.is_empty() else Time.get_date_string_from_system(false)
	if daily_day == today:
		return
	daily_day = today
	daily = {"drops":0,"pops":0,"points":0}
	claimed = {"drops":false,"pops":false,"points":false}
	_save()

func record_drop(event_id: String, day_override: String = "") -> void:
	ensure_day(day_override)
	if not _accept_event(event_id):
		return
	_played_today(day_override)
	total_drops = mini(total_drops+1,100000000)
	_grant_xp(2)
	_update_mission("drops",1)
	_save()

func record_pop(event_id: String, groups: int, balls: int, points: int, chain: int, day_override: String = "") -> void:
	ensure_day(day_override)
	if not _accept_event(event_id):
		return
	total_pops = mini(total_pops+maxi(0,groups),100000000)
	best_chain = maxi(best_chain,chain)
	_grant_xp(mini(90, maxi(0,balls)*2 + maxi(0,groups)*5 + maxi(0,chain-1)*5))
	_update_mission("pops",maxi(0,groups))
	_update_mission("points",maxi(0,points))
	_save()

func record_round(event_id: String) -> void:
	if not _accept_event(event_id):
		return
	total_rounds = mini(total_rounds+1,100000000)
	_save()

func mission_ratio(mission_id: String) -> float:
	for mission in MISSIONS:
		if str(mission["id"]) == mission_id:
			return clampf(float(int(daily.get(mission_id,0))) / float(int(mission["target"])),0.0,1.0)
	return 0.0

func _played_today(day_override: String) -> void:
	var today: String = day_override if not day_override.is_empty() else Time.get_date_string_from_system(false)
	if last_play_day == today:
		return
	var gap: int = 0
	if not last_play_day.is_empty():
		var previous: int = int(Time.get_unix_time_from_datetime_string(last_play_day+"T12:00:00"))
		var current: int = int(Time.get_unix_time_from_datetime_string(today+"T12:00:00"))
		gap = int((current - previous) / 86400)
	if gap < 0:
		return
	streak = mini(100000,streak+1) if gap == 1 else 1
	last_play_day = today
	streak_updated.emit(streak)

func _accept_event(event_id: String) -> bool:
	# Durable idempotency: animations/replayed callbacks cannot farm extra XP.
	if event_id.is_empty() or event_id in recent_event_ids:
		return false
	recent_event_ids.append(event_id)
	if recent_event_ids.size() > 128:
		recent_event_ids.pop_front()
	return true

func _update_mission(mission_id: String, amount: int) -> void:
	if amount <= 0 or bool(claimed.get(mission_id, false)):
		return
	var entry: Dictionary = {}
	for mission in MISSIONS:
		if str(mission["id"]) == mission_id:
			entry = mission
			break
	if entry.is_empty():
		return
	var target: int = int(entry["target"])
	daily[mission_id] = mini(target, int(daily.get(mission_id,0))+amount)
	if int(daily[mission_id]) >= target:
		claimed[mission_id] = true
		_grant_xp(int(entry["reward"]))
		mission_completed.emit(mission_id,int(entry["reward"]))

func _grant_xp(amount: int) -> void:
	var before: int = level()
	xp = clampi(xp+maxi(0, amount),0,MAX_XP)
	if level() > before:
		level_reached.emit(level())

func _save() -> bool:
	if not persist_enabled:
		return true
	var data: Dictionary = {
		"version": VERSION,"xp": xp,
		"last_play_day":last_play_day,"streak":streak,
		"daily_day":daily_day,"daily":daily,"claimed":claimed,
		"skin":skin,"total_drops":total_drops,"total_pops":total_pops,
		"total_rounds":total_rounds,"best_chain":best_chain,
		"recent_event_ids":recent_event_ids
	}
	var file: FileAccess = FileAccess.open(TEMP, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.flush()
	file.close()
	var code: Error = DirAccess.rename_absolute(
		ProjectSettings.globalize_path(TEMP),
		ProjectSettings.globalize_path(PATH)
	)
	return code == OK
