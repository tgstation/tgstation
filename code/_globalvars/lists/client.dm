GLOBAL_LIST_EMPTY(default_hotkeys)
GLOBAL_LIST_EMPTY(keybindings_by_name)

// This is a mapping from JS keys to Byond - ref: https://keycode.info/
GLOBAL_LIST_INIT(_kbMap, list(
	"UP" = "North",
	"RIGHT" = "East",
	"DOWN" = "South",
	"LEFT" = "West",
	"INSERT" = "Insert",
	"HOME" = "Northwest",
	"PAGEUP" = "Northeast",
	"DEL" = "Delete",
	"END" = "Southwest",
	"PAGEDOWN" = "Southeast",
	"SPACEBAR" = "Space",
	"ALT" = "Alt",
	"SHIFT" = "Shift",
	"CONTROL" = "Ctrl"
	))
