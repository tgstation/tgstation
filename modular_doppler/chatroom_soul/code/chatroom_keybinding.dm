/datum/keybinding/client/communication/IRC
	hotkey_keys = list("ShiftY")
	name = IRC_CHANNEL
	full_name = "IRC"
	keybind_signal = COMSIG_KB_CLIENT_IRC_DOWN

/datum/keybinding/client/communication/IRC/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(IRC_CHANNEL)]")
	return TRUE
