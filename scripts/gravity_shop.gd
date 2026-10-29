extends RefCounted
## Local-only soft currency shop. No purchases with real money, ads or server.
## POP score and XP are NEVER reduced by spending coins.
const PATH := "user://gravity_shop_v1.json"
const TEMP := "user://gravity_shop_v1.tmp"
const VERSION := 1
const MAX_COINS := 100000000
const ITEMS := [
	{"id":"bomb", "kind":"boost", "price":160},
	{"id":"time", "kind":"boost", "price":110},
	{"id":"neon", "kind":"skin", "price":500},
	{"id":"gold", "kind":"skin", "price":1200}
]
const MAX_BOOST_STOCK := 20
const MAX_EVENT_HISTORY := 256

var persist_enabled: bool = true
var coins: int = 0
var total_earned: int = 0
var total_spent: int = 0
var inventory: Dictionary = {"bomb":0,"time":0}
var owned_skins: Dictionary = {"neon":false,"gold":false}
var equipped_skin: String = "default"
var seen_pop_ids: Array = []

static func item(id: String) -> Dictionary:
	for entry in ITEMS:
		if str(entry["id"]) == id:
			return entry
	return {}

static func earned_from_pop(points: int) -> int:
	return clampi(maxi(0,points) / 10,0,1000000)

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

func credit_pop(event_id: String, points: int) -> int:
	if event_id.is_empty() or event_id in seen_pop_ids or points <= 0:
		return 0
	var reward: int = earned_from_pop(points)
	if reward <= 0:
		return 0
	if coins >= MAX_COINS - reward:
		reward = maxi(0,MAX_COINS-coins)
	if reward <= 0:
		return 0
	coins += reward
	total_earned = mini(MAX_COINS,total_earned+reward)
	seen_pop_ids.append(event_id)
	if seen_pop_ids.size() > MAX_EVENT_HISTORY:
		seen_pop_ids.pop_front()
	_save()
	return reward

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

func load_data() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if not (value is Dictionary) or int(value.get("version",0)) != VERSION:
		return
	coins = clampi(int(value.get("coins",0)),0,MAX_COINS)
	total_earned = clampi(int(value.get("total_earned",0)),0,MAX_COINS)
	total_spent = clampi(int(value.get("total_spent",0)),0,MAX_COINS)
	var stored_inventory: Variant = value.get("inventory",{})
	if stored_inventory is Dictionary:
		for boost_id in inventory.keys():
			inventory[boost_id] = clampi(int(stored_inventory.get(boost_id,0)),0,MAX_BOOST_STOCK)
	var stored_skins: Variant = value.get("owned_skins",{})
	if stored_skins is Dictionary:
		for skin_id in owned_skins.keys():
			owned_skins[skin_id] = bool(stored_skins.get(skin_id,false))
	var chosen: String = str(value.get("equipped_skin","default"))
	equipped_skin = chosen if chosen == "default" or owns_skin(chosen) else "default"
	var recorded: Variant = value.get("seen_pop_ids",[])
	seen_pop_ids.clear()
	if recorded is Array:
		for entry in recorded.slice(maxi(0,recorded.size()-MAX_EVENT_HISTORY)):
			var id: String = str(entry)
			if not id.is_empty() and id not in seen_pop_ids:
				seen_pop_ids.append(id)

func _save() -> bool:
	if not persist_enabled:
		return true
	var contents: Dictionary = {
		"version":VERSION,"coins":coins,
		"total_earned":total_earned,"total_spent":total_spent,
		"inventory":inventory,"owned_skins":owned_skins,
		"equipped_skin":equipped_skin,"seen_pop_ids":seen_pop_ids
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
