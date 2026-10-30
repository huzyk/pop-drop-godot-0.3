extends RefCounted
## Central registry of fully authored skin packs.
## Add one const array (coral/mint/blue), one match arm and the corresponding
## entry in the shop catalogue. Never stack procedural faces in gravity_game.gd.
const JELLY_PALS = [
	preload("res://assets/skins/jelly_pals/coral.svg"),
	preload("res://assets/skins/jelly_pals/mint.svg"),
	preload("res://assets/skins/jelly_pals/blue.svg")
]

static func sprite_for(skin_id: String, color_index: int) -> Texture2D:
	var pack: Array = []
	match skin_id:
		"default":
			pack = JELLY_PALS
		_:
			return null # Old shop art remains backward compatible until redesigned.
	return pack[clampi(color_index,0,2)]

static func is_authored(skin_id: String) -> bool:
	return skin_id == "default"
