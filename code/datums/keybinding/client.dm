/datum/keybinding/client
	category = CATEGORY_CLIENT
	weight = WEIGHT_HIGHEST


/datum/keybinding/client/admin_help
	hotkey_keys = list("F1")
	name = "admin_help"
	full_name = "Admin Help"
	description = "Ask an admin for help."
	keybind_signal = COMSIG_KB_CLIENT_GETHELP_DOWN

/datum/keybinding/client/admin_help/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	user.adminhelp()
	return TRUE


/datum/keybinding/client/screenshot
	hotkey_keys = list("F2")
	name = "screenshot"
	full_name = "Screenshot"
	description = "Take a screenshot."
	keybind_signal = COMSIG_KB_CLIENT_SCREENSHOT_DOWN

/datum/keybinding/client/screenshot/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	winset(user, null, "command=.auto")
	return TRUE

/datum/keybinding/client/toggle_fullscreen
	hotkey_keys = list("F11")
	name = "toggle_fullscreen"
	full_name = "Toggle Fullscreen"
	description = "Makes the game window fullscreen."
	keybind_signal = COMSIG_KB_CLIENT_FULLSCREEN_DOWN

/datum/keybinding/client/toggle_fullscreen/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	user.toggle_fullscreen()
	return TRUE

/datum/keybinding/client/minimal_hud
	hotkey_keys = list("F12")
	name = "minimal_hud"
	full_name = "Minimal HUD"
	description = "Hide most HUD features"
	keybind_signal = COMSIG_KB_CLIENT_MINIMALHUD_DOWN

/datum/keybinding/client/minimal_hud/down(client/user, turf/target)
	. = ..()
	if(.)
		return
	user.mob.button_pressed_F12()
	return TRUE
