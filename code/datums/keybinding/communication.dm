/datum/keybinding/client/communication
	category = CATEGORY_COMMUNICATION

/datum/keybinding/client/communication/say
	hotkey_keys = list("T")
	name = "Say"
	full_name = "IC Say"
	keybind_signal = COMSIG_KB_CLIENT_SAY_DOWN

/datum/keybinding/client/communication/say/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=say")
	return TRUE

/datum/keybinding/client/communication/ooc
	hotkey_keys = list("O")
	name = "OOC"
	full_name = "Out Of Character Say (OOC)"
	keybind_signal = COMSIG_KB_CLIENT_OOC_DOWN

/datum/keybinding/client/communication/ooc/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=ooc")
	return TRUE

/datum/keybinding/client/communication/me
	hotkey_keys = list("M")
	name = "Me"
	full_name = "Custom Emote (/Me)"
	keybind_signal = COMSIG_KB_CLIENT_ME_DOWN

/datum/keybinding/client/communication/me/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=me")
	return TRUE
