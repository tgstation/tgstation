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

/datum/transport_controller/linear/tram/New(obj/structure/transport/linear/tram/transport_module)
	. = ..()
	speed_limiter = transport_module.speed_limiter
	base_speed_limiter = transport_module.speed_limiter

	check_starting_landmark()

/datum/transport_controller/linear/tram/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == "base_speed_limiter")
		speed_limiter = max(speed_limiter, base_speed_limiter)

/datum/transport_controller/linear/tram/add_transport_modules(obj/structure/transport/linear/new_transport_module)
	. = ..()
	RegisterSignal(new_transport_module, COMSIG_MOVABLE_BUMP, PROC_REF(gracefully_break))

/datum/transport_controller/linear/tram/check_for_landmarks(obj/structure/transport/linear/tram/new_transport_module)
	. = ..()
	for(var/turf/platform_loc as anything in new_transport_module.locs)
		var/obj/effect/landmark/icts/nav_beacon/tram/initial_destination = locate() in platform_loc

		if(initial_destination)
			idle_platform = initial_destination

/datum/transport_controller/linear/tram/proc/check_starting_landmark()
	if(!idle_platform)
		CRASH("a tram lift_master was initialized without any tram landmark to give it direction!")

	SSicts_transport.can_fire = TRUE

	return TRUE

/**
 * Signal for when the tram runs into a field of which it cannot go through.
 * Stops the train's travel fully, sends a message, and destroys the train.
 * Arguments:
 * bumped_atom - The atom this tram bumped into
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

		for(var/obj/machinery/destination_sign/desto as anything in GLOB.tram_signs)
			desto.icon_state = "[desto.base_icon_state][DESTINATION_NOT_IN_SERVICE]"

		for(var/obj/machinery/crossing_signal/xing as anything in GLOB.tram_signals)
			xing.set_signal_state(XING_STATE_MALF)
			xing.update_appearance()


/datum/transport_controller/linear/tram/proc/calculate_route(obj/effect/landmark/icts/nav_beacon/tram/destination)
	if(destination == idle_platform)
		return FALSE

	destination_platform = destination
	travel_direction = get_dir(idle_platform, destination_platform)
	travel_remaining = get_dist(idle_platform, destination_platform)
	travel_trip_length = travel_remaining
	return TRUE
/**
 * Handles moving the tram
 *
 * Tells the individual tram parts where to actually go and has an extra safety checks
 * incase multiple inputs get through, preventing conflicting directions and the tram
 * literally ripping itself apart. all of the actual movement is handled by SSicts_transport
 * Arguments: destination platform, rapid (bypass some safety checks)
 */
/datum/transport_controller/linear/tram/proc/tram_travel(obj/effect/landmark/icts/nav_beacon/tram/destination_platform, rapid = FALSE)
	message_admins("ICTS: tram_travel")
	if(destination_platform == idle_platform)
		return

	travel_direction = get_dir(idle_platform, destination_platform)
	travel_remaining = get_dist(idle_platform, destination_platform)
	travel_trip_length = travel_remaining
	idle_platform = destination_platform
	set_active(TRUE)
	controls_lock(TRUE)
	if(rapid) // bypass for unsafe, rapid departure
		dispatch_transport(destination_platform)
	else
		update_tram_doors(CLOSE_DOORS)
		addtimer(CALLBACK(src, PROC_REF(dispatch_transport), destination_platform), 3 SECONDS)

/datum/transport_controller/linear/tram/proc/dispatch_transport(obj/effect/landmark/icts/nav_beacon/tram/destination_platform)
	message_admins("ICTS: dispatch_tram")
	controller_status &= ~PRE_DEPARTURE
	SEND_SIGNAL(src, COMSIG_TRAM_TRAVEL, idle_platform, destination_platform)

	for(var/obj/structure/transport/linear/tram/transport_module as anything in transport_modules) //only thing everyone needs to know is the new location.
		if(transport_module.travelling) //wee woo wee woo there was a double action queued. damn multi tile structs
			return //we don't care to undo locked controls, though, as that will resolve itself

		transport_module.glide_size_override = DELAY_TO_GLIDE_SIZE(speed_limiter)
		transport_module.set_travelling(TRUE)

	scheduled_move = world.time + speed_limiter

	START_PROCESSING(SSicts_transport, src)

/datum/transport_controller/linear/tram/process(seconds_per_tick)
	if(!travel_remaining)
		update_tram_doors(OPEN_DOORS)
		idle_platform = destination_platform
		addtimer(CALLBACK(src, PROC_REF(unlock_controls)), 2 SECONDS)
		return PROCESS_KILL
	else if(world.time >= scheduled_move)
		var/start_time = TICK_USAGE
		travel_remaining--

		move_lift_horizontally(travel_direction)

		var/duration = TICK_USAGE_TO_MS(start_time)
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
				message_admins("The tram at [ADMIN_JMP(transport_modules[1])] is taking more than [SSicts_transport.max_time] milliseconds per movement, halving its movement speed. if this continues to be a problem you can call reset_lift_contents() on the trams lift_master_datum to reset it to its original state and clear added objects")
				speed_limiter = base_speed_limiter * 2 //halves its speed
				recovery_mode = TRUE
				recovery_activate_count = 0
		else
			recovery_activate_count = max(recovery_activate_count - 1, 0)

		scheduled_move = world.time + speed_limiter

/**
 * Handles unlocking the tram controls for use after moving
 *
 * More safety checks to make sure the tram has actually docked properly
 * at a location before users are allowed to interact with the tram console again.
 * Tram finds its location at this point before fully unlocking controls to the user.
 */
/datum/transport_controller/linear/tram/proc/unlock_controls()
	message_admins("ICTS: unlock_controls")
	set_active(FALSE)
	controls_lock(FALSE)
	for(var/obj/structure/transport/linear/tram/transport_module as anything in transport_modules) //only thing everyone needs to know is the new location.
		transport_module.set_travelling(FALSE)


/datum/transport_controller/linear/tram/proc/set_active(new_status)
	message_admins("ICTS: set_travelling")
	if(controller_active == new_status)
		return

	controller_active = new_status
	SEND_ICTS_SIGNAL(COMSIG_ICTS_TRANSPORT_ACTIVE, src, controller_active)

/**
 * Controls the doors of the tram when it departs and arrives at stations.
 * The tram doors are in a list of airlocks and we apply the proc on that list.
 */
/datum/transport_controller/linear/tram/proc/update_tram_doors(action)
	message_admins("ICTS: update_tram_doors")
	for(var/obj/machinery/door/airlock/tram/tram_door in GLOB.tram_doors)
		if(tram_door.transport_linked_id != specific_transport_id)
			continue
		set_door_state(tram_door, action)

/datum/transport_controller/linear/tram/proc/set_door_state(tram_door, action)
	switch(action)
		if(OPEN_DOORS)
			INVOKE_ASYNC(tram_door, TYPE_PROC_REF(/obj/machinery/door/window/tram, cycle_doors), action)

		if(CLOSE_DOORS)
			INVOKE_ASYNC(tram_door, TYPE_PROC_REF(/obj/machinery/door/window/tram, cycle_doors), action)

		else
			stack_trace("Tram doors update_tram_doors called with an improper action ([action]).")
