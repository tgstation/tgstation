/datum/lift_master/tram

	///whether this tram is traveling across vertical and/or horizontal axis for some distance. not all lifts use this
	var/travelling = FALSE
	///if we're travelling, what direction are we going
	var/travel_direction = NONE
	///if we're travelling, how far do we have to go
	var/travel_distance = 0
	///how far in total we'll be travelling
	var/travel_trip_length = 0

	///multiplier on how much damage/force the tram imparts on things it hits
	var/collision_lethality = 1

	/// reference to the destination landmark we consider ourselves "at". since we potentially span multiple z levels we dont actually
	/// know where on us this platform is. as long as we know THAT its on us we can just move the distance and direction between this
	/// and the destination landmark.
	var/obj/effect/landmark/tram/idle_platform

	/// a navigational landmark that we use to find the tram's location on the map at any time
	var/obj/effect/landmark/tram/nav/nav_beacon

	///decisecond delay between horizontal movement. cannot make the tram move faster than 1 movement per world.tick_lag.
	///this var is poorly named its actually horizontal movement delay but whatever.
	var/horizontal_speed = 0.5

	///version of horizontal_speed that gets set in init and is considered our base speed if our lift gets slowed down
	var/base_horizontal_speed = 0.5

	///the world.time we should next move at. in case our speed is set to less than 1 movement per tick
	var/next_move = INFINITY

	///whether we have been slowed down automatically
	var/slowed_down = FALSE

	///how many times we moved while costing more than SStramprocess.max_time milliseconds per movement.
	///if this exceeds SStramprocess.max_exceeding_moves
	var/times_exceeded = 0

	///how many times we moved while costing less than 0.5 * SStramprocess.max_time milliseconds per movement
	var/times_below = 0

	var/is_operational = TRUE

/datum/lift_master/tram/New(obj/structure/industrial_lift/tram/lift_platform)
	. = ..()
	horizontal_speed = lift_platform.horizontal_speed
	base_horizontal_speed = lift_platform.horizontal_speed

	check_starting_landmark()

/datum/lift_master/tram/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == "base_horizontal_speed")
		horizontal_speed = max(horizontal_speed, base_horizontal_speed)

/datum/lift_master/tram/add_lift_platforms(obj/structure/industrial_lift/new_lift_platform)
	. = ..()
	RegisterSignal(new_lift_platform, COMSIG_MOVABLE_BUMP, PROC_REF(gracefully_break))

/datum/lift_master/tram/check_for_landmarks(obj/structure/industrial_lift/tram/new_lift_platform)
	. = ..()
	for(var/turf/platform_loc as anything in new_lift_platform.locs)
		var/obj/effect/landmark/tram/platform/initial_destination = locate() in platform_loc
		var/obj/effect/landmark/tram/nav/beacon = locate() in platform_loc

		if(initial_destination)
			idle_platform = initial_destination

		if(initial_destination)
			nav_beacon = beacon

/datum/lift_master/tram/proc/check_starting_landmark()
	if(!idle_platform || !nav_beacon)
		CRASH("a tram lift_master was initialized without the required landmarks to give it direction!")

	SStramprocess.can_fire = TRUE

	return TRUE

/**
 * Signal for when the tram runs into a field of which it cannot go through.
 * Stops the train's travel fully, sends a message, and destroys the train.
 * Arguments:
 * bumped_atom - The atom this tram bumped into
 */
/datum/lift_master/tram/proc/gracefully_break(atom/bumped_atom)
	SIGNAL_HANDLER

	travel_distance = 0
	bumped_atom.visible_message(span_userdanger("The [bumped_atom.name] crashes into the field violently!"))
	for(var/obj/structure/industrial_lift/tram/tram_part as anything in lift_platforms)
		tram_part.set_travelling(FALSE)
		for(var/tram_contents in tram_part.lift_load)
			if(iseffect(tram_contents))
				continue

			if(isliving(tram_contents))
				explosion(tram_contents, devastation_range = rand(0, 1), heavy_impact_range = 2, light_impact_range = 3) //50% chance of gib

			else if(prob(9))
				explosion(tram_contents, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3)

			explosion(tram_part, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3)
			qdel(tram_part)

		for(var/obj/machinery/destination_sign/desto as anything in GLOB.tram_signs)
			desto.icon_state = "[desto.base_icon_state][DESTINATION_NOT_IN_SERVICE]"

		for(var/obj/machinery/crossing_signal/xing as anything in GLOB.tram_signals)
			xing.set_signal_state(XING_STATE_MALF)
			xing.update_appearance()

/**
 * Handles moving the tram
 *
 * Tells the individual tram parts where to actually go and has an extra safety checks
 * incase multiple inputs get through, preventing conflicting directions and the tram
 * literally ripping itself apart. all of the actual movement is handled by SStramprocess
 * Arguments: destination platform, rapid (bypass some safety checks)
 */
/datum/lift_master/tram/proc/tram_travel(obj/effect/landmark/tram/destination_platform, rapid = FALSE)
	if(destination_platform == idle_platform)
		return FALSE

	travel_direction = get_dir(nav_beacon, destination_platform)
	travel_distance = get_dist(nav_beacon, destination_platform)
	travel_trip_length = travel_distance
	idle_platform = destination_platform
	set_travelling(TRUE)
	set_controls(LIFT_PLATFORM_LOCKED)
	if(rapid) // bypass for unsafe, rapid departure
		dispatch_tram(destination_platform)
		return TRUE
	else
		update_tram_doors(CLOSE_DOORS)
		addtimer(CALLBACK(src, PROC_REF(dispatch_tram), destination_platform), 3 SECONDS)
		return TRUE

/datum/lift_master/tram/proc/dispatch_tram(obj/effect/landmark/tram/destination_platform)
	SEND_SIGNAL(src, COMSIG_TRAM_TRAVEL, idle_platform, destination_platform)

	for(var/obj/structure/industrial_lift/tram/tram_part as anything in lift_platforms) //only thing everyone needs to know is the new location.
		if(tram_part.travelling) //wee woo wee woo there was a double action queued. damn multi tile structs
			return //we don't care to undo locked controls, though, as that will resolve itself

		tram_part.glide_size_override = DELAY_TO_GLIDE_SIZE(horizontal_speed)
		tram_part.set_travelling(TRUE)

	next_move = world.time + horizontal_speed

	START_PROCESSING(SStramprocess, src)

/datum/lift_master/tram/process(seconds_per_tick)
	if(!travel_distance)
		update_tram_doors(OPEN_DOORS)
		addtimer(CALLBACK(src, PROC_REF(unlock_controls)), 2 SECONDS)
		return PROCESS_KILL
	else if(world.time >= next_move)
		var/start_time = TICK_USAGE
		travel_distance--

		move_lift_horizontally(travel_direction)

		var/duration = TICK_USAGE_TO_MS(start_time)
		if(slowed_down)
			if(duration <= (SStramprocess.max_time / 2))
				times_below++
			else
				times_below = 0

			if(times_below >= SStramprocess.max_cheap_moves)
				horizontal_speed = base_horizontal_speed
				slowed_down = FALSE
				times_below = 0

		else if(duration > SStramprocess.max_time)
			times_exceeded++

			if(times_exceeded >= SStramprocess.max_exceeding_moves)
				message_admins("The tram at [ADMIN_JMP(lift_platforms[1])] is taking more than [SStramprocess.max_time] milliseconds per movement, halving its movement speed. if this continues to be a problem you can call reset_lift_contents() on the trams lift_master_datum to reset it to its original state and clear added objects")
				horizontal_speed = base_horizontal_speed * 2 //halves its speed
				slowed_down = TRUE
				times_exceeded = 0
		else
			times_exceeded = max(times_exceeded - 1, 0)

		next_move = world.time + horizontal_speed

/**
 * Handles unlocking the tram controls for use after moving
 *
 * More safety checks to make sure the tram has actually docked properly
 * at a location before users are allowed to interact with the tram console again.
 * Tram finds its location at this point before fully unlocking controls to the user.
 */
/datum/lift_master/tram/proc/unlock_controls()
	set_travelling(FALSE)
	set_controls(LIFT_PLATFORM_UNLOCKED)
	for(var/obj/structure/industrial_lift/tram/tram_part as anything in lift_platforms) //only thing everyone needs to know is the new location.
		tram_part.set_travelling(FALSE)


/datum/lift_master/tram/proc/set_travelling(new_travelling)
	if(travelling == new_travelling)
		return

	travelling = new_travelling
	SEND_SIGNAL(src, COMSIG_TRAM_SET_TRAVELLING, travelling)

/**
 * Controls the doors of the tram when it departs and arrives at stations.
 * The tram doors are in a list of airlocks and we apply the proc on that list.
 */
/datum/lift_master/tram/proc/update_tram_doors(action)
	for(var/obj/machinery/door/window/tram/tram_door as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/window/tram))
		if(tram_door.associated_lift != specific_lift_id)
			continue
		set_door_state(tram_door, action)

/datum/lift_master/tram/proc/set_door_state(tram_door, action)
	switch(action)
		if(OPEN_DOORS)
			INVOKE_ASYNC(tram_door, TYPE_PROC_REF(/obj/machinery/door/window/tram, cycle_doors), action)

		if(CLOSE_DOORS)
			INVOKE_ASYNC(tram_door, TYPE_PROC_REF(/obj/machinery/door/window/tram, cycle_doors), action)

		else
			stack_trace("Tram doors update_tram_doors called with an improper action ([action]).")

/datum/lift_master/tram/proc/set_operational(new_value)
	if(is_operational != new_value)
		is_operational = new_value

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
/datum/lift_master/tram/proc/closest_nav_in_travel_dir(atom/origin, travel_dir, beacon_type)
	if(!istype(origin) || !origin.z)
		return FALSE

	var/list/obj/effect/landmark/tram/nav/inbound_candidates = list()
	var/list/obj/effect/landmark/tram/nav/outbound_candidates = list()

	for(var/obj/effect/landmark/tram/nav/candidate_beacon in GLOB.tram_landmarks[beacon_type])
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
			var/obj/effect/landmark/tram/nav/selected = get_closest_atom(/obj/effect/landmark/tram/nav, inbound_candidates, origin)
			if(selected)
				return selected
			stack_trace("No inbound beacon candidate found for [origin]. Cancelling dispatch.")
			return FALSE

		if(OUTBOUND)
			var/obj/effect/landmark/tram/nav/selected = get_closest_atom(/obj/effect/landmark/tram/nav, outbound_candidates, origin)
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
/datum/lift_master/tram/proc/rod_collision(obj/effect/immovablerod/collided_rod)
	if(!is_operational)
		return
	var/rod_velocity_sign
	// Determine inbound or outbound
	if(collided_rod.dir & (NORTH|SOUTH))
		rod_velocity_sign = collided_rod.dir & NORTH ? OUTBOUND : INBOUND
	else
		rod_velocity_sign = collided_rod.dir & EAST ? OUTBOUND : INBOUND

	var/obj/effect/landmark/tram/nav/push_destination = closest_nav_in_travel_dir(origin = nav_beacon, travel_dir = rod_velocity_sign, beacon_type = IMMOVABLE_ROD_DESTINATIONS)
	if(!push_destination)
		return
	travel_direction = get_dir(nav_beacon, push_destination)
	travel_distance = get_dist(nav_beacon, push_destination)
	travel_trip_length = travel_distance
	idle_platform = push_destination
	// Don't bother processing crossing signals, where this tram's going there are no signals
	for(var/obj/machinery/crossing_signal/xing as anything in GLOB.tram_signals)
		xing.temp_malfunction()
	priority_announce("In a turn of rather peculiar events, it appears that [GLOB.station_name] has struck an immovable rod. (Don't ask us where it came from.) This has led to a station brakes failure on one of the tram platforms.\n\n\
		Our diligent team of engineers have been informed and they're rushing over - although not quite at the speed of our recently flying tram.\n\n\
		So while we all look in awe at the universe's mysterious sense of humour, please stand clear of the tracks and remember to stand behind the yellow line.", "Braking News")
	set_travelling(TRUE)
	set_controls(LIFT_PLATFORM_LOCKED)
	dispatch_tram(destination_platform = push_destination)
	set_operational(FALSE)
	return push_destination
