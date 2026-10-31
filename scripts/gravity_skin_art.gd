extends RefCounted
## One source of truth for ALL purchasable skin artwork.
## Never fake an owned cosmetic with circles or a recolor of the base sprite.
const PACK_PATHS = {
	"default": [
		"res://assets/atelier_v6/orb_coral.svg",
		"res://assets/atelier_v6/orb_mint.svg",
		"res://assets/atelier_v6/orb_violet.svg"
	],
	"neon": [
		"res://assets/skins/neon/coral.svg",
		"res://assets/skins/neon/mint.svg",
		"res://assets/skins/neon/blue.svg"
	],
	"gold": [
		"res://assets/skins/gold/coral.svg",
		"res://assets/skins/gold/mint.svg",
		"res://assets/skins/gold/blue.svg"
	],
	"donut": [
		"res://assets/skins/donut/coral.svg",
		"res://assets/skins/donut/mint.svg",
		"res://assets/skins/donut/blue.svg"
	],
	"capybara": [
		"res://assets/skins/animals/bear/coral.svg",
		"res://assets/skins/animals/bear/mint.svg",
		"res://assets/skins/animals/bear/blue.svg"
	],
	"crystal": [
		"res://assets/skins/crystal/coral.svg",
		"res://assets/skins/crystal/mint.svg",
		"res://assets/skins/crystal/blue.svg"
	],
	"star_capybara": [
		"res://assets/skins/animals/star_bear/coral.svg",
		"res://assets/skins/animals/star_bear/mint.svg",
		"res://assets/skins/animals/star_bear/blue.svg"
	],
	"bear": [
		"res://assets/skins/animals/bear/coral.svg",
		"res://assets/skins/animals/bear/mint.svg",
		"res://assets/skins/animals/bear/blue.svg"
	],
	"toucan": [
		"res://assets/skins/animals/toucan/coral.svg",
		"res://assets/skins/animals/toucan/mint.svg",
		"res://assets/skins/animals/toucan/blue.svg"
	],
	"parrot": [
		"res://assets/skins/animals/parrot/coral.svg",
		"res://assets/skins/animals/parrot/mint.svg",
		"res://assets/skins/animals/parrot/blue.svg"
	],
	"frog": [
		"res://assets/skins/animals/frog/coral.svg",
		"res://assets/skins/animals/frog/mint.svg",
		"res://assets/skins/animals/frog/blue.svg"
	],
	"monkey": [
		"res://assets/skins/animals/monkey/coral.svg",
		"res://assets/skins/animals/monkey/mint.svg",
		"res://assets/skins/animals/monkey/blue.svg"
	],
	"jaguar": [
		"res://assets/skins/animals/jaguar/coral.svg",
		"res://assets/skins/animals/jaguar/mint.svg",
		"res://assets/skins/animals/jaguar/blue.svg"
	],
	"sloth": [
		"res://assets/skins/animals/sloth/coral.svg",
		"res://assets/skins/animals/sloth/mint.svg",
		"res://assets/skins/animals/sloth/blue.svg"
	],
	"lion": [
		"res://assets/skins/animals/lion/coral.svg",
		"res://assets/skins/animals/lion/mint.svg",
		"res://assets/skins/animals/lion/blue.svg"
	],
	"zebra": [
		"res://assets/skins/animals/zebra/coral.svg",
		"res://assets/skins/animals/zebra/mint.svg",
		"res://assets/skins/animals/zebra/blue.svg"
	],
	"elephant": [
		"res://assets/skins/animals/elephant/coral.svg",
		"res://assets/skins/animals/elephant/mint.svg",
		"res://assets/skins/animals/elephant/blue.svg"
	],
	"giraffe": [
		"res://assets/skins/animals/giraffe/coral.svg",
		"res://assets/skins/animals/giraffe/mint.svg",
		"res://assets/skins/animals/giraffe/blue.svg"
	],
	"fox": [
		"res://assets/skins/animals/fox/coral.svg",
		"res://assets/skins/animals/fox/mint.svg",
		"res://assets/skins/animals/fox/blue.svg"
	],
	"owl": [
		"res://assets/skins/animals/owl/coral.svg",
		"res://assets/skins/animals/owl/mint.svg",
		"res://assets/skins/animals/owl/blue.svg"
	],
	"star_bear": [
		"res://assets/skins/animals/star_bear/coral.svg",
		"res://assets/skins/animals/star_bear/mint.svg",
		"res://assets/skins/animals/star_bear/blue.svg"
	],
	"dragon": [
		"res://assets/skins/animals/dragon/coral.svg",
		"res://assets/skins/animals/dragon/mint.svg",
		"res://assets/skins/animals/dragon/blue.svg"
	],
	"unicorn": [
		"res://assets/skins/animals/unicorn/coral.svg",
		"res://assets/skins/animals/unicorn/mint.svg",
		"res://assets/skins/animals/unicorn/blue.svg"
	],
	"phoenix": [
		"res://assets/skins/animals/phoenix/coral.svg",
		"res://assets/skins/animals/phoenix/mint.svg",
		"res://assets/skins/animals/phoenix/blue.svg"
	],
	"griffin": [
		"res://assets/skins/animals/griffin/coral.svg",
		"res://assets/skins/animals/griffin/mint.svg",
		"res://assets/skins/animals/griffin/blue.svg"
	]
}

# A mobile Godot editor has a strict memory budget. Do NOT preload every 512px
# skin sprite: that decoded over 69 textures before the first frame.
# Load only what is displayed (board colours + four store thumbnails).
const MAX_RESIDENT_SPRITES := 12
static var _resident: Dictionary = {}
static var _order: Array = []

static func sprite_for(skin_id: String, color_index: int) -> Texture2D:
	if not PACK_PATHS.has(skin_id):
		return null
	var path: String = str(PACK_PATHS[skin_id][clampi(color_index,0,2)])
	if _resident.has(path):
		# Recent skin stays resident; old skins can be released.
		_order.erase(path)
		_order.append(path)
		return _resident[path] as Texture2D
	var art: Texture2D = ResourceLoader.load(path) as Texture2D
	if art == null:
		push_warning("POP DROP: failed to load skin " + path)
		return null
	_resident[path] = art
	_order.append(path)
	while _order.size() > MAX_RESIDENT_SPRITES:
		var oldest: String = str(_order.pop_front())
		_resident.erase(oldest)
	return art

static func is_authored(skin_id: String) -> bool:
	return PACK_PATHS.has(skin_id)

static func resident_count() -> int:
	return _resident.size()

static func release_unused() -> void:
	_resident.clear()
	_order.clear()
