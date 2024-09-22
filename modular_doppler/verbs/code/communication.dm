/datum/keybinding/client/communication/looc
	hotkey_keys = list("CtrlO")
	name = LOOC_CHANNEL
	full_name = "Local OOC (LOOC)"
	keybind_signal = COMSIG_KB_CLIENT_LOOC_DOWN

/datum/keybinding/client/communication/looc/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(LOOC_CHANNEL)]")
	return TRUE

/datum/keybinding/client/communication/whisper
	hotkey_keys = list("CtrlT")
	name = WHIS_CHANNEL
	full_name = "IC Whisper"
	keybind_signal = COMSIG_KB_CLIENT_WHISPER_DOWN

/datum/keybinding/client/communication/whisper/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(WHIS_CHANNEL)]")
	return TRUE

/datum/keybinding/client/communication/Do
	hotkey_keys = list("K")
	name = DO_CHANNEL
	full_name = "Do"
	keybind_signal = COMSIG_KB_CLIENT_DO_DOWN

/datum/keybinding/client/communication/Do/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(DO_CHANNEL)]")
	return TRUE

/datum/keybinding/client/communication/Do_longer
	hotkey_keys = list("CtrlK")
	name = "do_longer"
	full_name = "Do (Longer)"
	keybind_signal = COMSIG_KB_CLIENT_DO_LONGER_DOWN

/datum/keybinding/client/communication/Do_longer/down(client/user)
	. = ..()
	if(.)
		return
	var/message_text = tgui_input_text(user, "Write out your Do action:", "Do (Longer)", null, MAX_MESSAGE_LEN, TRUE)
	if (!message_text)
		return

	user.mob.do_verb(message_text)
	return TRUE
