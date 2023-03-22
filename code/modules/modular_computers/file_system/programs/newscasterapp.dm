/datum/computer_file/program/newscaster
	filename = "newscasterapp"
	filedesc = "Newscaster"
	required_access = list(ACCESS_LIBRARY)
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "bountyboard"
	extended_desc = "This program allows any user to access the Newscaster network from anywhere."
	size = 2
	requires_ntnet = TRUE
	available_on_ntnet = TRUE
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
	var/list/data = list()
	data += newscaster_ui.ui_data(user)
	return data

/datum/computer_file/program/newscaster/ui_static_data(mob/user)
	var/list/data = newscaster_ui.ui_static_data(user)
	return data

/datum/computer_file/program/newscaster/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	return newscaster_ui.ui_act(action, params, ui)
