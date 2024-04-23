
/obj/machinery/computer/prisoner/gulag_teleporter_computer
	name = "labor camp teleporter console"
	desc = "Used to send criminals to the Labor Camp."
	icon_screen = "explosive"
	icon_keyboard = "security_key"
	req_access = list(ACCESS_BRIG)
	circuit = /obj/item/circuitboard/computer/gulag_teleporter_console
	light_color = COLOR_SOFT_RED
	/// The connected teleporter
	var/datum/weakref/teleporter_ref


/obj/machinery/computer/prisoner/gulag_teleporter_computer/Initialize(mapload)
	. = ..()

	find_teleporter()


/obj/machinery/computer/prisoner/gulag_teleporter_computer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(.)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(isnull(ui))
		ui = new(user, src, "GulagTeleporterConsole")
		ui.open()


/obj/machinery/computer/prisoner/gulag_teleporter_computer/ui_data(mob/user)
	var/list/data = list()

	var/obj/machinery/gulag_teleporter/teleporter = teleporter_ref?.resolve()
	if(QDELETED(teleporter))
		teleporter_ref = null
		return

	data["available_points"] = DSsecurity.available_points
	data["teleporter_lock"] = teleporter.locked
	data["teleporter_open"] = teleporter.state_open
	data["total_points"] = DSsecurity.total_points
	data["processing"] = teleporter.processing
	if(teleporter.occupant)
		data["occupant"] = teleporter.occupant.name
		data["wanted_status"] = get_wanted_status(teleporter.occupant)

	return data


/obj/machinery/computer/prisoner/gulag_teleporter_computer/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(!allowed(usr))
		to_chat(usr, span_warning("Access denied."))
		return TRUE

	if(action == "scan_teleporter")
		find_teleporter()
		return TRUE

	var/obj/machinery/gulag_teleporter/teleporter = teleporter_ref?.resolve()
	if(QDELETED(teleporter))
		return FALSE

	switch(action)
		if("toggle_open")
			if(teleporter.locked)
				to_chat(usr, span_alert("The teleporter must be unlocked first."))
				return
			teleporter.toggle_open()

			return TRUE

		if("toggle_lock")
			if(teleporter.state_open)
				to_chat(usr, span_alert("The teleporter must be closed first."))
				return TRUE
			playsound(teleporter, 'sound/machines/eject.ogg', 50, TRUE)
			teleporter.locked = !teleporter.locked
			return TRUE

		if("teleport")
			teleporter.handle_prisoner(usr)
			return TRUE

	return FALSE


/// Gets wanted status of the teleporter occupant.
/obj/machinery/computer/prisoner/gulag_teleporter_computer/proc/get_wanted_status(mob/prisoner)
	if(!ishuman(prisoner) || isnull(GLOB.manifest.general))
		return

	for(var/datum/record/crew/record as anything in GLOB.manifest.general)
		if(record.name == prisoner.name)
			return record.wanted_status


/// Resets the teleporter ref if needed.
/obj/machinery/computer/prisoner/gulag_teleporter_computer/proc/find_teleporter()
	var/obj/machinery/gulag_teleporter/teleporter = teleporter_ref?.resolve()
	if(!QDELETED(teleporter))
		return FALSE

	for(var/direction in GLOB.cardinals)
		teleporter = locate(/obj/machinery/gulag_teleporter, get_step(src, direction))
		if(teleporter?.is_operational)
			teleporter_ref = WEAKREF(teleporter)

	return TRUE

