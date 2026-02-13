/datum/keybinding/client
	category = CATEGORY_CLIENT
	weight = WEIGHT_HIGHEST


/datum/keybinding/client/admin_help
	hotkey_keys = list("F1")
	name = "admin_help"
	full_name = "Admin Help"
	description = "Ask an admin for help."
	keybind_signal = COMSIG_KB_CLIENT_GETHELP_DOWN

/datum/keybinding/client/admin_help/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	user.adminhelp()
	return TRUE


/datum/keybinding/client/screenshot
	hotkey_keys = list("F2")
	name = "quick screenshot"
	full_name = "Quick Screenshot"
	description = "Take a screenshot, which will be stored in BYOND's screenshots folder."
	keybind_signal = COMSIG_KB_CLIENT_SCREENSHOT_DOWN
	can_edit = FALSE

/* This is dealt by BYOND. Keeping this here in case that ever changes.
/datum/keybinding/client/screenshot/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	winset(user, null, "command=.screenshot auto")
	return TRUE
*/

/datum/keybinding/client/screenshot_loc
	hotkey_keys = list("ShiftF2")
	name = "screenshot as"
	full_name = "Save Screenshot as"
	description = "Take a screenshot and save it at a specific location."
	keybind_signal = COMSIG_KB_CLIENT_SCREENSHOT_AS_DOWN
	can_edit = FALSE

/* This is dealt by BYOND. Keeping this here in case that ever changes.
/datum/keybinding/client/screenshot_loc/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	winset(user, null, "command=.screenshot")
	return TRUE
*/

/datum/keybinding/client/toggle_fullscreen
	hotkey_keys = list("F11")
	name = "toggle_fullscreen"
	full_name = "Toggle Fullscreen"
	description = "Makes the game window fullscreen."
	keybind_signal = COMSIG_KB_CLIENT_FULLSCREEN_DOWN

/datum/keybinding/client/toggle_fullscreen/down(client/user, turf/target, mousepos_x, mousepos_y)
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

/datum/keybinding/client/minimal_hud/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	user.mob.button_pressed_F12()
	return TRUE

/datum/keybinding/client/close_every_ui
	hotkey_keys = list("Northwest") // HOME key
	name = "close_every_ui"
	full_name = "Close Open UIs"
	description = "Closes all UI windows you have open."
	keybind_signal = COMSIG_KB_CLIENT_CLOSEUI_DOWN

/datum/keybinding/client/close_every_ui/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	SStgui.close_user_uis(user.mob)
	return TRUE
