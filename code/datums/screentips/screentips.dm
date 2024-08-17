#define HINT_ICON_FILE 'icons/ui/screentips/cursor_hints.dmi'

/// Stores the cursor hint icons for screentip context.
GLOBAL_LIST_INIT_TYPED(screentip_context_icons, /image, prepare_screentip_context_icons())

/proc/prepare_screentip_context_icons()
	var/list/output = list()
	for(var/state in icon_states(HINT_ICON_FILE))
		output[state] = image(HINT_ICON_FILE, icon_state = state)
	return output

/*
 * # Compiles a string for this key
 * Args:
 * - context = list (REQUIRED)
 * 	- Must contain key
 * - key = string (REQUIRED)
 * - allow_image = boolean (not required)
*/
/proc/build_context(list/context, key, allow_image)
	if(!length(context) || !context[key] || !key)
		return ""
	// Splits key combinations from mouse buttons. e.g. `Ctrl-Shift-LMB` goes in, `Ctrl-Shift-` goes out. Will be empty for single button actions.
	var/key_combo = length(key) > 3 ? "[copytext(key, 1, -3)]" : ""
	// Grab the mouse button, LMB/RMB
	var/button = copytext(key, -3)
	if(allow_image)
		// Compile into image, if allowed
		button = "\icon[GLOB.screentip_context_icons[button]]"

	// Voilá, final result
	return "[key_combo][button][allow_image ? "" : ":"] [context[key]]"

#undef HINT_ICON_FILE
