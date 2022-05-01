/datum/lift_master/tram

	///whether this tram is traveling across vertical and/or horizontal axis for some distance. not all lifts use this
	var/travelling = FALSE
	///if we're travelling, what direction are we going
	var/travel_direction = NONE
	///if we're travelling, how far do we have to go
	var/travel_distance = 0

	/// For finding the landmark initially - should be the exact same as the landmark's destination id.
	var/initial_id = "middle_part"
	/// reference to the destination landmark we consider ourselves "at". since we potentially span multiple z levels we dont actually
	/// know where on us this platform is. as long as we know THAT its on us we can just move the distance and direction between this
	/// and the destination landmark.
	var/obj/effect/landmark/tram/from_where

	///decisecond delay between horizontal movement. cannot make the tram move faster than 1 movement per world.tick_lag
	var/horizontal_speed = 0.5

	///the world.time we should next move at. in case our speed is set to less than 1 movement per tick
	var/next_move = INFINITY

/datum/lift_master/tram/New(obj/structure/industrial_lift/tram/lift_platform)
	. = ..()
	initial_id = lift_platform.initial_id
	horizontal_speed = lift_platform.horizontal_speed

	find_starting_landmark()

/datum/lift_master/tram/add_lift_platforms(obj/structure/industrial_lift/new_lift_platform)
	. = ..()
	RegisterSignal(new_lift_platform, COMSIG_MOVABLE_BUMP, .proc/gracefully_break)

/datum/lift_master/tram/proc/find_starting_landmark()
	var/obj/effect/landmark/tram/linked_landmark
	for(var/obj/effect/landmark/tram/tram_landmark as anything in GLOB.tram_landmarks)
		if(tram_landmark.destination_id == initial_id)
			linked_landmark = tram_landmark
			break

	if(!linked_landmark)
		CRASH("a tram was unable to link to a starting landmark because there was no landmark coinciding with its initial_id!")

	var/turf/landmark_turf = get_turf(linked_landmark)

	if(!landmark_turf)
		CRASH("a tram was unable to link to a starting landmark because the landmark was in nullspace!")

	var/obj/structure/industrial_lift/linked_lift = locate() in landmark_turf

	if(!linked_lift || !(linked_lift in lift_platforms))
		CRASH("a tram was unable to link to a starting landmark because the landmark wasnt on the tram!")

	SStramprocess.can_fire = TRUE

	//ok we found it on our turf, now we know how we're orientated
	return TRUE

/**
 * Signal for when the tram runs into a field of which it cannot go through.
 * Stops the train's travel fully, sends a message, and destroys the train.
 * Arguments:
 * bumped_atom - The atom this tram bumped into
 */
/datum/lift_master/tram/proc/gracefully_break(atom/bumped_atom)
	SIGNAL_HANDLER

	if(istype(bumped_atom, /obj/machinery/field))
		return

	travel_distance = 0

	bumped_atom.visible_message(span_userdanger("[src] crashes into the field violently!"))
	for(var/obj/structure/industrial_lift/tram/tram_part as anything in lift_platforms)
		tram_part.set_travelling(FALSE)
		if(prob(15) || locate(/mob/living) in tram_part.lift_load) //always go boom on people on the track
			explosion(tram_part, devastation_range = rand(0, 1), heavy_impact_range = 2, light_impact_range = 3) //50% chance of gib
		qdel(tram_part)

/**
 * Handles moving the tram
 *
 * Tells the individual tram parts where to actually go and has an extra safety check
 * incase multiple inputs get through, preventing conflicting directions and the tram
 * literally ripping itself apart. all of the actual movement is handled by SStramprocess
 */
/datum/lift_master/tram/proc/tram_travel(obj/effect/landmark/tram/to_where)
	if(to_where == from_where)
		return

	//TODOKYLER: make the tram console say when its called

	travel_direction = get_dir(from_where, to_where)
	travel_distance = get_dist(from_where, to_where)
	from_where = to_where
	set_travelling(TRUE)
	set_controls(LIFT_PLATFORM_LOCKED)
	SEND_SIGNAL(src, COMSIG_TRAM_TRAVEL, from_where, to_where)

	for(var/obj/structure/industrial_lift/tram/tram_part as anything in lift_platforms) //only thing everyone needs to know is the new location.
		if(tram_part.travelling) //wee woo wee woo there was a double action queued. damn multi tile structs
			return //we don't care to undo locked controls, though, as that will resolve itself

		tram_part.glide_size_override = DELAY_TO_GLIDE_SIZE(horizontal_speed)
		tram_part.set_travelling(TRUE)

	next_move = world.time + horizontal_speed

	START_PROCESSING(SStramprocess, src)

/datum/lift_master/tram/process(delta_time)
	if(!travel_distance)
		addtimer(CALLBACK(src, .proc/unlock_controls), 3 SECONDS)
		return PROCESS_KILL
	else if(world.time <= next_move)
		next_move = world.time + horizontal_speed
		travel_distance--
		MoveLiftHorizontal(travel_direction)

/**
 * Handles unlocking the tram controls for use after moving
 *
 * More safety checks to make sure the tram has actually docked properly
 * at a location before users are allowed to interact with the tram console again.
 * Tram finds its location at this point before fully unlocking controls to the user.
 */
/datum/lift_master/tram/proc/unlock_controls()
	//visible_message(span_notice("[src]'s controls are now unlocked.")) //TODOKYLER: make the control console say this
	set_travelling(FALSE)
	set_controls(LIFT_PLATFORM_UNLOCKED)
	for(var/obj/structure/industrial_lift/tram/tram_part as anything in lift_platforms) //only thing everyone needs to know is the new location.
		tram_part.set_travelling(FALSE)


/datum/lift_master/tram/proc/set_travelling(new_travelling)
	if(travelling == new_travelling)
		return

	travelling = new_travelling
	SEND_SIGNAL(src, COMSIG_TRAM_SET_TRAVELLING, travelling)
