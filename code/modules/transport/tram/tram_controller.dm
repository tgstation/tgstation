/**
 * Tram specific variant of the generic linear transport controller.
 *
 * Hierarchy
 * The sstransport subsystem manages a list of controllers,
 * A controller manages a list of transport modules (individual tiles) which together make up a transport unit (in this case a tram)
 */
/datum/transport_controller/linear/tram
	///whether this controller is active (any state we don't accept new orders, not nessecarily moving)
	var/controller_active = FALSE
	///whether all required parts of the tram are considered operational
	var/controller_operational = TRUE
	var/obj/machinery/transport/tram_controller/paired_cabinet
	///if we're travelling, what direction are we going
	var/travel_direction = NONE
	///if we're travelling, how far do we have to go
	var/travel_remaining = 0
	///how far in total we'll be travelling
	var/travel_trip_length = 0

	///multiplier on how much damage/force the tram imparts on things it hits
	var/collision_lethality = 1
	var/obj/effect/landmark/transport/nav_beacon/tram/nav/nav_beacon
	/// reference to the destination landmarks we consider ourselves "at" or travelling towards. since we potentially span multiple z levels we dont actually
	/// know where on us this platform is. as long as we know THAT its on us we can just move the distance and direction between this
	/// and the destination landmark.
	var/obj/effect/landmark/transport/nav_beacon/tram/platform/idle_platform
	/// reference to the destination landmarks we consider ourselves travelling towards. since we potentially span multiple z levels we dont actually
	/// know where on us this platform is. as long as we know THAT its on us we can just move the distance and direction between this
	/// and the destination landmark.
	var/obj/effect/landmark/transport/nav_beacon/tram/platform/destination_platform

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

	///how many times we moved while costing more than SStransport.max_time milliseconds per movement.
	///if this exceeds SStransport.max_exceeding_moves
	var/recovery_activate_count = 0

	///how many times we moved while costing less than 0.5 * SStransport.max_time milliseconds per movement
	var/recovery_clear_count = 0

	var/datum/tram_mfg_info/tram_registration

	var/list/tram_history

/datum/tram_mfg_info
	var/serial_number
	var/active = TRUE
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
		serial_number = "LT306TG[add_leading(GLOB.round_id, 6, "0")]"
	else
		serial_number = "LT306TG[rand(000000, 999999)]"

	mfg_date = "[CURRENT_STATION_YEAR]-[time2text(world.timeofday, "MM-DD")]"
	install_location = specific_transport_id

/datum/tram_mfg_info/proc/load_from_json(list/json_data)
	serial_number = json_data["serial_number"]
	active = json_data["active"]
	mfg_date = json_data["mfg_date"]
	install_location = json_data["install_location"]
	distance_travelled = json_data["distance_travelled"]
	collisions = json_data["collisions"]

/datum/tram_mfg_info/proc/export_to_json()
	var/list/new_data = list()
	new_data["serial_number"] = serial_number
	new_data["active"] = active
	new_data["mfg_date"] = mfg_date
	new_data["install_location"] = install_location
	new_data["distance_travelled"] = distance_travelled
	new_data["collisions"] = collisions
	return new_data

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
	tram_history = SSpersistence.load_tram_history(specific_transport_id)
	var/datum/tram_mfg_info/previous_tram = peek(tram_history)
	if(!isnull(previous_tram) && previous_tram.active)
		tram_registration = pop(tram_history)
	else
		tram_registration = new /datum/tram_mfg_info(specific_transport_id)

	check_starting_landmark()

/**
 * If someone VVs the base speed limiter of the tram, copy it to the current active speed limiter.
 */
/datum/transport_controller/linear/tram/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == "base_speed_limiter")
		speed_limiter = max(speed_limiter, base_speed_limiter)

/datum/transport_controller/linear/tram/Destroy()
	paired_cabinet = null
	set_status_code(SYSTEM_FAULT, TRUE)
	tram_registration.active = FALSE
	SSblackbox.record_feedback("amount", "tram_destroyed", 1)
	SSpersistence.save_tram_history(specific_transport_id)
	..()

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
		var/obj/effect/landmark/transport/nav_beacon/tram/platform/initial_destination = locate() in platform_loc
		var/obj/effect/landmark/transport/nav_beacon/tram/nav/beacon = locate() in platform_loc

		if(initial_destination)
			idle_platform = initial_destination
			destination_platform = initial_destination

		if(beacon)
			nav_beacon = beacon

/**
 * Verify tram is in a valid starting location, start the subsystem.
 *
 * Throw an error if someone mapped a tram with no landmarks available for it to register.
 * The processing subsystem starts off because not all maps have elevators/transports.
 * Now that the tram is aware of its surroundings, we start the subsystem.
 */
/datum/transport_controller/linear/tram/proc/check_starting_landmark()
	if(!idle_platform || !nav_beacon)
		CRASH("a tram lift_master was initialized without the required landmarks to give it direction!")

	SStransport.can_fire = TRUE

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

		send_transport_active_signal()

/**
 * Calculate the journey details to the requested platform
 *
 * These will eventually be passed to the transport modules as args telling them where to move.
 * We do some sanity checking in case of discrepencany between where the subsystem thinks the
 * tram is and where the tram actually is. (For example, moving the landmarks after round start.)

 */
/datum/transport_controller/linear/tram/proc/calculate_route(obj/effect/landmark/transport/nav_beacon/tram/destination)
	if(destination == idle_platform)
		return FALSE

	destination_platform = destination
	travel_direction = get_dir(nav_beacon, destination_platform)
	travel_remaining = get_dist(nav_beacon, destination_platform)
	travel_trip_length = travel_remaining
	log_transport("TC: [specific_transport_id] trip calculation: src: [nav_beacon.x], [nav_beacon.y], [nav_beacon.z] dst: [destination_platform] [destination_platform.x], [destination_platform.y], [destination_platform.z] = Dir [travel_direction] Dist [travel_remaining].")
	return TRUE

/**
 * Handles moving the tram
 *
 * Called by the subsystem, the controller tells the individual tram parts where to actually go and has extra safety checks
 * incase multiple inputs get through, preventing conflicting directions and the tram literally ripping itself apart.
 * All of the actual movement is handled by SStransport.
 *
 * If we're this far all the PRE_DEPARTURE checks should have passed, so we leave the PRE_DEPARTURE status and actually move.
 * We send a signal to anything registered that cares about the physical movement of the tram.
 *
 * Arguments:
 * * destination_platform - where the subsystem wants it to go
 */

/datum/transport_controller/linear/tram/proc/dispatch_transport(obj/effect/landmark/transport/nav_beacon/tram/destination_platform)
	log_transport("TC: [specific_transport_id] starting departure.")
	set_status_code(PRE_DEPARTURE, FALSE)
	if(controller_status & EMERGENCY_STOP)
		set_status_code(EMERGENCY_STOP, FALSE)
		playsound(paired_cabinet, 'sound/machines/synth_yes.ogg', 40, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		paired_cabinet.say("Controller reset.")

	SEND_SIGNAL(src, COMSIG_TRAM_TRAVEL, idle_platform, destination_platform)

	for(var/obj/structure/transport/linear/tram/transport_module as anything in transport_modules) //only thing everyone needs to know is the new location.
		if(transport_module.travelling) //wee woo wee woo there was a double action queued. damn multi tile structs
			return //we don't care to undo cover_locked controls, though, as that will resolve itself
		transport_module.glide_size_override = DELAY_TO_GLIDE_SIZE(speed_limiter)
		transport_module.set_travelling(TRUE)

	scheduled_move = world.time + speed_limiter

	START_PROCESSING(SStransport, src)

/**
 * Tram processing loop
 *
 * Moves the tram to its set destination.
 * When it arrives at its destination perform callback to the post-arrival procs like controls and lights.
 * We update the odometer and kill the process until we need to move again.
 *
 * If the status is EMERGENCY_STOP the tram should immediately come to a stop regardless of the travel_remaining.
 * Some extra things happen in an emergency stop (throwing the passengers) and when reset will run a
 * recovery procedure to head to the nearest platform and sync logical and physical location data
 * (idle_platform and nav_beacon) once the issue is resolved.
 */
/datum/transport_controller/linear/tram/process(seconds_per_tick)
	if(isnull(paired_cabinet))
		set_status_code(SYSTEM_FAULT, TRUE)

	if(controller_status & SYSTEM_FAULT || controller_status & EMERGENCY_STOP)
		halt_and_catch_fire()
		return PROCESS_KILL

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
			if(duration <= (SStransport.max_time / 2))
				recovery_clear_count++
			else
				recovery_clear_count = 0

			if(recovery_clear_count >= SStransport.max_cheap_moves)
				speed_limiter = base_speed_limiter
				recovery_mode = FALSE
				recovery_clear_count = 0
				log_transport("TC: [specific_transport_id] removing speed limiter, performance issue resolved. Last tick was [duration]ms.")

		else if(duration > SStransport.max_time)
			recovery_activate_count++
			if(recovery_activate_count >= SStransport.max_exceeding_moves)
				message_admins("The tram at [ADMIN_JMP(transport_modules[1])] is taking [duration] ms which is more than [SStransport.max_time] ms per movement for [recovery_activate_count] ticks. Reducing its movement speed until it recovers. If this continues to be a problem you can reset the tram contents to its original state, and clear added objects on the Debug tab.")
				log_transport("TC: [specific_transport_id] activating speed limiter due to poor performance.  Last tick was [duration]ms.")
				speed_limiter = base_speed_limiter * 2 //halves its speed
				recovery_mode = TRUE
				recovery_activate_count = 0
		else
			recovery_activate_count = max(recovery_activate_count - 1, 0)

		scheduled_move = world.time + speed_limiter

/datum/transport_controller/linear/tram/proc/normal_stop()
	cycle_doors(CYCLE_OPEN)
	log_transport("TC: [specific_transport_id] trip completed. Info: nav_pos ([nav_beacon.x], [nav_beacon.y], [nav_beacon.z]) idle_pos ([destination_platform.x], [destination_platform.y], [destination_platform.z]).")
	addtimer(CALLBACK(src, PROC_REF(unlock_controls)), 2 SECONDS)
	if((controller_status & SYSTEM_FAULT) && (nav_beacon.loc == destination_platform.loc)) //position matches between controller and tram, we're back on track
		set_status_code(SYSTEM_FAULT, FALSE)
		playsound(paired_cabinet, 'sound/machines/synth_yes.ogg', 40, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		paired_cabinet.say("Controller reset.")
		log_transport("TC: [specific_transport_id] position data successfully reset.")
		speed_limiter = initial(speed_limiter)
	idle_platform = destination_platform
	tram_registration.distance_travelled += (travel_trip_length - travel_remaining)
	travel_trip_length = 0
	current_speed = 0
	current_load = 0
	speed_limiter = initial(speed_limiter)

/datum/transport_controller/linear/tram/proc/degraded_stop()
	log_transport("TC: [specific_transport_id] trip completed with a degraded status. Info: [TC_TS_STATUS] nav_pos ([nav_beacon.x], [nav_beacon.y], [nav_beacon.z]) idle_pos ([destination_platform.x], [destination_platform.y], [destination_platform.z]).")
	addtimer(CALLBACK(src, PROC_REF(unlock_controls)), 4 SECONDS)
	if(controller_status & SYSTEM_FAULT)
		set_status_code(SYSTEM_FAULT, FALSE)
		playsound(paired_cabinet, 'sound/machines/synth_yes.ogg', 40, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		paired_cabinet.say("Controller reset.")
		log_transport("TC: [specific_transport_id] position data successfully reset. ")
		speed_limiter = initial(speed_limiter)
	idle_platform = destination_platform
	tram_registration.distance_travelled += (travel_trip_length - travel_remaining)
	travel_trip_length = 0
	current_speed = 0
	current_load = 0
	speed_limiter = initial(speed_limiter)
	var/throw_direction = travel_direction
	for(var/obj/structure/transport/linear/tram/module in transport_modules)
		module.estop_throw(throw_direction)

/datum/transport_controller/linear/tram/proc/halt_and_catch_fire()
	if(controller_status & SYSTEM_FAULT)
		if(!isnull(paired_cabinet))
			playsound(paired_cabinet, 'sound/machines/buzz-sigh.ogg', 60, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
			paired_cabinet.say("Controller error. Please contact your engineering department.")
		log_transport("TC: [specific_transport_id] Transport Controller failed!")

	if(travel_remaining)
		travel_remaining = 0
		var/throw_direction = travel_direction
		for(var/obj/structure/transport/linear/tram/module in transport_modules)
			module.estop_throw(throw_direction)

	addtimer(CALLBACK(src, PROC_REF(unlock_controls)), 4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(cycle_doors), CYCLE_OPEN), 2 SECONDS)
	idle_platform = null
	log_transport("TC: [specific_transport_id] Transport Controller needs new position data from the tram.")
	tram_registration.distance_travelled += (travel_trip_length - travel_remaining)
	travel_trip_length = 0
	current_speed = 0
	current_load = 0

/datum/transport_controller/linear/tram/proc/reset_position()
	if(idle_platform)
		if(get_turf(idle_platform) == get_turf(nav_beacon))
			set_status_code(SYSTEM_FAULT, FALSE)
			set_status_code(EMERGENCY_STOP, FALSE)
			playsound(paired_cabinet, 'sound/machines/synth_yes.ogg', 40, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
			paired_cabinet.say("Controller reset.")
			log_transport("TC: [specific_transport_id] Transport Controller reset was requested, but the tram nav data seems correct. Info: nav_pos ([nav_beacon.x], [nav_beacon.y], [nav_beacon.z]) idle_pos ([idle_platform.x], [idle_platform.y], [idle_platform.z]).")
			return

	log_transport("TC: [specific_transport_id] performing Transport Controller reset. Locating closest reset beacon to ([nav_beacon.x], [nav_beacon.y], [nav_beacon.z])")
	var/tram_velocity_sign
	if(travel_direction & (NORTH|SOUTH))
		tram_velocity_sign = travel_direction & NORTH ? OUTBOUND : INBOUND
	else
		tram_velocity_sign = travel_direction & EAST ? OUTBOUND : INBOUND

	var/reset_beacon = closest_nav_in_travel_dir(nav_beacon, tram_velocity_sign, specific_transport_id)

	if(!reset_beacon)
		playsound(paired_cabinet, 'sound/machines/buzz-sigh.ogg', 60, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		paired_cabinet.say("Controller reset failed. Contact manufacturer.") // If you screwed up the tram this bad, I don't even
		log_transport("TC: [specific_transport_id] non-recoverable error! Tram is at ([nav_beacon.x], [nav_beacon.y], [nav_beacon.z] [tram_velocity_sign ? "OUTBOUND" : "INBOUND"]) and can't find a reset beacon.")
		message_admins("Tram ID [specific_transport_id] is in a non-recoverable error state at [ADMIN_JMP(nav_beacon)]. If it's causing problems, delete the controller datum from the 'Reset Tram' proc in the Debug tab.")
		return

	travel_direction = get_dir(nav_beacon, reset_beacon)
	travel_remaining = get_dist(nav_beacon, reset_beacon)
	travel_trip_length = travel_remaining
	destination_platform = reset_beacon
	speed_limiter = 1.5
	playsound(paired_cabinet, 'sound/machines/ping.ogg', 40, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	paired_cabinet.say("Peforming controller reset... Navigating to reset point.")
	log_transport("TC: [specific_transport_id] trip calculation: src: [nav_beacon.x], [nav_beacon.y], [nav_beacon.z] dst: [destination_platform] [destination_platform.x], [destination_platform.y], [destination_platform.z] = Dir [travel_direction] Dist [travel_remaining].")
	cycle_doors(CYCLE_CLOSED)
	set_active(TRUE)
	set_status_code(CONTROLS_LOCKED, TRUE)
	addtimer(CALLBACK(src, PROC_REF(dispatch_transport), reset_beacon), 3 SECONDS)
	log_transport("TC: [specific_transport_id] trying to reset at [destination_platform].")

/datum/transport_controller/linear/tram/proc/estop()
	playsound(paired_cabinet, 'sound/machines/buzz-sigh.ogg', 60, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	paired_cabinet.say("Emergency stop activated!")
	set_status_code(EMERGENCY_STOP, TRUE)
	log_transport("TC: [specific_transport_id] requested emergency stop.")

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
	send_transport_active_signal()
	log_transport("TC: [specific_transport_id] controller state [controller_active ? "READY > PROCESSING" : "PROCESSING > READY"].")

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
	if(code != DOORS_READY)
		log_transport("TC: [specific_transport_id] status change [value ? "+" : "-"][english_list(bitfield_to_list(code, TRANSPORT_FLAGS))].")
	switch(value)
		if(TRUE)
			controller_status |= code
		if(FALSE)
			controller_status &= ~code
		else
			stack_trace("Transport controller received invalid status code request [code]/[value]")
			return

	send_transport_active_signal()

/datum/transport_controller/linear/tram/proc/send_transport_active_signal()
	SEND_SIGNAL(SStransport, COMSIG_TRANSPORT_ACTIVE, src, controller_active, controller_status, travel_direction, destination_platform)

/**
 * Part of the pre-departure list, checks the status of the doors on the tram
 *
 * Checks if all doors are closed, and updates the status code accordingly.
 *
 * TODO: this is probably better renamed check_door_status()
 */
/datum/transport_controller/linear/tram/proc/update_status()
	for(var/obj/machinery/door/airlock/tram/door as anything in SStransport.doors)
		if(door.transport_linked_id != specific_transport_id)
			continue
		if(door.crushing_in_progress)
			log_transport("TC: [specific_transport_id] door [door.id_tag] failed crush status check.")
			set_status_code(DOORS_READY, FALSE)
			return

	set_status_code(DOORS_READY, TRUE)

/**
 * Cycle all the doors on the tram.
 */
/datum/transport_controller/linear/tram/proc/cycle_doors(door_status, rapid)
	switch(door_status)
		if(CYCLE_OPEN)
			for(var/obj/machinery/door/airlock/tram/door as anything in SStransport.doors)
				if(door.transport_linked_id == specific_transport_id)
					INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/airlock/tram, open), rapid)

		if(CYCLE_CLOSED)
			for(var/obj/machinery/door/airlock/tram/door as anything in SStransport.doors)
				if(door.transport_linked_id == specific_transport_id)
					INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/airlock/tram, close), rapid)

/datum/transport_controller/linear/tram/proc/notify_controller(obj/machinery/transport/tram_controller/new_cabinet)
	paired_cabinet = new_cabinet
	RegisterSignal(new_cabinet, COMSIG_MACHINERY_POWER_LOST, PROC_REF(power_lost))
	RegisterSignal(new_cabinet, COMSIG_MACHINERY_POWER_RESTORED, PROC_REF(power_restored))
	RegisterSignal(new_cabinet, COMSIG_QDELETING, PROC_REF(on_cabinet_qdel))
	log_transport("TC: [specific_transport_id] is now paired with [new_cabinet].")
	if(controller_status & SYSTEM_FAULT)
		set_status_code(SYSTEM_FAULT, FALSE)
		reset_position()

/datum/transport_controller/linear/tram/proc/on_cabinet_qdel()
	paired_cabinet = null
	log_transport("TC: [specific_transport_id] received QDEL from controller cabinet.")
	set_status_code(SYSTEM_FAULT, TRUE)

/**
 * Tram malfunction random event. Set comm error, increase tram lethality.
 */
/datum/transport_controller/linear/tram/proc/start_malf_event()
	set_status_code(COMM_ERROR, TRUE)
	SEND_TRANSPORT_SIGNAL(COMSIG_COMMS_STATUS, src, FALSE)
	paired_cabinet.generate_repair_signals()
	collision_lethality = 1.25
	log_transport("TC: [specific_transport_id] starting Tram Malfunction event.")

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
	paired_cabinet.clear_repair_signals()
	collision_lethality = initial(collision_lethality)
	SEND_TRANSPORT_SIGNAL(COMSIG_COMMS_STATUS, src, TRUE)
	log_transport("TC: [specific_transport_id] ending Tram Malfunction event.")

/datum/transport_controller/linear/tram/proc/register_collision()
	tram_registration.collisions += 1
	SEND_TRANSPORT_SIGNAL(COMSIG_TRAM_COLLISION, SSpersistence.tram_hits_this_round)

/datum/transport_controller/linear/tram/proc/power_lost()
	set_operational(FALSE)
	log_transport("TC: [specific_transport_id] power lost.")
	send_transport_active_signal()

/datum/transport_controller/linear/tram/proc/power_restored()
	set_operational(TRUE)
	log_transport("TC: [specific_transport_id] power restored.")
	cycle_doors(CYCLE_OPEN)
	send_transport_active_signal()

/datum/transport_controller/linear/tram/proc/set_operational(new_value)
	if(controller_operational != new_value)
		controller_operational = new_value

/**
 * Returns the closest tram nav beacon to an atom
 *
 * Creates a list of nav beacons in the requested direction
 * and returns the closest to be passed to the industrial_lift
 *
 * Arguments: source: the starting point to find a beacon
 *            travel_dir: travel direction in tram form, INBOUND or OUTBOUND
 *            beacon_type: what list of beacons we pull from
 */
/datum/transport_controller/linear/tram/proc/closest_nav_in_travel_dir(atom/origin, travel_dir, beacon_type)
	if(!istype(origin) || !origin.z)
		return FALSE

	var/list/obj/effect/landmark/transport/nav_beacon/tram/inbound_candidates = list()
	var/list/obj/effect/landmark/transport/nav_beacon/tram/outbound_candidates = list()

	for(var/obj/effect/landmark/transport/nav_beacon/tram/candidate_beacon in SStransport.nav_beacons[beacon_type])
		if(candidate_beacon.z != origin.z || candidate_beacon.z != nav_beacon.z)
			continue

		switch(nav_beacon.dir)
			if(EAST, WEST)
				if(candidate_beacon.y != nav_beacon.y)
					continue
				else if(candidate_beacon.x < nav_beacon.x)
					inbound_candidates += candidate_beacon
				else
					outbound_candidates += candidate_beacon
			if(NORTH, SOUTH)
				if(candidate_beacon.x != nav_beacon.x)
					continue
				else if(candidate_beacon.y < nav_beacon.y)
					inbound_candidates += candidate_beacon
				else
					outbound_candidates += candidate_beacon

	switch(travel_dir)
		if(INBOUND)
			var/obj/effect/landmark/transport/nav_beacon/tram/nav/selected = get_closest_atom(/obj/effect/landmark/transport/nav_beacon/tram, inbound_candidates, origin)
			if(selected)
				return selected
			stack_trace("No inbound beacon candidate found for [origin]. Cancelling dispatch.")
			return FALSE

		if(OUTBOUND)
			var/obj/effect/landmark/transport/nav_beacon/tram/nav/selected = get_closest_atom(/obj/effect/landmark/transport/nav_beacon/tram, outbound_candidates, origin)
			if(selected)
				return selected
			stack_trace("No outbound beacon candidate found for [origin]. Cancelling dispatch.")
			return FALSE

		else
			stack_trace("Tram receieved invalid travel direction [travel_dir]. Cancelling dispatch.")

	return FALSE

/**
 * Moves the tram when hit by an immovable rod
 *
 * Tells the individual tram parts where to actually go and has an extra safety checks
 * incase multiple inputs get through, preventing conflicting directions and the tram
 * literally ripping itself apart. all of the actual movement is handled by SStramprocess
 *
 * Arguments: collided_rod (the immovable rod that hit the tram)
 * Return: push_destination (the landmark /obj/effect/landmark/tram/nav that the tram is being pushed to due to the rod's trajectory)
 */
/datum/transport_controller/linear/tram/proc/rod_collision(obj/effect/immovablerod/collided_rod)
	log_transport("TC: [specific_transport_id] hit an immovable rod.")
	if(!controller_operational)
		return
	var/rod_velocity_sign
	// Determine inbound or outbound
	if(collided_rod.dir & (NORTH|SOUTH))
		rod_velocity_sign = collided_rod.dir & NORTH ? OUTBOUND : INBOUND
	else
		rod_velocity_sign = collided_rod.dir & EAST ? OUTBOUND : INBOUND

	var/obj/effect/landmark/transport/nav_beacon/tram/nav/push_destination = closest_nav_in_travel_dir(origin = nav_beacon, travel_dir = rod_velocity_sign, beacon_type = IMMOVABLE_ROD_DESTINATIONS)
	if(!push_destination)
		return
	travel_direction = get_dir(nav_beacon, push_destination)
	travel_remaining = get_dist(nav_beacon, push_destination)
	travel_trip_length = travel_remaining
	destination_platform = push_destination
	log_transport("TC: [specific_transport_id] collided at ([nav_beacon.x], [nav_beacon.y], [nav_beacon.z]) towards [push_destination] ([push_destination.x], [push_destination.y], [push_destination.z]) Dir [travel_direction] Dist [travel_remaining].")
	// Don't bother processing crossing signals, where this tram's going there are no signals
	//for(var/obj/machinery/transport/crossing_signal/xing as anything in SStransport.crossing_signals)
	//	xing.temp_malfunction()
	priority_announce("In a turn of rather peculiar events, it appears that [GLOB.station_name] has struck an immovable rod. (Don't ask us where it came from.) This has led to a station brakes failure on one of the tram platforms.\n\n\
		Our diligent team of engineers have been informed and they're rushing over - although not quite at the speed of our recently flying tram.\n\n\
		So while we all look in awe at the universe's mysterious sense of humour, please stand clear of the tracks and remember to stand behind the yellow line.", "Braking News")
	set_active(TRUE)
	set_status_code(CONTROLS_LOCKED, TRUE)
	dispatch_transport(destination_platform = push_destination)
	return push_destination

/**
 * The physical cabinet on the tram. Acts as the interface between players and the controller datum.
 */
/obj/machinery/transport/tram_controller
	name = "tram controller"
	desc = "Makes the tram go, or something. Holds the tram's electronics, controls, and maintenance panel. A sticker above the card reader says 'Engineering access only.'"
	icon = 'icons/obj/tram/tram_controllers.dmi'
	icon_state = "controller-panel"
	anchored = TRUE
	density = FALSE
	armor_type = /datum/armor/transport_module
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 750
	integrity_failure = 0.25
	layer = SIGN_LAYER
	req_access = list(ACCESS_TCOMMS)
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 4.8
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 4.8
	var/datum/transport_controller/linear/tram/controller_datum
	/// If the cover is open
	var/cover_open = FALSE
	/// If the cover is locked
	var/cover_locked = TRUE
	COOLDOWN_DECLARE(manual_command_cooldown)

/obj/machinery/transport/tram_controller/hilbert
	configured_transport_id = HILBERT_LINE_1
	flags_1 = NODECONSTRUCT_1

/obj/machinery/transport/tram_controller/Initialize(mapload)
	. = ..()
	register_context()
	if(!id_tag)
		id_tag = assign_random_name()
	return INITIALIZE_HINT_LATELOAD

/**
 * Mapped or built tram cabinet isn't located on a transport module.
 */
/obj/machinery/transport/tram_controller/LateInitialize(mapload)
	. = ..()
	SStransport.hello(src, name, id_tag)
	find_controller()
	update_appearance()

/obj/machinery/transport/tram_controller/atom_break()
	set_machine_stat(machine_stat | BROKEN)
	..()

/obj/machinery/transport/tram_controller/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(held_item?.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_RMB] = panel_open ? "close panel" : "open panel"

	if(!held_item)
		context[SCREENTIP_CONTEXT_LMB] = cover_open ? "access controls" : "open cabinet"
		context[SCREENTIP_CONTEXT_RMB] = cover_open ? "close cabinet" : "toggle lock"


	if(panel_open)
		if(held_item?.tool_behaviour == TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_RMB] = "unscrew cabinet"
		if(malfunctioning || methods_to_fix.len)
			context[SCREENTIP_CONTEXT_LMB] = "repair electronics"

	if(held_item?.tool_behaviour == TOOL_WELDER)
		context[SCREENTIP_CONTEXT_LMB] = "repair frame"

	if(istype(held_item, /obj/item/card/emag) && !(obj_flags & EMAGGED))
		context[SCREENTIP_CONTEXT_LMB] = "emag controller"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/transport/tram_controller/examine(mob/user)
	. = ..()
	. += span_notice("The door appears to be [cover_locked ? "locked. Swipe an ID card to unlock" : "unlocked. Swipe an ID card to lock"].")
	if(panel_open)
		. += span_notice("It is secured to the tram wall with [EXAMINE_HINT("bolts.")]")
		. += span_notice("The maintenance panel can be closed with a [EXAMINE_HINT("screwdriver.")]")
	else
		. += span_notice("The maintenance panel can be opened with a [EXAMINE_HINT("screwdriver.")]")

	if(cover_open)
		. += span_notice("The [EXAMINE_HINT("yellow reset button")] resets the tram controller if a problem occurs or needs to be restarted.")
		. += span_notice("The [EXAMINE_HINT("red stop button")] immediately stops the tram, requiring a reset afterwards.")
		. += span_notice("The cabinet can be closed with a [EXAMINE_HINT("Right-click.")]")
	else
		. += span_notice("The cabinet can be opened with a [EXAMINE_HINT("Left-click.")]")


/obj/machinery/transport/tram_controller/attackby(obj/item/weapon, mob/living/user, params)
	if(user.combat_mode || cover_open)
		return ..()

	var/obj/item/card/id/id_card = user.get_id_in_hand()
	if(!isnull(id_card))
		try_toggle_lock(user, id_card)
		return

	return ..()

/obj/machinery/transport/tram_controller/attack_hand(mob/living/user, params)
	. = ..()
	if(cover_open)
		return

	if(cover_locked)
		var/obj/item/card/id/id_card = user.get_idcard(TRUE)
		if(isnull(id_card))
			balloon_alert(user, "access denied!")
			return

		try_toggle_lock(user, id_card)
		return

	toggle_door()

/obj/machinery/transport/tram_controller/attack_hand_secondary(mob/living/user, params)
	. = ..()

	if(!cover_open)
		var/obj/item/card/id/id_card = user.get_idcard(TRUE)
		if(isnull(id_card))
			balloon_alert(user, "access denied!")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		try_toggle_lock(user, id_card)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	toggle_door()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/transport/tram_controller/proc/toggle_door()
	if(!cover_open)
		playsound(loc, 'sound/machines/closet_open.ogg', 35, TRUE, -3)
	else
		playsound(loc, 'sound/machines/closet_close.ogg', 50, TRUE, -3)
	cover_open = !cover_open
	update_appearance()

/obj/machinery/transport/tram_controller/proc/try_toggle_lock(mob/living/user, obj/item/card/id_card, params)
	if(isnull(id_card))
		id_card = user.get_idcard(TRUE)
	if(obj_flags & EMAGGED)
		balloon_alert(user, "access controller damaged!")
		return FALSE

	if(check_access(id_card))
		cover_locked = !cover_locked
		balloon_alert(user, "controls [cover_locked ? "locked" : "unlocked"]")
		update_appearance()
		return TRUE

	balloon_alert(user, "access denied!")
	return FALSE

/obj/machinery/transport/tram_controller/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	if(panel_open && cover_open)
		balloon_alert(user, "unsecuring...")
		tool.play_tool_sound(src)
		if(!tool.use_tool(src, user, 6 SECONDS))
			return
		playsound(loc, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		balloon_alert(user, "unsecured")
		deconstruct()
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/transport/tram_controller/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	if(!cover_open)
		return

	tool.play_tool_sound(src)
	panel_open = !panel_open
	balloon_alert(user, "[panel_open ? "mounting bolts exposed" : "mounting bolts hidden"]")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/transport/tram_controller/deconstruct(disassembled = TRUE)
	if(flags_1 & NODECONSTRUCT_1)
		return

	var/turf/drop_location = find_obstruction_free_location(1, src)

	if(disassembled)
		new /obj/item/wallframe/tram/controller(drop_location)
	else
		new /obj/item/stack/sheet/mineral/titanium(drop_location, 2)
		new /obj/item/stack/sheet/iron(drop_location, 1)
	qdel(src)

/**
 * Update the blinky lights based on the controller status, allowing to quickly check without opening up the cabinet.
 */
/obj/machinery/transport/tram_controller/update_overlays()
	. = ..()

	if(!cover_open)
		. += mutable_appearance(icon, "controller-closed")
		if(cover_locked)
			. += mutable_appearance(icon, "controller-locked")

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

	if(controller_datum.controller_status & EMERGENCY_STOP)
		. += mutable_appearance(icon, "estop")
		. += emissive_appearance(icon, "estop", src, alpha = src.alpha)
		return

	if(!(controller_datum.controller_status & DOORS_READY))
		. += mutable_appearance(icon, "doors")
		. += emissive_appearance(icon, "doors", src, alpha = src.alpha)

	if(controller_datum.controller_active)
		. += mutable_appearance(icon, "active")
		. += emissive_appearance(icon, "active", src, alpha = src.alpha)

	if(controller_datum.controller_status & SYSTEM_FAULT)
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
/obj/machinery/transport/tram_controller/proc/find_controller()
	var/obj/structure/transport/linear/tram/tram_structure = locate() in src.loc
	if(!tram_structure)
		return

	controller_datum = tram_structure.transport_controller_datum
	if(!controller_datum)
		return

	controller_datum.notify_controller(src)
	RegisterSignal(SStransport, COMSIG_TRANSPORT_ACTIVE, PROC_REF(sync_controller))

/obj/machinery/transport/tram_controller/hilbert/find_controller()
	for(var/datum/transport_controller/linear/tram/tram as anything in SStransport.transports_by_type[TRANSPORT_TYPE_TRAM])
		if(tram.specific_transport_id == configured_transport_id)
			controller_datum = tram
			break

	if(!controller_datum)
		return

	controller_datum.notify_controller(src)
	RegisterSignal(SStransport, COMSIG_TRANSPORT_ACTIVE, PROC_REF(sync_controller))

/**
 * Since the machinery obj is a dumb terminal for the controller datum, sync the display with the status bitfield of the tram
 */
/obj/machinery/transport/tram_controller/proc/sync_controller(source, controller, controller_status, travel_direction, destination_platform)
	use_power(active_power_usage)
	if(controller != controller_datum)
		return
	update_appearance()

/obj/machinery/transport/tram_controller/emag_act(mob/user, obj/item/card/emag/emag_card)
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
/obj/machinery/transport/tram_controller/try_fix_machine(obj/machinery/transport/machine, mob/living/user, obj/item/tool)
	. = ..()

	if(. == FALSE)
		return

	if(!controller_datum)
		return

	var/datum/round_event/tram_malfunction/malfunction_event = locate(/datum/round_event/tram_malfunction) in SSevents.running
	if(malfunction_event)
		malfunction_event.end()

	if(controller_datum.controller_status & COMM_ERROR)
		controller_datum.set_status_code(COMM_ERROR, FALSE)

/obj/machinery/transport/tram_controller/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	if(!cover_open && !issiliconoradminghost(user) && !isobserver(user))
		return

	if(!is_operational)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TramController")
		ui.open()

/obj/machinery/transport/tram_controller/ui_data(mob/user)
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
		"statusSF" = controller_datum.controller_status & SYSTEM_FAULT,
		"statusCE" = controller_datum.controller_status & COMM_ERROR,
		"statusES" = controller_datum.controller_status & EMERGENCY_STOP,
		"statusPD" = controller_datum.controller_status & PRE_DEPARTURE,
		"statusDR" = controller_datum.controller_status & DOORS_READY,
		"statusCL" = controller_datum.controller_status & CONTROLS_LOCKED,
		"statusBS" = controller_datum.controller_status & BYPASS_SENSORS,
	)

	return data

/obj/machinery/transport/tram_controller/ui_static_data(mob/user)
	var/list/data = list()
	data["destinations"] = SStransport.detailed_destination_list(controller_datum.specific_transport_id)

	return data

/obj/machinery/transport/tram_controller/ui_act(action, params)
	. = ..()
	if (.)
		return

	if(!COOLDOWN_FINISHED(src, manual_command_cooldown))
		return

	switch(action)

		if("dispatch")
			var/obj/effect/landmark/transport/nav_beacon/tram/platform/destination_platform
			for (var/obj/effect/landmark/transport/nav_beacon/tram/platform/destination as anything in SStransport.nav_beacons[controller_datum.specific_transport_id])
				if(destination.name == params["tripDestination"])
					destination_platform = destination
					break

			if(!destination_platform)
				return FALSE

			SEND_SIGNAL(src, COMSIG_TRANSPORT_REQUEST, controller_datum.specific_transport_id, destination_platform.platform_code)
			update_appearance()

		if("estop")
			controller_datum.estop()

		if("reset")
			controller_datum.reset_position()

		if("dclose")
			controller_datum.cycle_doors(CYCLE_CLOSED)

		if("dopen")
			controller_datum.cycle_doors(CYCLE_OPEN)

		if("togglesensors")
			if(controller_datum.controller_status & BYPASS_SENSORS)
				controller_datum.set_status_code(BYPASS_SENSORS, FALSE)
			else
				controller_datum.set_status_code(BYPASS_SENSORS, TRUE)

	COOLDOWN_START(src, manual_command_cooldown, 2 SECONDS)

/obj/item/wallframe/tram/controller
	name = "tram controller cabinet"
	desc = "A box that contains the equipment to control a tram. Just secure to the tram wall."
	icon = 'icons/obj/tram/tram_controllers.dmi'
	icon_state = "controller-panel"
	custom_materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 4, /datum/material/iron = SHEET_MATERIAL_AMOUNT * 2, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2)
	result_path = /obj/machinery/transport/tram_controller
	pixel_shift = 32
