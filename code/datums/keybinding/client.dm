/datum/keybinding/client
	category = CATEGORY_CLIENT
	weight = WEIGHT_HIGHEST


/datum/keybinding/client/admin_help
	hotkey_keys = list("F1")
	name = "admin_help"
	full_name = "Admin Help"
	description = "Ask an admin for help."
	keybind_signal = COMSIG_KB_CLIENT_GETHELP_DOWN

/datum/keybinding/client/admin_help/down(client/user)
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

/datum/keybinding/client/screenshot/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=.auto")
	return TRUE

/datum/keybinding/client/minimal_hud
	hotkey_keys = list("F12")
	name = "minimal_hud"
	full_name = "Minimal HUD"
	description = "Hide most HUD features"
	keybind_signal = COMSIG_KB_CLIENT_MINIMALHUD_DOWN

/datum/keybinding/client/minimal_hud/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.button_pressed_F12()
	return TRUE


/datum/keybinding/client/zoomin
	hotkey_keys = list("Add")
	name = "viewport_zoomin"
	full_name = "Zoom viewport inwards"
	description = "Adjusts your viewport inwards slightly."
	keybind_signal = COMSIG_KB_CLIENT_VIEWPORT_IN

/datum/keybinding/client/zoomin/down(client/user)
	. = ..()
	if(.)
		return
	user.ScaleHotkey(2)
	return TRUE

/datum/keybinding/client/zoomout
	hotkey_keys = list("Subtract")
	name = "viewport_zoomout"
	full_name = "Zoom viewport outwards"
	description = "Adjusts your viewport outwards slightly."
	keybind_signal = COMSIG_KB_CLIENT_VIEWPORT_OUT

/datum/keybinding/client/zoomout/down(client/user)
	. = ..()
	if(.)
		return
	user.ScaleHotkey(-2)
	return TRUE
