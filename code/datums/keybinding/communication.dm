/datum/keybinding/client/communication
	category = CATEGORY_COMMUNICATION

/datum/keybinding/client/communication/say
	hotkey_keys = list("F3", "T") // BANDASTATION EDIT
	name = SAY_CHANNEL
	full_name = "Говорить"
	keybind_signal = COMSIG_KB_CLIENT_SAY_DOWN

/datum/keybinding/client/communication/say/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	if(!user.prefs.read_preference(/datum/preference/toggle/tgui_input))
		winset(user, null, "command=[VERB_SAY]")
		return TRUE
	winset(user, null, "command=[user.tgui_say_create_open_command(SAY_CHANNEL)];")
	winset(user, SKIN_TGUISAY_BROWSER, "focus=true")
	return TRUE

/datum/keybinding/client/communication/radio
	hotkey_keys = list("Y")
	name = RADIO_CHANNEL
	full_name = "Общий канал рации (;)"
	keybind_signal = COMSIG_KB_CLIENT_RADIO_DOWN

/datum/keybinding/client/communication/radio/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	if(!user.prefs.read_preference(/datum/preference/toggle/tgui_input))
		winset(user, null, "command=[VERB_SAY]")
		return TRUE
	winset(user, null, "command=[user.tgui_say_create_open_command(RADIO_CHANNEL)]")
	winset(user, SKIN_TGUISAY_BROWSER, "focus=true")
	return TRUE

/datum/keybinding/client/communication/ooc
	hotkey_keys = list("F2", "O") // BANDASTATION EDIT
	name = OOC_CHANNEL
	full_name = "OOC"
	keybind_signal = COMSIG_KB_CLIENT_OOC_DOWN

/datum/keybinding/client/communication/ooc/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	if(!user.prefs.read_preference(/datum/preference/toggle/tgui_input))
		winset(user, null, "command=[VERB_OOC]")
		return TRUE
	winset(user, null, "command=[user.tgui_say_create_open_command(OOC_CHANNEL)]")
	winset(user, SKIN_TGUISAY_BROWSER, "focus=true")
	return TRUE

/datum/keybinding/client/communication/me
	hotkey_keys = list("M") // BANDASTATION EDIT
	name = ME_CHANNEL
	full_name = "Эмоция"
	keybind_signal = COMSIG_KB_CLIENT_ME_DOWN

/datum/keybinding/client/communication/me/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	if(!user.prefs.read_preference(/datum/preference/toggle/tgui_input))
		winset(user, null, "command=[VERB_ME]")
		return TRUE
	winset(user, null, "command=[user.tgui_say_create_open_command(ME_CHANNEL)]")
	winset(user, SKIN_TGUISAY_BROWSER, "focus=true")
	return TRUE

/datum/keybinding/client/communication/pray
	hotkey_keys = list("P")
	name = PRAY_CHANNEL
	full_name = "Молитва"
	description = "Позволяет вам напрямую отправить сообщение вашему богу (Админам) в рамках IC."
	keybind_signal = COMSIG_KB_CLIENT_PRAY_DOWN

/datum/keybinding/client/communication/pray/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	if(!user.prefs.read_preference(/datum/preference/toggle/tgui_input))
		winset(user, null, "command=[VERB_PRAY]")
		return TRUE
	winset(user, null, "command=[user.tgui_say_create_open_command(PRAY_CHANNEL)];")
	winset(user, "tgui_say.browser", "focus=true")
	return TRUE
