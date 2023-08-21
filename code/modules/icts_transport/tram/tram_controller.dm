/**
 * Tram specific variant of the generic linear transport controller.
 *
 * Hierarchy
 * The ssICTS_transport subsystem manages a list of controllers,
 * A controller manages a list of transport modules (individual tiles) which together make up a transport unit (in this case a tram)
 */
/datum/transport_controller/linear/tram

	///whether this controller is active (any state we don't accept new orders, not nessecarily moving)
	var/controller_active = FALSE
	///whether all required parts of the tram are considered operational
	var/controller_operational = TRUE
	///if we're travelling, what direction are we going
	var/travel_direction = NONE
	///if we're travelling, how far do we have to go
	var/travel_remaining = 0
	///how far in total we'll be travelling
	var/travel_trip_length = 0

	///multiplier on how much damage/force the tram imparts on things it hits
	var/collision_lethality = 1

	/// reference to the destination landmarks we consider ourselves "at" or travelling towards. since we potentially span multiple z levels we dont actually
	/// know where on us this platform is. as long as we know THAT its on us we can just move the distance and direction between this
	/// and the destination landmark.
	var/obj/effect/landmark/icts/nav_beacon/tram/idle_platform
	/// reference to the destination landmarks we consider ourselves travelling towards. since we potentially span multiple z levels we dont actually
	/// know where on us this platform is. as long as we know THAT its on us we can just move the distance and direction between this
	/// and the destination landmark.
	var/obj/effect/landmark/icts/nav_beacon/tram/destination_platform

	var/current_speed = 0
	var/current_load = 0

	///decisecond delay between horizontal movement. cannot make the tram move faster than 1 movement per world.tick_lag.
	var/speed_limiter = 0.5

	///version of speed_limiter that gets set in init and is considered our base speed if our lift gets slowed down
	var/base_speed_limiter = 0.5

	///the world.time we should next move at. in case our speed is set to less than 1 movement per tick
	var/scheduled_move = INFINITY

	///whether we have been slowed down automatically
	var/recovery_mode = FALSE

	///how many times we moved while costing more than SSicts_transport.max_time milliseconds per movement.
	///if this exceeds SSicts_transport.max_exceeding_moves
	var/recovery_activate_count = 0

	///how many times we moved while costing less than 0.5 * SSicts_transport.max_time milliseconds per movement
	var/recovery_clear_count = 0

	var/datum/tram_mfg_info/tram_registration

	var/obj/machinery/icts/controller/control_panel

/datum/tram_mfg_info
	var/serial_number
	var/mfg_date
	var/install_location
	var/distance_travelled = 0
	var/collisions = 0

/**
 * Assign registration details to a new tram.
 *
 * When a new tram is created, we give it a builder's plate with the date it was created.
 * We track a few stats about it, and keep a small historical record on the
 * information plate inside the tram.
 */
/datum/tram_mfg_info/New(specific_transport_id)
	if(GLOB.round_id)
		serial_number = "LT306TG[add_leading(GLOB.round_id, 6, 0)]"
	else
		serial_number = "LT306TG[rand(000000, 999999)]"
	mfg_date = world.realtime
	install_location = specific_transport_id

/**
 * Loads persistent tram data from the JSON save file on initialization.
 */
/datum/tram_mfg_info/proc/load_data(list/tram_data)
	serial_number = text2path(tram_data["serial_number"])
	mfg_date = text2path(tram_data["mfg_date"])
	install_location = text2path(tram_data["install_location"])
	distance_travelled = text2path(tram_data["distance_travelled"])
	collisions = text2path(tram_data["collisions"])
	return TRUE

/**
 * Provide JSON formatted data to the persistence subsystem to save at round end.
 */
/datum/transport_controller/linear/tram/proc/get_json_data()
	. = list()
	.["serial_number"] = tram_registration.serial_number
	.["mfg_date"] = tram_registration.mfg_date
	.["install_location"] = tram_registration.install_location
	.["distance_travelled"] = tram_registration.distance_travelled
	.["collisions"] = tram_registration.collisions

/**
 * Make sure all modules have matching speed limiter vars, pull save data from persistence
 *
 * We track a few stats about it, and keep a small historical record on the
 * information plate inside the tram.
 */
/datum/transport_controller/linear/tram/New(obj/structure/transport/linear/tram/transport_module)
	. = ..()
	speed_limiter = transport_module.speed_limiter
	base_speed_limiter = transport_module.speed_limiter
	tram_registration = SSpersistence.load_tram_stats(specific_transport_id)

	if(!tram_registration)
		tram_registration = new /datum/tram_mfg_info(specific_transport_id)

	check_starting_landmark()

/**
 * If someone VVs the base speed limiter of the tram, copy it to the current active speed limiter.
 */
/datum/transport_controller/linear/tram/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == "base_speed_limiter")
		speed_limiter = max(speed_limiter, base_speed_limiter)

/**
 * Register transport modules to the controller
 *
 * Spreads out searching neighbouring tiles for additional transport modules, to combine into one full tram.
 * We register to every module's signal that it's collided with something, be it mob, structure, etc.
 */
/datum/transport_controller/linear/tram/add_transport_modules(obj/structure/transport/linear/new_transport_module)
	. = ..()
	RegisterSignal(new_transport_module, COMSIG_MOVABLE_BUMP, PROC_REF(gracefully_break))

/**
 * The mapper should have placed the tram at one of the stations, the controller will search for a landmark within
 * its control area and set it as its idle position.
 */
/datum/transport_controller/linear/tram/check_for_landmarks(obj/structure/transport/linear/tram/new_transport_module)
	. = ..()
	for(var/turf/platform_loc as anything in new_transport_module.locs)
		var/obj/effect/landmark/icts/nav_beacon/tram/initial_destination = locate() in platform_loc

		if(initial_destination)
			idle_platform = initial_destination

/**
 * Verify tram is in a valid starting location, start the subsystem.
 *
 * Throw an error if someone mapped a tram with no landmarks available for it to register.
 * The processing subsystem starts off because not all maps have elevators/transports.
 * Now that the tram is aware of its surroundings, we start the subsystem.
 */
/datum/transport_controller/linear/tram/proc/check_starting_landmark()
	if(!idle_platform)
		CRASH("a tram transport_controller was initialized without any tram landmark to give it direction!")

	SSicts_transport.can_fire = TRUE

	return TRUE

/**
 * The tram explodes if it hits a few types of objects.
 *
 * Signal for when the tram runs into a field of which it cannot go through.
 * Stops the train's travel fully, sends a message, and destroys the train.
 * Arguments:
 * * bumped_atom - The atom this tram bumped into
 */
/datum/transport_controller/linear/tram/proc/gracefully_break(atom/bumped_atom)
	SIGNAL_HANDLER

	travel_remaining = 0
	bumped_atom.visible_message(span_userdanger("The [bumped_atom.name] crashes into the field violently!"))
	for(var/obj/structure/transport/linear/tram/transport_module as anything in transport_modules)
		transport_module.set_travelling(FALSE)
		for(var/explosive_target in transport_module.transport_contents)
			if(iseffect(explosive_target))
				continue

			if(isliving(explosive_target))
				explosion(explosive_target, devastation_range = rand(0, 1), heavy_impact_range = 2, light_impact_range = 3) //50% chance of gib

			else if(prob(9))
				explosion(explosive_target, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3)

			explosion(transport_module, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3)
			qdel(transport_module)

		for(var/obj/machinery/icts/destination_sign/desto as anything in SSicts_transport.displays)
			desto.icon_state = "[desto.base_icon_state][DESTINATION_NOT_IN_SERVICE]"

		for(var/obj/machinery/icts/crossing_signal/xing as anything in SSicts_transport.crossing_signals)
			xing.set_signal_state(XING_STATE_MALF)
			xing.update_appearance()

/**
 * Calculate the journey details to the requested platform
 *
 * These will eventually be passed to the transport modules as args telling them where to move.
 * We do some sanity checking in case of discrepencany between where the subsystem thinks the
 * tram is and where the tram actually is. (For example, moving the landmarks after round start.)
 *
 * TODO: the message_admins is just for debugging. remove before PRing. ideally the tram will
 * self-recover with the SYSTEM_FAULT operational status if it finds a mismatch between subsystem
 * and controller.
 */
/datum/transport_controller/linear/tram/proc/calculate_route(obj/effect/landmark/icts/nav_beacon/tram/destination)
	if(destination == idle_platform)
		return FALSE

	destination_platform = destination
	travel_direction = get_dir(idle_platform, destination_platform)
	travel_remaining = get_dist(idle_platform, destination_platform)
	var/physical_dist = get_dist(get_turf(transport_modules[1]), destination_platform)
	if(physical_dist != travel_remaining + (DEFAULT_TRAM_LENGTH * 0.5) && physical_dist != travel_remaining - (DEFAULT_TRAM_LENGTH * 0.5))
		message_admins("ICTS: WARNING! Calculated trip of [travel_remaining] doesn't match validation of [physical_dist]!")
	travel_trip_length = travel_remaining
	return TRUE

/**
 * Handles moving the tram
 *
 * Called by the subsystem, the controller tells the individual tram parts where to actually go and has extra safety checks
 * incase multiple inputs get through, preventing conflicting directions and the tram literally ripping itself apart.
 * All of the actual movement is handled by SSicts_transport.
 *
 * If we're this far all the PRE_DEPARTURE checks should have passed, so we leave the PRE_DEPARTURE status and actually move.
 * We send a signal to anything registered that cares about the physical movement of the tram.
 *
 * Arguments:
 * * destination_platform - where the subsystem wants it to go
 */

/datum/transport_controller/linear/tram/proc/dispatch_transport(obj/effect/landmark/icts/nav_beacon/tram/destination_platform)
	set_status_code(PRE_DEPARTURE, FALSE)
	SEND_SIGNAL(src, COMSIG_TRAM_TRAVEL, idle_platform, destination_platform)

	for(var/obj/structure/transport/linear/tram/transport_module as anything in transport_modules) //only thing everyone needs to know is the new location.
		if(transport_module.travelling) //wee woo wee woo there was a double action queued. damn multi tile structs
			return //we don't care to undo cover_locked controls, though, as that will resolve itself
		transport_module.glide_size_override = DELAY_TO_GLIDE_SIZE(speed_limiter)
		transport_module.set_travelling(TRUE)

	scheduled_move = world.time + speed_limiter

	START_PROCESSING(SSicts_transport, src)

/**
 * Tram processing loop
 *
 * Moves the tram to its set destination.
 * When it arrives at its destination perform callback to the post-arrival procs like controls and lights.
 * We update the odometer and kill the process until we need to move again.area
 *
 * TODO: If the status is EMERGENCY_STOP the tram should immediately come to a stop regardless of the
 * travel_remaining. Some extra things happen in an emergency stop (throwing the passengers) and it will
 * run a recovery procedure to head to the nearest platform and 'reset' once the issue is resolved.
 */
/datum/transport_controller/linear/tram/process(seconds_per_tick)
	if(!travel_remaining)
		if(!controller_operational)
			degraded_stop()
			return PROCESS_KILL
		normal_stop()
		return PROCESS_KILL

	else if(world.time >= scheduled_move)
		var/start_time = TICK_USAGE
		travel_remaining--

		move_transport_horizontally(travel_direction)

		var/duration = TICK_USAGE_TO_MS(start_time)
		current_load = duration
		current_speed = transport_modules[1].glide_size
		if(recovery_mode)
			if(duration <= (SSicts_transport.max_time / 2))
				recovery_clear_count++
			else
				recovery_clear_count = 0

			if(recovery_clear_count >= SSicts_transport.max_cheap_moves)
				speed_limiter = base_speed_limiter
				recovery_mode = FALSE
				recovery_clear_count = 0

		else if(duration > SSicts_transport.max_time)
			recovery_activate_count++

			if(recovery_activate_count >= SSicts_transport.max_exceeding_moves)
				message_admins("The tram at [ADMIN_JMP(transport_modules[1])] is taking more than [SSicts_transport.max_time] milliseconds per movement, halving its movement speed. if this continues to be a problem you can call reset_lift_contents() on the trams transport_controller_datum to reset it to its original state and clear added objects")
				speed_limiter = base_speed_limiter * 2 //halves its speed
				recovery_mode = TRUE
				recovery_activate_count = 0
		else
			recovery_activate_count = max(recovery_activate_count - 1, 0)

		scheduled_move = world.time + speed_limiter

/datum/transport_controller/linear/tram/proc/normal_stop()
	cycle_doors(OPEN_DOORS)
	addtimer(CALLBACK(src, PROC_REF(unlock_controls)), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_lights)), 2.2 SECONDS)
	idle_platform = destination_platform
	tram_registration.distance_travelled += (travel_trip_length - travel_remaining)
	travel_trip_length = 0
	current_speed = 0
	current_load = 0

/datum/transport_controller/linear/tram/proc/degraded_stop()
	addtimer(CALLBACK(src, PROC_REF(unlock_controls)), 4 SECONDS)
	set_lights(estop = TRUE)
	idle_platform = destination_platform
	tram_registration.distance_travelled += (travel_trip_length - travel_remaining)
	travel_trip_length = 0
	current_speed = 0
	current_load = 0
	var/throw_direction = travel_direction
	for(var/obj/structure/transport/linear/tram/module in transport_modules)
		module.estop_throw(throw_direction)

/**
 * Handles unlocking the tram controls for use after moving
 *
 * More safety checks to make sure the tram has actually docked properly
 * at a location before users are allowed to interact with the tram console again.
 * Tram finds its location at this point before fully unlocking controls to the user.
 */
/datum/transport_controller/linear/tram/proc/unlock_controls()
	controls_lock(FALSE)
	for(var/obj/structure/transport/linear/tram/transport_module as anything in transport_modules) //only thing everyone needs to know is the new location.
		transport_module.set_travelling(FALSE)
	set_active(FALSE)

/**
 * Send a signal to any lights associated with the tram so they can change based on the status and direction.
 */
/datum/transport_controller/linear/tram/proc/set_lights(estop = FALSE)
	SEND_SIGNAL(src, COMSIG_ICTS_TRANSPORT_LIGHTS, controller_active, controller_status, travel_direction, estop)

/**
 * Sets the active status for the controller and sends a signal to listeners.
 *
 * The main signal used by most components, it has the active status, the bitfield of the controller's status, its direction, and set destination.
 *
 * Arguments:
 * new_status - The active status of the controller (whether it's busy doing something and not taking commands right now)
 */
/datum/transport_controller/linear/tram/proc/set_active(new_status)
	if(controller_active == new_status)
		return

	controller_active = new_status
	SEND_ICTS_SIGNAL(COMSIG_ICTS_TRANSPORT_ACTIVE, src, controller_active, controller_status, travel_direction, destination_platform)

/**
 * Sets the controller status bitfield
 *
 * This status var is used by various components like lights, crossing signals, signs
 * Sent via signal the listening components will perform required actions based on
 * the status codes.
 *
 * Arguments:
 * * code - The status bitflag we're changing
 * * value - boolean TRUE/FALSE to set the code
 */
/datum/transport_controller/linear/tram/proc/set_status_code(code, value)
	switch(value)
		if(TRUE)
			controller_status |= code
		if(FALSE)
			controller_status &= ~code
		else
			stack_trace("Transport controller received invalid status code request [code]/[value]")
			return

	SEND_ICTS_SIGNAL(COMSIG_ICTS_TRANSPORT_ACTIVE, src, controller_active, controller_status, travel_direction, destination_platform)

/**
 * Part of the pre-departure list, checks the status of the doors on the tram
 *
 * Checks if all doors are closed, and updates the status code accordingly.
 *
 * TODO: this is probably better renamed check_door_status()
 */
/datum/transport_controller/linear/tram/proc/update_status()
	set_status_code(DOORS_OPEN, FALSE)
	for(var/obj/machinery/door/airlock/tram/door as anything in SSicts_transport.doors)
		if(door.transport_linked_id == specific_transport_id)
			if(door.airlock_state != 1)
				set_status_code(DOORS_OPEN, TRUE)
				break

/**
 * Cycle all the doors on the tram.
 */
/datum/transport_controller/linear/tram/proc/cycle_doors(door_status)
	switch(door_status)
		if(OPEN_DOORS)
			for(var/obj/machinery/door/airlock/tram/door as anything in SSicts_transport.doors)
				if(door.transport_linked_id == specific_transport_id)
					INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/airlock/tram, open))

		if(CLOSE_DOORS)
			for(var/obj/machinery/door/airlock/tram/door as anything in SSicts_transport.doors)
				if(door.transport_linked_id == specific_transport_id)
					INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/airlock/tram, close))

	update_status()

/datum/transport_controller/linear/tram/proc/notify_controller(obj/machinery/icts/controller/new_controller)
	control_panel = new_controller
	RegisterSignal(new_controller, COMSIG_MACHINERY_POWER_LOST, PROC_REF(power_lost))
	RegisterSignal(new_controller, COMSIG_MACHINERY_POWER_RESTORED, PROC_REF(power_restored))

/**
 * Tram malfunction random event. Set comm error, increase tram lethality.
 */
/datum/transport_controller/linear/tram/proc/start_malf_event()
	set_status_code(SYSTEM_FAULT, TRUE)
	set_status_code(COMM_ERROR, TRUE)
	SEND_ICTS_SIGNAL(COMSIG_COMMS_STATUS, src, FALSE)
	control_panel.generate_repair_signals()
	collision_lethality = 1.25

/**
 * Remove effects of tram malfunction event.
 *
 * If engineers didn't already repair the tram by the end of the event,
 * automagically reset it remotely.
 */
/datum/transport_controller/linear/tram/proc/end_malf_event()
	if(!(controller_status & COMM_ERROR))
		return
	set_status_code(COMM_ERROR, FALSE)
	control_panel.clear_repair_signals()
	collision_lethality = initial(collision_lethality)
	SEND_ICTS_SIGNAL(COMSIG_COMMS_STATUS, src, TRUE)

/datum/transport_controller/linear/tram/proc/register_collision()
	tram_registration.collisions += 1

/datum/transport_controller/linear/tram/proc/power_lost()
	controller_operational = FALSE
	SEND_ICTS_SIGNAL(COMSIG_ICTS_TRANSPORT_ACTIVE, src, controller_active, controller_status, travel_direction, destination_platform)

/datum/transport_controller/linear/tram/proc/power_restored()
	controller_operational = TRUE
	SEND_ICTS_SIGNAL(COMSIG_ICTS_TRANSPORT_ACTIVE, src, controller_active, controller_status, travel_direction, destination_platform)

/**
 * The physical cabinet on the tram. Acts as the interface between players and the controller datum.
 */
/obj/machinery/icts/controller
	name = "tram controller"
	desc = "Makes the tram go, or something."
	icon = 'icons/obj/tram/tram_controllers.dmi'
	icon_state = "controller-panel"
	anchored = TRUE
	density = FALSE
	armor_type = /datum/armor/transport_module
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 1000
	integrity_failure = 0.25
	layer = SIGN_LAYER
	req_access = list(ACCESS_TCOMMS)
	flags_1 = NODECONSTRUCT_1
	circuit = /obj/item/circuitboard/machine/icts_controller
	var/datum/transport_controller/linear/tram/controller_datum
	/// If the cover is open
	var/cover_open = FALSE
	/// If the cover is locked
	var/cover_locked = FALSE

/obj/machinery/icts/controller/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/**
 * Mapped or built tram cabinet isn't located on a transport module.
 */
/obj/machinery/icts/controller/LateInitialize(mapload)
	. = ..()
	if(!find_controller())
		stack_trace("Tram cabinet failed to find controller datum!")

	update_appearance()

/obj/machinery/icts/controller/atom_break()
	var/controller_integrity = get_integrity()
	if(controller_integrity <= 0)
		update_integrity(1)

	set_machine_stat(machine_stat | BROKEN)

	..()

/obj/machinery/icts/controller/attackby(obj/item/weapon, mob/living/user, params)
	if (!user.combat_mode)
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, weapon))
			return

		if(default_deconstruction_crowbar(weapon))
			return

	return ..()

/**
 * Update the blinky lights based on the controller status, allowing to quickly check without opening up the cabinet.
 */
/obj/machinery/icts/controller/update_overlays()
	. = ..()

	if(!cover_open)
		. += mutable_appearance(icon, "controller-closed")

	else
		var/mutable_appearance/controller_door = mutable_appearance(icon, "controller-open")
		controller_door.pixel_w = -3
		. += controller_door

	if(machine_stat & NOPOWER)
		. += mutable_appearance(icon, "estop")
		. += emissive_appearance(icon, "estop", src, alpha = src.alpha)
		return

	. += mutable_appearance(icon, "power")
	. += emissive_appearance(icon, "power", src, alpha = src.alpha)

	if(!controller_datum)
		. += mutable_appearance(icon, "fatal")
		. += emissive_appearance(icon, "fatal", src, alpha = src.alpha)
		return

	if(controller_datum.controller_status & DOORS_OPEN)
		. += mutable_appearance(icon, "doors")
		. += emissive_appearance(icon, "doors", src, alpha = src.alpha)

	if(controller_datum.controller_active)
		. += mutable_appearance(icon, "active")
		. += emissive_appearance(icon, "active", src, alpha = src.alpha)

	if(controller_datum.controller_status & EMERGENCY_STOP)
		. += mutable_appearance(icon, "estop")
		. += emissive_appearance(icon, "estop", src, alpha = src.alpha)

	else if(controller_datum.controller_status & SYSTEM_FAULT)
		. += mutable_appearance(icon, "fault")
		. += emissive_appearance(icon, "fault", src, alpha = src.alpha)

	else if(controller_datum.controller_status & COMM_ERROR)
		. += mutable_appearance(icon, "comms")
		. += emissive_appearance(icon, "comms", src, alpha = src.alpha)

	else
		. += mutable_appearance(icon, "normal")
		. += emissive_appearance(icon, "normal", src, alpha = src.alpha)

/**
 * Find the controller associated with the transport module the cabinet is sitting on.
 */
/obj/machinery/icts/controller/proc/find_controller()
	var/obj/structure/transport/linear/tram/tram_structure = locate() in src.loc
	if(!tram_structure)
		return FALSE

	controller_datum = tram_structure.transport_controller_datum
	if(!controller_datum)
		return FALSE

	controller_datum.notify_controller(src)
	RegisterSignal(SSicts_transport, COMSIG_ICTS_TRANSPORT_ACTIVE, PROC_REF(sync_controller))
	return TRUE

/**
 * Since the machinery obj is a dumb terminal for the controller datum, sync the display with the status bitfield of the tram
 */
/obj/machinery/icts/controller/proc/sync_controller(source, controller, controller_status, travel_direction, destination_platform)
	if(controller != controller_datum)
		return
	update_appearance()

/obj/machinery/icts/controller/attack_hand(mob/living/user, params)
	. = ..()

	if(!cover_open)
		return try_toggle_lock(user)

/obj/machinery/icts/controller/attack_hand_secondary(mob/living/user, params)
	. = ..()

	if(cover_locked)
		return

	if(!cover_open)
		playsound(loc, 'sound/machines/closet_open.ogg', 35, TRUE, -3)
	else
		playsound(loc, 'sound/machines/closet_close.ogg', 50, TRUE, -3)
	cover_open = !cover_open
	update_appearance()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/icts/controller/proc/try_toggle_lock(mob/living/user, item, params)
	if(user.get_idcard() && !cover_open)
		if(allowed(user) && !(obj_flags & EMAGGED))
			cover_locked = !cover_locked
			balloon_alert(user, "controls [cover_locked ? "locked" : "unlocked"]")
			update_appearance()
			return TRUE

		else if(obj_flags & EMAGGED)
			balloon_alert(user, "access controller damaged!")
			return FALSE

		else
			balloon_alert(user, "access denied")
			return FALSE

/obj/machinery/icts/controller/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		balloon_alert(user, "already fried!")
		return FALSE
	obj_flags |= EMAGGED
	cover_locked = FALSE
	playsound(src, SFX_SPARKS, 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(user, "access controller shorted")
	return TRUE


/**
 * Check if the tram was malfunctioning due to the random event, and if so end the event on repair.
 */
/obj/machinery/icts/controller/try_fix_machine(obj/machinery/icts/machine, mob/living/user, obj/item/tool)
	. = ..()

	if(. == FALSE)
		return

	if(!controller_datum)
		return

	controller_datum.end_malf_event()

/obj/machinery/icts/controller/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	if(!is_operational || !cover_open)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ICTSTransportControls")
		ui.open()

/obj/machinery/icts/controller/ui_data(mob/user)
	var/list/data = list()

	data = list(
		"transportId" = controller_datum.specific_transport_id,
		"controllerActive" = controller_datum.controller_active,
		"controllerOperational" = controller_datum.controller_operational,
		"travelDirection" = controller_datum.travel_direction,
		"destinationPlatform" = controller_datum.destination_platform,
		"idlePlatform" = controller_datum.idle_platform,
		"recoveryMode" = controller_datum.recovery_mode,
		"currentSpeed" = controller_datum.current_speed,
		"currentLoad" = controller_datum.current_load,
	)

	return data
