#define DEFAULT_JOB_SLOT_ADJUSTMENT_COOLDOWN 2 MINUTES

/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 *
 * Now it's only used for spawning and managing job slots.
 * Hope it was worth it
 */
GLOBAL_LIST_EMPTY(cryopod_computers)

//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "An interface between crew and the cryogenic storage oversight systems."
	icon = 'voidcrew/modules/cryo/icons/cryogenic.dmi'
	icon_keyboard = null
	icon_state = "cellconsole_1"
	// circuit = /obj/item/circuitboard/cryopodcontrol
	density = FALSE
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF

	/// The ship object representing the ship that this console is on.
//	var/obj/structure/overmap/ship/linked_ship //voidcrew todo: ship functionality

/obj/machinery/computer/cryopod/Initialize()
	. = ..()
	GLOB.cryopod_computers += src

/obj/machinery/computer/cryopod/Destroy()
	GLOB.cryopod_computers -= src
	return ..()

/obj/machinery/computer/cryopod/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CryoStorageConsole", name)
		ui.open()

/* //voidcrew todo: ship functionality
/obj/machinery/computer/cryopod/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	. = ..()
	linked_ship = port.current_ship

/obj/machinery/computer/cryopod/ui_act(action, list/params)
	. = ..()
	if(.)
		return TRUE
	var/mob/user = usr

	add_fingerprint(user)

	switch(action)
		if("toggleAwakening")
			linked_ship.join_allowed = !linked_ship.join_allowed
			return

		if("setMemo")
			if(!("newName" in params) || params["newName"] == linked_ship.memo)
				return
			linked_ship.memo = params["newName"]
			return

		if("adjustJobSlot")
			if(!("toAdjust" in params) || !("delta" in params) || !COOLDOWN_FINISHED(linked_ship, job_slot_adjustment_cooldown))
				return
			var/datum/job/target_job = locate(params["toAdjust"])
			if(!target_job)
				return
			if(linked_ship.job_slots[target_job] + params["delta"] < 0 || linked_ship.job_slots[target_job] + params["delta"] > 4)
				return
			linked_ship.job_slots[target_job] += params["delta"]
			linked_ship.job_slot_adjustment_cooldown = world.time + DEFAULT_JOB_SLOT_ADJUSTMENT_COOLDOWN
			update_static_data(user)
			return

/obj/machinery/computer/cryopod/ui_data(mob/user)
	var/list/data = list()
	data["awakening"] = linked_ship.join_allowed
	data["cooldown"] = linked_ship.job_slot_adjustment_cooldown - world.time
	data["memo"] = linked_ship.memo
	return data

/obj/machinery/computer/cryopod/ui_static_data(mob/user)
	var/list/data = list()
	data["jobs"] = list()
	for(var/datum/job/ship_jobs as anything in linked_ship.job_slots)
		if(ship_jobs.officer)
			continue
		data["jobs"] += list(list(
			name = ship_jobs.title,
			slots = linked_ship.job_slots[ship_jobs],
			ref = REF(ship_jobs),
			max = linked_ship.source_template.job_slots[ship_jobs] * 2
		))

	return data
*/
#undef DEFAULT_JOB_SLOT_ADJUSTMENT_COOLDOWN
