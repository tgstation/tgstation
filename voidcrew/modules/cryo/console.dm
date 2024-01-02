#define DEFAULT_JOB_SLOT_ADJUSTMENT_COOLDOWN (2 MINUTES)

//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "An interface between crew and the cryogenic storage oversight systems."
	icon = 'voidcrew/modules/cryo/icons/cryogenic.dmi'
	icon_state = "cellconsole_1"
	icon_keyboard = null
	icon_screen = null
	density = FALSE
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF

	/// The ship object representing the ship that this console is on.
	var/obj/docking_port/mobile/voidcrew/linked_port

/obj/machinery/computer/cryopod/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CryoStorageConsole", name)
		ui.open()

/obj/machinery/computer/cryopod/connect_to_shuttle(mapload, obj/docking_port/mobile/voidcrew/port, obj/docking_port/stationary/dock)
	. = ..()
	linked_port = port

/obj/machinery/computer/cryopod/ui_data(mob/user)
	var/list/data = ..()

	data["awakening"] = linked_port.current_ship.joining_allowed
	data["cooldown"] = (COOLDOWN_TIMELEFT(linked_port.current_ship, job_slot_adjustment_cooldown) / 10)
	data["memo"] = linked_port.current_ship.memo

	return data

/obj/machinery/computer/cryopod/ui_static_data(mob/user)
	var/list/data = ..()
	data["jobs"] = list()

	for(var/datum/job/ship_jobs as anything in linked_port.current_ship.job_slots)
		if(ship_jobs.officer)
			continue
		data["jobs"] += list(list(
			name = ship_jobs.title,
			slots = linked_port.current_ship.job_slots[ship_jobs],
			ref = REF(ship_jobs),
			max = linked_port.current_ship.source_template.job_slots[ship_jobs] * 2,
		))

	return data

/obj/machinery/computer/cryopod/ui_act(action, list/params)
	. = ..()
	if(.)
		return TRUE

	switch(action)
		if("toggleAwakening")
			linked_port.current_ship.joining_allowed = !linked_port.current_ship.joining_allowed
		if("setMemo")
			if(!("newName" in params) || params["newName"] == linked_port.current_ship.memo)
				return
			linked_port.current_ship.memo = params["newName"]

		if("adjustJobSlot")
			if(!("toAdjust" in params) || !("delta" in params) || !COOLDOWN_FINISHED(linked_port.current_ship, job_slot_adjustment_cooldown))
				return
			var/datum/job/target_job = locate(params["toAdjust"])
			if(!target_job)
				return
			if(linked_port.current_ship.job_slots[target_job] + params["delta"] < 0 || linked_port.current_ship.job_slots[target_job] + params["delta"] > 4)
				return
			linked_port.current_ship.job_slots[target_job] += params["delta"]
			COOLDOWN_START(linked_port.current_ship, job_slot_adjustment_cooldown, DEFAULT_JOB_SLOT_ADJUSTMENT_COOLDOWN)
			update_static_data(usr)

#undef DEFAULT_JOB_SLOT_ADJUSTMENT_COOLDOWN
