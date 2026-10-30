extends RefCounted
## Offline-only player progression. No login, device identifier, network or ads.
## All progression is cosmetic; neither rewarded ads nor paid purchases give XP.
signal mission_completed(mission_id: String, bonus_xp: int)
signal level_reached(new_level: int)
signal streak_updated(days: int)
signal achievement_unlocked(id: String, reward_coins: int)

const PATH := "user://gravity_profile_v1.json"
const TEMP := "user://gravity_profile_v1.tmp"
const VERSION := 1
const MAX_XP := 200000000
const MISSIONS := [
	{"id":"drops", "target":10, "reward":60},
	{"id":"pops", "target":3, "reward":90},
	{"id":"points", "target":1800, "reward":120}
]
const ACHIEVEMENTS := [
	{"id":"first_drop","target":1,"metric":"drops","coins":20},
	{"id":"drops_25","target":25,"metric":"drops","coins":60},
	{"id":"drops_100","target":100,"metric":"drops","coins":180},
	{"id":"pop_1","target":1,"metric":"pops","coins":25},
	{"id":"pop_50","target":50,"metric":"pops","coins":130},
	{"id":"pop_200","target":200,"metric":"pops","coins":300},
	{"id":"combo_2","target":2,"metric":"chain","coins":45},
	{"id":"combo_4","target":4,"metric":"chain","coins":160},
	{"id":"score_10000","target":10000,"metric":"points","coins":180},
	{"id":"rounds_10","target":10,"metric":"rounds","coins":100},
	{"id":"streak_3","target":3,"metric":"streak","coins":80},
	{"id":"streak_7","target":7,"metric":"streak","coins":220}
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
var total_pop_points: int = 0
var unlocked_achievements: Dictionary = {}
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
			total_pop_points = clampi(int(raw.get("total_pop_points",0)),0,MAX_XP)
			var stored_badges: Variant = raw.get("unlocked_achievements",{})
			if stored_badges is Dictionary:
				for badge in ACHIEVEMENTS:
					var key: String = str(badge["id"])
					unlocked_achievements[key] = bool(stored_badges.get(key,false))
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
	_check_achievements()
	_save()

func record_pop(event_id: String, groups: int, balls: int, points: int, chain: int, day_override: String = "") -> void:
	ensure_day(day_override)
	if not _accept_event(event_id):
		return
	total_pops = mini(total_pops+maxi(0,groups),100000000)
	best_chain = maxi(best_chain,chain)
	total_pop_points = mini(MAX_XP,total_pop_points+maxi(0,points))
	_grant_xp(mini(90, maxi(0,balls)*2 + maxi(0,groups)*5 + maxi(0,chain-1)*5))
	_update_mission("pops",maxi(0,groups))
	_update_mission("points",maxi(0,points))
	_check_achievements()
	_save()

func record_round(event_id: String) -> void:
	if not _accept_event(event_id):
		return
	total_rounds = mini(total_rounds+1,100000000)
	_check_achievements()
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
	_check_achievements()
	streak_updated.emit(streak)

func achievement_progress(id: String) -> int:
	for badge in ACHIEVEMENTS:
		if str(badge["id"]) != id:
			continue
		match str(badge["metric"]):
			"drops": return total_drops
			"pops": return total_pops
			"chain": return best_chain
			"points": return total_pop_points
			"rounds": return total_rounds
			"streak": return streak
	return 0

func achievement_unlocked_count() -> int:
	var result: int = 0
	for badge in ACHIEVEMENTS:
		if bool(unlocked_achievements.get(str(badge["id"]),false)):
			result += 1
	return result

func _check_achievements() -> void:
	for badge in ACHIEVEMENTS:
		var id: String = str(badge["id"])
		if bool(unlocked_achievements.get(id,false)):
			continue
		if achievement_progress(id) < int(badge["target"]):
			continue
		unlocked_achievements[id] = true
		achievement_unlocked.emit(id,int(badge["coins"]))

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
		"total_pop_points":total_pop_points,"unlocked_achievements":unlocked_achievements,
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
