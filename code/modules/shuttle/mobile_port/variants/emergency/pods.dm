// THIS FILE CONTAINS: Pod mobile/stationary docking port, pod control console, pod storage and pod items

/obj/docking_port/mobile/pod
	name = "escape pod"
	shuttle_id = "pod"
	launch_status = UNLAUNCHED

/obj/docking_port/mobile/pod/request(obj/docking_port/stationary/S)
	var/obj/machinery/computer/shuttle/connected_computer = get_control_console()
	if(!istype(connected_computer, /obj/machinery/computer/shuttle/pod))
		return FALSE
	if(!(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED) && !(connected_computer.obj_flags & EMAGGED))
		to_chat(usr, span_warning("Escape pods will only launch during \"Code Red\" security alert."))
		return FALSE
	if(launch_status == UNLAUNCHED)
		launch_status = EARLY_LAUNCHED
		return ..()

/obj/docking_port/mobile/pod/cancel()
	return

/obj/machinery/computer/shuttle/pod
	name = "pod control computer"
	locked = TRUE
	possible_destinations = "pod_asteroid"
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "pod_off"
	circuit = /obj/item/circuitboard/computer/emergency_pod
	light_color = LIGHT_COLOR_BLUE
	density = FALSE
	icon_keyboard = null
	icon_screen = "pod_on"

	var/capacity = -1

// /obj/machinery/computer/shuttle/pod/Initialize(mapload)
// 	. = ..()
// 	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(check_lock))

/obj/machinery/computer/shuttle/pod/examine(mob/user)
	. = ..()
	if(capacity != -1)
		. += span_notice("This pod can hold up to <b>[capacity]</b> passengers.")
		. += span_smallnotice("&bull; Capacity is calculated by the size of every living passenger, including animals and silicon lifeforms.")
		. += span_smallnotice("&bull; Passengers in sleepers or cryopods do not count towards this limit.")
		. += span_smallnotice("&bull; Pets and animals also do not count towards the limit if held.")

/obj/machinery/computer/shuttle/pod/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	locked = FALSE
	balloon_alert(user, "alert level checking disabled")
	icon_screen = "emagged_general"
	update_appearance()
	return TRUE

// /obj/machinery/computer/shuttle/pod/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
// 	. = ..()
// 	if(port)
// 		//Checks if the computer has already added the shuttle destination with the initial id
// 		//This has to be done because connect_to_shuttle is called again after its ID is updated
// 		//due to conflicting id names
// 		var/base_shuttle_destination = ";[initial(port.shuttle_id)]_lavaland"
// 		var/shuttle_destination = ";[port.shuttle_id]_lavaland"

// 		var/position = findtext(possible_destinations, base_shuttle_destination)
// 		if(position)
// 			if(base_shuttle_destination == shuttle_destination)
// 				return
// 			possible_destinations = splicetext(possible_destinations, position, position + length(base_shuttle_destination), shuttle_destination)
// 			return

// 		possible_destinations += shuttle_destination

/obj/machinery/computer/shuttle/pod/get_valid_destinations()
	return list(list(
		"id" = "n/a",
		"name" = "Launch",
	))

/obj/machinery/computer/shuttle/pod/send_shuttle(dest_id, mob/user)
	if(!launch_check(user))
		return SHUTTLE_CONSOLE_ACCESSDENIED
	var/obj/docking_port/mobile/shuttle_port = SSshuttle.getShuttle(shuttleId)
	if(shuttle_port.launch_status == ENDGAME_LAUNCHED)
		return SHUTTLE_CONSOLE_ENDGAME
	if(shuttle_port.mode != SHUTTLE_IDLE)
		return SHUTTLE_CONSOLE_INTRANSIT

	var/human_count = 0
	// holy o^3 proc batman
	for(var/area/shuttle_area as anything in shuttle_port.shuttle_areas)
		for(var/turf/shuttle_turf as anything in shuttle_area.get_turfs_from_all_zlevels())
			for(var/mob/living/stowaway in shuttle_turf)
				if(stowaway.stat == DEAD || (isnull(stowaway.mind) && isnull(stowaway.ai_controller)))
					continue
				human_count += stowaway.mob_size * 0.5

	if(human_count > capacity)
		say("Maximum shuttle capacity reached. Launch aborted.")
		return SHUTTLE_CONSOLE_ERROR
	if(human_count == 0)
		say("No passengers detected. Launch aborted.")
		return SHUTTLE_CONSOLE_ERROR

	for(var/area/shuttle_area as anything in shuttle_port.shuttle_areas)
		for(var/turf/shuttle_turf as anything in shuttle_area.get_turfs_from_all_zlevels())
			for(var/obj/machinery/door/airlock/door in shuttle_turf)
				door.bolt()

	if(!EMERGENCY_PAST_POINT_OF_NO_RETURN)
		minor_announce(
			message = "Pod launch initiated: [capitalize(shuttle_port.name)] away.",
			title = "Alert:",
			alert = TRUE,
			color_override = "orange",
		)

	addtimer(CALLBACK(src, PROC_REF(really_launch)), 10 SECONDS)
	say("Launch initiated.")
	shuttle_port.mode = SHUTTLE_IGNITING
	shuttle_port.hyperspace_sound(HYPERSPACE_WARMUP)
	return SHUTTLE_CONSOLE_SUCCESS

/// Launches the shuttle
/obj/machinery/computer/shuttle/pod/proc/really_launch()
	var/obj/docking_port/mobile/shuttle_port = SSshuttle.getShuttle(shuttleId)
	if(shuttle_port.mode != SHUTTLE_IGNITING)
		return

	shuttle_port.mode = SHUTTLE_ESCAPE
	shuttle_port.launch_status = ENDGAME_LAUNCHED
	shuttle_port.hyperspace_sound(HYPERSPACE_LAUNCH)
	shuttle_port.enterTransit()
	addtimer(CALLBACK(src, PROC_REF(immersion_break)), 0.5 MINUTES)
	if(EMERGENCY_IDLE_OR_RECALLED)
		addtimer(CALLBACK(src, PROC_REF(sunset)), 3.5 MINUTES)

/obj/machinery/computer/shuttle/pod/proc/immersion_break()
	var/msg = "You have escaped [station_name()]! You officially count as 'escaped alive' for objectives.\n\n"
	switch(SSshuttle.abandon_ship_state)
		if(ABANDON_SHIP_ESCAPE)
			msg += "The round will end in roughly [DisplayTimeText(timeleft(SSshuttle.abandon_ship_timer), 10)]. \
				EORG is NOT permitted until then - feel free to continue roleplaying, or ghost to observe any survivors."
		if(ABANDON_SHIP_UNLOCK, ABANDON_SHIP_LAUNCH)
			msg += "The round will end in roughly [DisplayTimeText(3 MINUTES + timeleft(SSshuttle.abandon_ship_timer), 10)]. \
				EORG is NOT permitted until then - feel free to continue roleplaying, or ghost to observe any survivors."
		else
			msg += "You will be despawned in roughly 3 minutes. \
				EORG is NOT permitted while you wait - feel free to continue roleplaying, or ghost to observe any survivors."

	var/obj/docking_port/mobile/shuttle_port = SSshuttle.getShuttle(shuttleId)
	for(var/area/shuttle_area as anything in shuttle_port.shuttle_areas)
		for(var/turf/shuttle_turf as anything in shuttle_area.get_turfs_from_all_zlevels())
			for(var/mob/living/stowaway in shuttle_turf.get_all_contents())
				stowaway.mind?.force_escaped = TRUE
				to_chat(stowaway, span_boldannounce(boxed_message(msg)))

/obj/machinery/computer/shuttle/pod/proc/sunset()
	var/obj/docking_port/mobile/shuttle_port = SSshuttle.getShuttle(shuttleId)
	shuttle_port.intoTheSunset()

/**
 * Signal handler for checking if we should lock or unlock escape pods accordingly to a newly set security level
 *
 * Arguments:
 * * source The datum source of the signal
 * * new_level The new security level that is in effect
 */
/obj/machinery/computer/shuttle/pod/proc/check_lock(datum/source, new_level)
	SIGNAL_HANDLER

	if(obj_flags & EMAGGED)
		return
	locked = (new_level < SEC_LEVEL_RED)

/obj/docking_port/stationary/random
	name = "escape pod"
	shuttle_id = "pod"
	hidden = TRUE
	override_can_dock_checks = TRUE
	/// The area the pod tries to land at
	var/target_area = /area/lavaland/surface/outdoors
	/// Minimal distance from the map edge, setting this too low can result in shuttle landing on the edge and getting "sliced"
	var/edge_distance = 16

/obj/docking_port/stationary/random/Initialize(mapload)
	. = ..()
	if(!mapload)
		return

	var/list/turfs = get_area_turfs(target_area)
	var/original_len = turfs.len
	while(turfs.len)
		var/turf/picked_turf = pick(turfs)
		if(picked_turf.x<edge_distance || picked_turf.y<edge_distance || (world.maxx+1-picked_turf.x)<edge_distance || (world.maxy+1-picked_turf.y)<edge_distance)
			turfs -= picked_turf
		else
			forceMove(picked_turf)
			return

	// Fallback: couldn't find anything
	WARNING("docking port '[shuttle_id]' could not be randomly placed in [target_area]: of [original_len] turfs, none were suitable")
	return INITIALIZE_HINT_QDEL

/obj/docking_port/stationary/random/icemoon
	target_area = /area/icemoon/surface/outdoors/unexplored/rivers/no_monsters

//Pod suits/pickaxes


/obj/item/clothing/head/helmet/space/orange
	name = "emergency space helmet"
	icon_state = "syndicate-helm-orange"
	inhand_icon_state = "syndicate-helm-orange"

/obj/item/clothing/suit/space/orange
	name = "emergency space suit"
	icon_state = "syndicate-orange"
	inhand_icon_state = "syndicate-orange"
	slowdown = 3

/obj/item/pickaxe/emergency
	name = "emergency disembarkation tool"
	desc = "For extracting yourself from rough landings."

/obj/item/storage/pod
	name = "emergency space suits"
	desc = "A wall mounted safe containing space suits. Will only open in emergencies."
	anchored = TRUE
	density = FALSE
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "wall_safe_locked"
	storage_type = /datum/storage/pod

/obj/item/storage/pod/update_icon_state()
	. = ..()
	icon_state = "wall_safe[atom_storage?.locked ? "_locked" : ""]"

MAPPING_DIRECTIONAL_HELPERS(/obj/item/storage/pod, 32)

/obj/item/storage/pod/PopulateContents()
	new /obj/item/clothing/head/helmet/space/orange(src)
	new /obj/item/clothing/head/helmet/space/orange(src)
	new /obj/item/clothing/suit/space/orange(src)
	new /obj/item/clothing/suit/space/orange(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/pickaxe/emergency(src)
	new /obj/item/pickaxe/emergency(src)
	new /obj/item/survivalcapsule(src)
	new /obj/item/storage/toolbox/emergency(src)
	new /obj/item/bodybag/environmental(src)
	new /obj/item/bodybag/environmental(src)
