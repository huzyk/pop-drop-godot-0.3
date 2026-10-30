extends RefCounted
## One source of truth for ALL purchasable skin artwork.
## Never fake an owned cosmetic with circles or a recolor of the base sprite.
const PACKS = {
	"default": [
		preload("res://assets/atelier_v6/orb_coral.svg"),
		preload("res://assets/atelier_v6/orb_mint.svg"),
		preload("res://assets/atelier_v6/orb_violet.svg")
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
		preload("res://assets/skins/animals/bear/coral.svg"),
		preload("res://assets/skins/animals/bear/mint.svg"),
		preload("res://assets/skins/animals/bear/blue.svg")
	],
	"crystal": [
		preload("res://assets/skins/crystal/coral.svg"),
		preload("res://assets/skins/crystal/mint.svg"),
		preload("res://assets/skins/crystal/blue.svg")
	],
	"star_capybara": [
		preload("res://assets/skins/animals/star_bear/coral.svg"),
		preload("res://assets/skins/animals/star_bear/mint.svg"),
		preload("res://assets/skins/animals/star_bear/blue.svg")
	],
	"bear": [
		preload("res://assets/skins/animals/bear/coral.svg"),
		preload("res://assets/skins/animals/bear/mint.svg"),
		preload("res://assets/skins/animals/bear/blue.svg")
	],
	"toucan": [
		preload("res://assets/skins/animals/toucan/coral.svg"),
		preload("res://assets/skins/animals/toucan/mint.svg"),
		preload("res://assets/skins/animals/toucan/blue.svg")
	],
	"parrot": [
		preload("res://assets/skins/animals/parrot/coral.svg"),
		preload("res://assets/skins/animals/parrot/mint.svg"),
		preload("res://assets/skins/animals/parrot/blue.svg")
	],
	"frog": [
		preload("res://assets/skins/animals/frog/coral.svg"),
		preload("res://assets/skins/animals/frog/mint.svg"),
		preload("res://assets/skins/animals/frog/blue.svg")
	],
	"monkey": [
		preload("res://assets/skins/animals/monkey/coral.svg"),
		preload("res://assets/skins/animals/monkey/mint.svg"),
		preload("res://assets/skins/animals/monkey/blue.svg")
	],
	"jaguar": [
		preload("res://assets/skins/animals/jaguar/coral.svg"),
		preload("res://assets/skins/animals/jaguar/mint.svg"),
		preload("res://assets/skins/animals/jaguar/blue.svg")
	],
	"sloth": [
		preload("res://assets/skins/animals/sloth/coral.svg"),
		preload("res://assets/skins/animals/sloth/mint.svg"),
		preload("res://assets/skins/animals/sloth/blue.svg")
	],
	"lion": [
		preload("res://assets/skins/animals/lion/coral.svg"),
		preload("res://assets/skins/animals/lion/mint.svg"),
		preload("res://assets/skins/animals/lion/blue.svg")
	],
	"zebra": [
		preload("res://assets/skins/animals/zebra/coral.svg"),
		preload("res://assets/skins/animals/zebra/mint.svg"),
		preload("res://assets/skins/animals/zebra/blue.svg")
	],
	"elephant": [
		preload("res://assets/skins/animals/elephant/coral.svg"),
		preload("res://assets/skins/animals/elephant/mint.svg"),
		preload("res://assets/skins/animals/elephant/blue.svg")
	],
	"giraffe": [
		preload("res://assets/skins/animals/giraffe/coral.svg"),
		preload("res://assets/skins/animals/giraffe/mint.svg"),
		preload("res://assets/skins/animals/giraffe/blue.svg")
	],
	"fox": [
		preload("res://assets/skins/animals/fox/coral.svg"),
		preload("res://assets/skins/animals/fox/mint.svg"),
		preload("res://assets/skins/animals/fox/blue.svg")
	],
	"owl": [
		preload("res://assets/skins/animals/owl/coral.svg"),
		preload("res://assets/skins/animals/owl/mint.svg"),
		preload("res://assets/skins/animals/owl/blue.svg")
	],
	"star_bear": [
		preload("res://assets/skins/animals/star_bear/coral.svg"),
		preload("res://assets/skins/animals/star_bear/mint.svg"),
		preload("res://assets/skins/animals/star_bear/blue.svg")
	]
}

static func sprite_for(skin_id: String, color_index: int) -> Texture2D:
	if not PACKS.has(skin_id):
		return null
	return PACKS[skin_id][clampi(color_index,0,2)]

static func is_authored(skin_id: String) -> bool:
	return PACKS.has(skin_id)
