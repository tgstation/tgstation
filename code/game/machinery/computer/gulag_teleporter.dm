/obj/machinery/computer/gulag_teleporter_computer
	name = "labor camp teleporter console"
	desc = "Used to send criminals to the Labor Camp."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	req_access = list(ACCESS_BRIG)
	circuit = /obj/item/circuitboard/computer/gulag_teleporter_console
	light_color = COLOR_SOFT_RED
	/// The connected teleporter
	var/datum/weakref/teleporter_ref


/obj/machinery/computer/gulag_teleporter_computer/Initialize(mapload)
	. = ..()

	find_teleporter()


/obj/machinery/computer/gulag_teleporter_computer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(isnull(ui))
		ui = new(user, src, "GulagTeleporterConsole")
		ui.open()


/obj/machinery/computer/gulag_teleporter_computer/ui_data(mob/user)
	var/list/data = list()

	var/datum/bank_account/sec_account = SSeconomy.get_dep_account(ACCOUNT_SEC)
	data["available_points"] = sec_account.account_balance
	data["last_bounty"] = DSsecurity.last_bounty
	data["total_points"] = DSsecurity.total_points

	var/obj/machinery/gulag_teleporter/teleporter = find_teleporter()
	if(isnull(teleporter))
		return data

	data["teleporter_lock"] = teleporter.locked
	data["teleporter_open"] = teleporter.state_open
	data["processing"] = teleporter.processing

	data["occupant"] = null
	data["wanted_status"] = null
	if(teleporter.occupant)
		data["occupant"] = teleporter.occupant.name
		var/datum/record/crew/record = teleporter.get_occupant_record()
		if(record)
			data["wanted_status"] = record.wanted_status

	return data


/obj/machinery/computer/gulag_teleporter_computer/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(!allowed(usr))
		balloon_alert(usr, "access denied")
		playsound(src, 'sound/machines/terminal_error.ogg', 50, TRUE)
		return TRUE

	if(action == "scan_teleporter")
		find_teleporter()
		return TRUE

	var/obj/machinery/gulag_teleporter/teleporter = find_teleporter()
	if(isnull(teleporter))
		return FALSE

	switch(action)
		if("toggle_open")
			teleporter.toggle_open(usr)
			return TRUE

		if("toggle_lock")
			if(teleporter.state_open)
				to_chat(usr, span_alert("The teleporter must be closed first."))
				return TRUE
			playsound(teleporter, 'sound/machines/eject.ogg', 50, TRUE)
			teleporter.locked = !teleporter.locked
			return TRUE

		if("teleport")
			usr.log_message("is teleporting [key_name(teleporter.occupant)] to the labor camp.", LOG_GAME)
			teleporter.handle_prisoner(usr)
			return TRUE

	return FALSE


/// Gets wanted status of the teleporter occupant.
/obj/machinery/computer/gulag_teleporter_computer/proc/get_record(mob/prisoner) as /datum/record/crew
	if(!ishuman(prisoner) || isnull(GLOB.manifest.general))
		return

	for(var/datum/record/crew/record as anything in GLOB.manifest.general)
		if(record.name == prisoner.name)
			return record


/// Resets the teleporter ref if needed.
/obj/machinery/computer/gulag_teleporter_computer/proc/find_teleporter() as /obj/machinery/gulag_teleporter
	var/obj/machinery/gulag_teleporter/teleporter = teleporter_ref?.resolve()
	if(!QDELETED(teleporter))
		return teleporter

	for(var/direction in GLOB.cardinals)
		teleporter = locate(/obj/machinery/gulag_teleporter, get_step(src, direction))
		if(teleporter?.is_operational)
			teleporter_ref = WEAKREF(teleporter)
			return teleporter
