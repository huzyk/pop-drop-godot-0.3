extends RefCounted
## Offline soft-currency store and regenerating energy for POP DROP.
## All rewards are idempotent locally; real ad rewards require the SDK callback.
const PATH := "user://gravity_shop_v1.json"
const TEMP := "user://gravity_shop_v1.tmp"
const VERSION := 5
const MAX_COINS := 100000000
const MAX_BOOST_STOCK := 20
const MAX_EVENT_HISTORY := 256
const MAX_ENERGY := 5
const ENERGY_SECONDS := 1200
const RESCUE_PRICE := 220
const DAILY_PRIZES := [20,30,50,70,90,120,150]
const ITEMS := [
	{"id":"bomb","kind":"boost","price":160},
	{"id":"reroll","kind":"boost","price":140},
	{"id":"neon","kind":"skin","price":900},
	{"id":"gold","kind":"skin","price":2600},
	{"id":"donut","kind":"skin","price":1900},
	{"id":"capybara","kind":"skin","price":3300},
	{"id":"crystal","kind":"skin","price":3900},
	{"id":"toucan","kind":"skin","price":2900},
	{"id":"parrot","kind":"skin","price":3100},
	{"id":"frog","kind":"skin","price":1800},
	{"id":"monkey","kind":"skin","price":2700},
	{"id":"jaguar","kind":"skin","price":4200},
	{"id":"sloth","kind":"skin","price":3000},
	{"id":"lion","kind":"skin","price":3900},
	{"id":"zebra","kind":"skin","price":3400},
	{"id":"elephant","kind":"skin","price":4100},
	{"id":"giraffe","kind":"skin","price":3500},
	{"id":"fox","kind":"skin","price":2300},
	{"id":"owl","kind":"skin","price":2600}
]
const SPECIAL_SKIN := "star_capybara"

var persist_enabled: bool = true
var coins: int = 0
var total_earned: int = 0
var total_spent: int = 0
var inventory: Dictionary = {"bomb":0,"reroll":0}
var owned_skins: Dictionary = {"neon":false,"gold":false,"donut":false,
	"capybara":false,"crystal":false,"star_capybara":false,
	"toucan":false,"parrot":false,"frog":false,"monkey":false,
	"jaguar":false,"sloth":false,"lion":false,"zebra":false,
	"elephant":false,"giraffe":false,"fox":false,"owl":false}
var equipped_skin: String = "default"
var seen_pop_ids: Array = []
var seen_bonus_ids: Array = []
var energy: int = MAX_ENERGY
var energy_anchor: int = 0
var daily_last_claim: String = ""
var daily_streak: int = 0

static func item(id: String) -> Dictionary:
	for entry in ITEMS:
		if str(entry["id"]) == id:
			return entry
	return {}

static func earned_from_pop(points: int) -> int:
	if points <= 0:
		return 0
	# Unlimited earnings: a square-root curve keeps huge combos valuable,
	# but prevents their payouts from overwhelming long-term cosmetic goals.
	return maxi(2,int(round(sqrt(float(points))*0.30)))

func stock(id: String) -> int:
	return int(inventory.get(id,0))

func owns_skin(id: String) -> bool:
	return bool(owned_skins.get(id,false))

func can_purchase(id: String) -> bool:
	var offer: Dictionary = item(id)
	if offer.is_empty() or coins < int(offer["price"]):
		return false
	if str(offer["kind"]) == "skin":
		return not owns_skin(id)
	return stock(id) < MAX_BOOST_STOCK

func _credit(amount: int) -> int:
	var gained: int = mini(maxi(0,amount),MAX_COINS-coins)
	coins += gained
	total_earned = mini(MAX_COINS,total_earned+gained)
	return gained

func credit_pop(event_id: String, points: int) -> int:
	if event_id.is_empty() or event_id in seen_pop_ids or points <= 0:
		return 0
	var gained: int = _credit(earned_from_pop(points))
	if gained <= 0:
		return 0
	# Every unique POP earns coins for as long as the game continues.
	seen_pop_ids.append(event_id)
	if seen_pop_ids.size() > MAX_EVENT_HISTORY:
		seen_pop_ids.pop_front()
	_save()
	return gained

func credit_bonus(event_id: String, amount: int) -> int:
	if event_id.is_empty() or event_id in seen_bonus_ids or amount <= 0:
		return 0
	var gained: int = _credit(amount)
	if gained <= 0:
		return 0
	seen_bonus_ids.append(event_id)
	if seen_bonus_ids.size() > MAX_EVENT_HISTORY:
		seen_bonus_ids.pop_front()
	_save()
	return gained

func purchase(id: String) -> bool:
	if not can_purchase(id):
		return false
	var offer: Dictionary = item(id)
	coins -= int(offer["price"])
	total_spent = mini(MAX_COINS,total_spent+int(offer["price"]))
	if str(offer["kind"]) == "boost":
		inventory[id] = stock(id)+1
	else:
		owned_skins[id] = true
	_save()
	return true

func spend_coins(amount: int) -> bool:
	if amount <= 0 or coins < amount:
		return false
	coins -= amount
	total_spent = mini(MAX_COINS,total_spent+amount)
	_save()
	return true

func equip_skin(id: String) -> bool:
	if id != "default" and not owns_skin(id):
		return false
	equipped_skin = id
	_save()
	return true

func use_boost(id: String) -> bool:
	if str(item(id).get("kind","")) != "boost" or stock(id) <= 0:
		return false
	inventory[id] = stock(id)-1
	_save()
	return true

func refresh_energy(now_unix: int = -1) -> int:
	var now: int = now_unix if now_unix >= 0 else int(Time.get_unix_time_from_system())
	if energy >= MAX_ENERGY:
		energy = MAX_ENERGY
		energy_anchor = 0
		return energy
	if energy_anchor <= 0:
		energy_anchor = now
		_save()
		return energy
	if now < energy_anchor:
		return energy
	var ticks: int = (now-energy_anchor) / ENERGY_SECONDS
	if ticks > 0:
		energy = mini(MAX_ENERGY,energy+ticks)
		energy_anchor = 0 if energy == MAX_ENERGY else energy_anchor+ticks*ENERGY_SECONDS
		_save()
	return energy

func energy_seconds_remaining(now_unix: int = -1) -> int:
	var now: int = now_unix if now_unix >= 0 else int(Time.get_unix_time_from_system())
	refresh_energy(now)
	if energy >= MAX_ENERGY:
		return 0
	return maxi(0,ENERGY_SECONDS-maxi(0,now-energy_anchor))

func spend_energy(now_unix: int = -1) -> bool:
	var now: int = now_unix if now_unix >= 0 else int(Time.get_unix_time_from_system())
	refresh_energy(now)
	if energy <= 0:
		return false
	energy -= 1
	if energy_anchor <= 0:
		energy_anchor = now
	_save()
	return true

func reward_energy(now_unix: int = -1) -> bool:
	var now: int = now_unix if now_unix >= 0 else int(Time.get_unix_time_from_system())
	refresh_energy(now)
	if energy >= MAX_ENERGY:
		return false
	energy += 1
	if energy == MAX_ENERGY:
		energy_anchor = 0
	_save()
	return true

func claim_daily(day_override: String = "") -> Dictionary:
	var today: String = day_override if not day_override.is_empty() else Time.get_date_string_from_system(false)
	if today == daily_last_claim:
		return {}
	var gap: int = 99
	if not daily_last_claim.is_empty():
		var previous: int = int(Time.get_unix_time_from_datetime_string(daily_last_claim+"T12:00:00"))
		var current: int = int(Time.get_unix_time_from_datetime_string(today+"T12:00:00"))
		gap = int((current-previous)/86400)
	if gap <= 0:
		return {}
	daily_streak = (daily_streak % 7)+1 if gap == 1 else 1
	daily_last_claim = today
	var reward: int = DAILY_PRIZES[daily_streak-1]
	var granted: int = _credit(reward)
	var special: bool = daily_streak == 7 and not owns_skin(SPECIAL_SKIN)
	if special:
		owned_skins[SPECIAL_SKIN] = true
	_save()
	return {"day":daily_streak,"coins":granted,"skin":SPECIAL_SKIN if special else ""}

func load_data() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if not (value is Dictionary) or int(value.get("version",0)) not in [1,2,3,4,VERSION]:
		return
	coins = clampi(int(value.get("coins",0)),0,MAX_COINS)
	total_earned = clampi(int(value.get("total_earned",0)),0,MAX_COINS)
	total_spent = clampi(int(value.get("total_spent",0)),0,MAX_COINS)
	var stored_inventory: Variant = value.get("inventory",{})
	var refund_magic: int = 0
	if stored_inventory is Dictionary:
		for boost_id in inventory.keys():
			inventory[boost_id] = clampi(int(stored_inventory.get(boost_id,0)),0,MAX_BOOST_STOCK)
		# Deprecated color charges are refunded exactly once during migration.
		if int(value.get("version",0)) < 3:
			refund_magic = clampi(int(stored_inventory.get("magic",0)),0,MAX_BOOST_STOCK)*220
		# Preserve previously purchased +10s stock as the new reroll power.
		if int(value.get("version",0)) == 1:
			inventory["reroll"] = mini(MAX_BOOST_STOCK,stock("reroll")+maxi(0,int(stored_inventory.get("time",0))))
	var stored_skins: Variant = value.get("owned_skins",{})
	var refund_cosmos: int = 0
	if stored_skins is Dictionary:
		for skin_id in owned_skins.keys():
			owned_skins[skin_id] = bool(stored_skins.get(skin_id,false))
		# Cosmos is retired. Refund old buyers once; preserve every other skin.
		if int(value.get("version",0)) < 5 and bool(stored_skins.get("cosmos",false)):
			refund_cosmos = 5200
	var chosen: String = str(value.get("equipped_skin","default"))
	equipped_skin = chosen if chosen == "default" or owns_skin(chosen) else "default"
	for key in ["seen_pop_ids","seen_bonus_ids"]:
		var history: Variant = value.get(key,[])
		if history is Array:
			for entry in history.slice(maxi(0,history.size()-MAX_EVENT_HISTORY)):
				var id: String = str(entry)
				var out: Array = seen_pop_ids if key == "seen_pop_ids" else seen_bonus_ids
				if not id.is_empty() and id not in out:
					out.append(id)
	energy = clampi(int(value.get("energy",MAX_ENERGY)),0,MAX_ENERGY)
	energy_anchor = maxi(0,int(value.get("energy_anchor",0)))
	daily_last_claim = str(value.get("daily_last_claim",""))
	daily_streak = clampi(int(value.get("daily_streak",0)),0,7)
	if int(value.get("version",0)) < VERSION:
		_credit(refund_magic+refund_cosmos)
		_save() # One-time migrations never repeat on the next startup.
	refresh_energy()

func _save() -> bool:
	if not persist_enabled:
		return true
	var contents: Dictionary = {
		"version":VERSION,"coins":coins,
		"total_earned":total_earned,"total_spent":total_spent,
		"inventory":inventory,"owned_skins":owned_skins,
		"equipped_skin":equipped_skin,"seen_pop_ids":seen_pop_ids,
		"seen_bonus_ids":seen_bonus_ids,"energy":energy,
		"energy_anchor":energy_anchor,
		"daily_last_claim":daily_last_claim,"daily_streak":daily_streak
	}
	var file: FileAccess = FileAccess.open(TEMP,FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(contents))
	file.flush()
	file.close()
	var result: Error = DirAccess.rename_absolute(
		ProjectSettings.globalize_path(TEMP),
		ProjectSettings.globalize_path(PATH)
	)
	return result == OK
