/datum/computer_file/program/warrant
	filename = "warrantapp"
	filedesc = "Citations & Fines"
	download_access = list(ACCESS_BRIG_ENTRANCE)
	downloader_category = PROGRAM_CATEGORY_SECURITY
	program_open_overlay = "warrant"
	extended_desc = "This program allows any user to read, pay, and print citations on go."
	size = 2
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	can_run_on_flags = PROGRAM_PDA
	tgui_id = "NtosWarrant"
	program_icon = "money-check-dollar"
	///The UI we use for the citations
	var/obj/machinery/computer/warrant/warrant_ui

/datum/computer_file/program/warrant/New()
	warrant_ui = new()
	return ..()

/datum/computer_file/program/warrant/Destroy()
	QDEL_NULL(warrant_ui)
	return ..()

/datum/computer_file/program/warrant/ui_data(mob/user)
	warrant_ui.source = user
	return warrant_ui.ui_data(user)

/datum/computer_file/program/warrant/ui_static_data(mob/user)
	return warrant_ui.ui_static_data(user)

/datum/computer_file/program/warrant/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	return warrant_ui.ui_act(action, params, ui, state)
