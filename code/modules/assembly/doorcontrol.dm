/obj/item/assembly/control
	name = "blast door controller"
	desc = "A small electronic device able to control a blast door remotely."
	icon_state = "control"
	attachable = TRUE
	/// The ID of the blast door electronics to match to the ID of the blast door being used.
	var/id = null
	/// Cooldown of the door's controller. Updates when pressed (activate())
	var/cooldown = FALSE
	var/sync_doors = TRUE

/obj/item/assembly/control/examine(mob/user)
	. = ..()
	if(id)
		. += span_notice("Its channel ID is '[id]'.")

/obj/item/assembly/control/multitool_act(mob/living/user)
	var/change_id = tgui_input_number(user, "Set the door controllers ID", "Door ID", id, 100)
	if(!change_id || QDELETED(user) || QDELETED(src) || !usr.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	id = change_id
	balloon_alert(user, "id changed")
	to_chat(user, span_notice("You change the ID to [id]."))

/obj/item/assembly/control/activate()
	var/openclose
	if(cooldown)
		return
	cooldown = TRUE
	for(var/obj/machinery/door/poddoor/M as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/poddoor))
		if(M.id == src.id)
			if(openclose == null || !sync_doors)
				openclose = M.density
			INVOKE_ASYNC(M, openclose ? TYPE_PROC_REF(/obj/machinery/door/poddoor, open) : TYPE_PROC_REF(/obj/machinery/door/poddoor, close))
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 10)

/obj/item/assembly/control/curtain
	name = "curtain controller"
	desc = "A small electronic device able to control a mechanical curtain remotely."

/obj/item/assembly/control/curtain/examine(mob/user)
	. = ..()
	if(id)
		. += span_notice("Its channel ID is '[id]'.")

/obj/item/assembly/control/curtain/activate()
	var/openclose
	if(cooldown)
		return
	cooldown = TRUE
	for(var/obj/structure/curtain/cloth/fancy/mechanical/M in GLOB.curtains)
		if(M.id == src.id)
			if(openclose == null || !sync_doors)
				openclose = M.density
			INVOKE_ASYNC(M, openclose ? TYPE_PROC_REF(/obj/structure/curtain/cloth/fancy/mechanical, open) : TYPE_PROC_REF(/obj/structure/curtain/cloth/fancy/mechanical, close))
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 5)


/obj/item/assembly/control/airlock
	name = "airlock controller"
	desc = "A small electronic device able to control an airlock remotely."
	id = "badmin" // Set it to null for MEGAFUN.
	var/specialfunctions = OPEN
	/*
	Bitflag, 1= open (OPEN)
				2= idscan (IDSCAN)
				4= bolts (BOLTS)
				8= shock (SHOCK)
				16= door safties (SAFE)
	*/

/obj/item/assembly/control/airlock/activate()
	if(cooldown)
		return
	cooldown = TRUE
	var/doors_need_closing = FALSE
	var/list/obj/machinery/door/airlock/open_or_close = list()
	for(var/obj/machinery/door/airlock/D as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock))
		if(D.id_tag == src.id)
			if(specialfunctions & OPEN)
				open_or_close += D
				if(!D.density)
					doors_need_closing = TRUE
			if(specialfunctions & IDSCAN)
				D.aiDisabledIdScanner = !D.aiDisabledIdScanner
			if(specialfunctions & BOLTS)
				if(!D.wires.is_cut(WIRE_BOLTS) && D.hasPower())
					if(D.locked)
						D.unlock()
					else
						D.lock()
					D.update_appearance()
			if(specialfunctions & SHOCK)
				if(D.secondsElectrified)
					D.set_electrified(MACHINE_ELECTRIFIED_PERMANENT, usr)
				else
					D.set_electrified(MACHINE_NOT_ELECTRIFIED, usr)
			if(specialfunctions & SAFE)
				D.safe = !D.safe

	for(var/D in open_or_close)
		INVOKE_ASYNC(D,  doors_need_closing ? TYPE_PROC_REF(/obj/machinery/door/airlock, close) : TYPE_PROC_REF(/obj/machinery/door/airlock, open))

	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 10)


/obj/item/assembly/control/massdriver
	name = "mass driver controller"
	desc = "A small electronic device able to control a mass driver."

/obj/item/assembly/control/massdriver/activate()
	if(cooldown)
		return
	cooldown = TRUE
	for(var/obj/machinery/door/poddoor/M as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/poddoor))
		if (M.id == src.id)
			INVOKE_ASYNC(M, TYPE_PROC_REF(/obj/machinery/door/poddoor, open))

	addtimer(CALLBACK(src, PROC_REF(activate_stage2)), 1 SECONDS)

/obj/item/assembly/control/massdriver/proc/activate_stage2()
	for(var/obj/machinery/mass_driver/M as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/mass_driver))
		if(M.id == src.id)
			M.drive()

	addtimer(CALLBACK(src, PROC_REF(activate_stage3)), 6 SECONDS)

/obj/item/assembly/control/massdriver/proc/activate_stage3()
	for(var/obj/machinery/door/poddoor/M as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/poddoor))
		if (M.id == src.id)
			INVOKE_ASYNC(M, TYPE_PROC_REF(/obj/machinery/door/poddoor, close))

	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 10)


/obj/item/assembly/control/igniter
	name = "ignition controller"
	desc = "A remote controller for a mounted igniter."

/obj/item/assembly/control/igniter/activate()
	if(cooldown)
		return
	cooldown = TRUE
	for(var/obj/machinery/sparker/M as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/sparker))
		if (M.id == src.id)
			INVOKE_ASYNC(M, TYPE_PROC_REF(/obj/machinery/sparker, ignite))

	for(var/obj/machinery/igniter/M as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/igniter))
		if(M.id == src.id)
			INVOKE_ASYNC(M, TYPE_PROC_REF(/obj/machinery/igniter, toggle))

	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 30)

/obj/item/assembly/control/flasher
	name = "flasher controller"
	desc = "A remote controller for a mounted flasher."

/obj/item/assembly/control/flasher/activate()
	if(cooldown)
		return
	cooldown = TRUE
	for(var/obj/machinery/flasher/M as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/flasher))
		if(M.id == src.id)
			INVOKE_ASYNC(M, TYPE_PROC_REF(/obj/machinery/flasher, flash))

	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 50)


/obj/item/assembly/control/crematorium
	name = "crematorium controller"
	desc = "An evil-looking remote controller for a crematorium."

/obj/item/assembly/control/crematorium/activate()
	if(cooldown)
		return
	cooldown = TRUE
	for (var/obj/structure/bodycontainer/crematorium/C in GLOB.crematoriums)
		if (C.id == id)
			C.cremate(usr)

	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 50)

/obj/item/assembly/control/tram
	name = "tram call button"
	desc = "A small device used to bring trams to you."
	///for finding the landmark initially - should be the exact same as the landmark's destination id.
	var/initial_id
	///ID to link to allow us to link to one specific tram in the world
	var/specific_lift_id = MAIN_STATION_TRAM
	///this is our destination's landmark, so we only have to find it the first time.
	var/datum/weakref/destination_platform

/obj/item/assembly/control/tram/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/assembly/control/tram/LateInitialize()
	. = ..()
	//find where the tram needs to go to (our destination). only needs to happen the first time
	for(var/obj/effect/landmark/tram/our_destination as anything in GLOB.tram_landmarks[specific_lift_id])
		if(our_destination.platform_code == initial_id)
			destination_platform = WEAKREF(our_destination)
			break

/obj/item/assembly/control/tram/Destroy()
	destination_platform = null
	return ..()

/obj/item/assembly/control/tram/activate()
	if(cooldown)
		return
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 2 SECONDS)

	var/datum/lift_master/tram/tram
	for(var/datum/lift_master/tram/possible_match as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(possible_match.specific_lift_id == specific_lift_id)
			tram = possible_match
			break

	if(!tram || !tram.is_operational) //tram is QDEL or has no power
		say("The tram is not in service. Please send a technician to repair the internals of the tram.")
		return
	if(tram.travelling) //already on its way
		say("The tram is already travelling to [tram.idle_platform].")
		return
	if(tram.controls_locked) //attempting a dispatch or on cooldown
		say("The tram controller is busy. Try again in a moment.")
		return
	if(!destination_platform)
		return
	var/obj/effect/landmark/tram/current_location = destination_platform.resolve()
	if(!current_location)
		return
	if(tram.idle_platform == current_location) //already here
		say("The tram is already here. Please board the tram and select a destination.")
		return

	if(tram.tram_travel(current_location))
		say("The tram has been called to [current_location.name]. Please wait for its arrival.")
		return
	else
		say("The tram controller has encountered an error. Try again in a moment.")
