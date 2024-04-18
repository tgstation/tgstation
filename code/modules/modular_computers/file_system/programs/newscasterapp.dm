/datum/computer_file/program/newscaster
	filename = "newscasterapp"
	filedesc = "Newscaster"
	download_access = list(ACCESS_LIBRARY)
	downloader_category = PROGRAM_CATEGORY_GAMES
	program_open_overlay = "bountyboard"
	extended_desc = "This program allows any user to access the Newscaster network from anywhere."
	size = 2
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	tgui_id = "NtosNewscaster"
	program_icon = "newspaper"
	///The UI we use for the newscaster
	var/obj/machinery/newscaster/newscaster_ui

/datum/computer_file/program/newscaster/New()
	newscaster_ui = new()
	return ..()

/datum/computer_file/program/newscaster/Destroy()
	QDEL_NULL(newscaster_ui)
	return ..()

/datum/computer_file/program/newscaster/ui_data(mob/user)
	return newscaster_ui.ui_data(user)

/datum/computer_file/program/newscaster/ui_static_data(mob/user)
	return newscaster_ui.ui_static_data(user)

/datum/computer_file/program/newscaster/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	return newscaster_ui.ui_act(action, params, ui, state)
