extends RefCounted
## One visual world per animal set. Explicitly authored SVGs, no runtime circles
## or procedural recoloring of the artwork.
const BOARD = {
	"jungle":preload("res://assets/themes/jungle.svg"),
	"safari":preload("res://assets/themes/safari.svg"),
	"forest":preload("res://assets/themes/forest.svg"),
	"wetlands":preload("res://assets/themes/wetlands.svg"),
	"aviary":preload("res://assets/themes/aviary.svg")
}
const FRAME = {
	"jungle":preload("res://assets/themes/jungle_frame.svg"),
	"safari":preload("res://assets/themes/safari_frame.svg"),
	"forest":preload("res://assets/themes/forest_frame.svg"),
	"wetlands":preload("res://assets/themes/wetlands_frame.svg"),
	"aviary":preload("res://assets/themes/aviary_frame.svg")
}
const SKIN_THEME = {
	"capybara":"forest","star_capybara":"forest","bear":"forest","star_bear":"forest",
	"toucan":"jungle","monkey":"jungle","jaguar":"jungle","sloth":"jungle",
	"parrot":"aviary","frog":"wetlands",
	"lion":"safari","zebra":"safari","elephant":"safari","giraffe":"safari",
	"fox":"forest","owl":"forest"
}
const THEME_LABELS = {
	"jungle":{"pl":"DŻUNGLA","en":"JUNGLE"},
	"safari":{"pl":"SAFARI","en":"SAFARI"},
	"forest":{"pl":"LAS","en":"FOREST"},
	"wetlands":{"pl":"MOKRADŁA","en":"WETLANDS"},
	"aviary":{"pl":"PTASIA KRAINA","en":"BIRDLAND"}
}

static func for_skin(skin_id: String) -> String:
	return str(SKIN_THEME.get(skin_id,""))

static func board_for_skin(skin_id: String) -> Texture2D:
	return BOARD.get(for_skin(skin_id),null)

static func frame_for_skin(skin_id: String) -> Texture2D:
	return FRAME.get(for_skin(skin_id),null)

static func theme_title(skin_id: String, language: String = "pl") -> String:
	var theme: String = for_skin(skin_id)
	if theme.is_empty():
		return ""
	var names: Dictionary = THEME_LABELS.get(theme,{})
	return str(names.get(language,names.get("en",theme)))
