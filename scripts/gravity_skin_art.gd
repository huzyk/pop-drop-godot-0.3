extends RefCounted
## One source of truth for ALL purchasable skin artwork.
## Never fake an owned cosmetic with circles or a recolor of the base sprite.
const PACKS = {
	"default": [
		preload("res://assets/visual_v2/orb_peach.svg"),
		preload("res://assets/visual_v2/orb_aqua.svg"),
		preload("res://assets/visual_v2/orb_violet.svg")
	],
	"neon": [
		preload("res://assets/skins/neon/coral.svg"),
		preload("res://assets/skins/neon/mint.svg"),
		preload("res://assets/skins/neon/blue.svg")
	],
	"gold": [
		preload("res://assets/skins/gold/coral.svg"),
		preload("res://assets/skins/gold/mint.svg"),
		preload("res://assets/skins/gold/blue.svg")
	],
	"donut": [
		preload("res://assets/skins/donut/coral.svg"),
		preload("res://assets/skins/donut/mint.svg"),
		preload("res://assets/skins/donut/blue.svg")
	],
	"capybara": [
		preload("res://assets/skins/capybara/coral.svg"),
		preload("res://assets/skins/capybara/mint.svg"),
		preload("res://assets/skins/capybara/blue.svg")
	],
	"crystal": [
		preload("res://assets/skins/crystal/coral.svg"),
		preload("res://assets/skins/crystal/mint.svg"),
		preload("res://assets/skins/crystal/blue.svg")
	],
	"cosmos": [
		preload("res://assets/skins/cosmos/coral.svg"),
		preload("res://assets/skins/cosmos/mint.svg"),
		preload("res://assets/skins/cosmos/blue.svg")
	],
	"star_capybara": [
		preload("res://assets/skins/star_capybara/coral.svg"),
		preload("res://assets/skins/star_capybara/mint.svg"),
		preload("res://assets/skins/star_capybara/blue.svg")
	]
}

static func sprite_for(skin_id: String, color_index: int) -> Texture2D:
	if not PACKS.has(skin_id):
		return null
	return PACKS[skin_id][clampi(color_index,0,2)]

static func is_authored(skin_id: String) -> bool:
	return PACKS.has(skin_id)
