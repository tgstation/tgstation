#define HINT_ICON_FILE 'icons/ui_icons/screentips/cursor_hints.dmi'

// Generate intent icons
GLOBAL_LIST_INIT_TYPED(screentip_context_icons, /image, prepare_screentip_context_icons())

/proc/prepare_screentip_context_icons()
	. = list()
	for(var/state in icon_states(HINT_ICON_FILE))
		.[state] = image(HINT_ICON_FILE, icon_state = state)

/*
 * # Compiles a string for this key
 * Args:
 * - context = list (REQUIRED)
 * 	- Must contain key
 * - key = string (REQUIRED)
 * - allow_image = boolean (not required)
*/
/proc/build_context(list/context, key, allow_image)
	if(!(length(context) && context[key] && key))
		return ""
	// Get everything but the mouse button, may be empty
	var/key_combo = length(key) > 3 ? "[copytext(key, 1, -3)]" : ""
	// Grab the mouse button, LMB/RMB
	var/button = copytext(key, -3)
	if(allow_image)
		// Compile into image, if allowed
		button = "\icon[GLOB.screentip_context_icons[button]]"

	// Voilá, final result
	return "[key_combo][button][allow_image ? "" : ":"] [context[key]]"

#undef HINT_ICON_FILE
