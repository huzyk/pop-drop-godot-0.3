extends RefCounted
## One visual world per animal set. Explicitly authored SVGs, no runtime circles
## or procedural recoloring of the artwork.
const BOARD = {
	"jungle":"res://assets/themes/jungle.svg",
	"safari":"res://assets/themes/safari.svg",
	"forest":"res://assets/themes/forest.svg",
	"wetlands":"res://assets/themes/wetlands.svg",
	"aviary":"res://assets/themes/aviary.svg",
	"fantasy":"res://assets/themes/fantasy.svg"
}
const FRAME = {
	"jungle":"res://assets/themes/jungle_frame.svg",
	"safari":"res://assets/themes/safari_frame.svg",
	"forest":"res://assets/themes/forest_frame.svg",
	"wetlands":"res://assets/themes/wetlands_frame.svg",
	"aviary":"res://assets/themes/aviary_frame.svg",
	"fantasy":"res://assets/themes/fantasy_frame.svg"
}
const SKIN_THEME = {
	"capybara":"forest","star_capybara":"forest","bear":"forest","star_bear":"forest",
	"toucan":"jungle","monkey":"jungle","jaguar":"jungle","sloth":"jungle",
	"parrot":"aviary","frog":"wetlands",
	"lion":"safari","zebra":"safari","elephant":"safari","giraffe":"safari",
	"fox":"forest","owl":"forest",
	"dragon":"fantasy","unicorn":"fantasy","phoenix":"fantasy","griffin":"fantasy"
}
const THEME_LABELS = {
	"jungle":{"pl":"DŻUNGLA","en":"JUNGLE"},
	"safari":{"pl":"SAFARI","en":"SAFARI"},
	"forest":{"pl":"LAS","en":"FOREST"},
	"wetlands":{"pl":"MOKRADŁA","en":"WETLANDS"},
	"aviary":{"pl":"PTASIA KRAINA","en":"BIRDLAND"},
	"fantasy":{"pl":"BAJKOWA KRAINA","en":"FANTASY REALM"}
}

static func for_skin(skin_id: String) -> String:
	return str(SKIN_THEME.get(skin_id,""))

# Avoid preloading all six 720x1280 overlays and six boards on
# memory-constrained Android editors. Keep only the selected world.
static var _loaded_theme: String = ""
static var _loaded_board: Texture2D = null
static var _loaded_frame: Texture2D = null

static func _ensure_skin(skin_id: String) -> void:
	var next_theme: String = for_skin(skin_id)
	if next_theme == _loaded_theme:
		return
	_loaded_theme = next_theme
	_loaded_board = null
	_loaded_frame = null
	if next_theme.is_empty():
		return
	_loaded_board = ResourceLoader.load(str(BOARD.get(next_theme,""))) as Texture2D
	_loaded_frame = ResourceLoader.load(str(FRAME.get(next_theme,""))) as Texture2D

static func board_for_skin(skin_id: String) -> Texture2D:
	_ensure_skin(skin_id)
	return _loaded_board

static func frame_for_skin(skin_id: String) -> Texture2D:
	_ensure_skin(skin_id)
	return _loaded_frame

static func theme_title(skin_id: String, language: String = "pl") -> String:
	var theme: String = for_skin(skin_id)
	if theme.is_empty():
		return ""
	var names: Dictionary = THEME_LABELS.get(theme,{})
	return str(names.get(language,names.get("en",theme)))
