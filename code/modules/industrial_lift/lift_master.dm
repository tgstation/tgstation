///associative list of the form: list(lift_id = list(all lift_master datums attached to lifts of that type))
GLOBAL_LIST_EMPTY(active_lifts_by_type)

///coordinate and control movement across linked industrial_lift's. allows moving large single multitile platforms and many 1 tile platforms.
///also is capable of linking platforms across linked z levels
/datum/lift_master
	///the lift platforms we consider as part of this lift. ordered in order of lowest z level to highest z level after init.
	///(the sorting algorithm sucks btw)
	var/list/obj/structure/industrial_lift/lift_platforms

	/// Typepath list of what to ignore smashing through, controls all lifts
	var/static/list/ignored_smashthroughs = list(
		/obj/machinery/power/supermatter_crystal,
		/obj/structure/holosign,
		/obj/machinery/field,
	)

	///whether the lift handled by this lift_master datum is multitile as opposed to nxm platforms per z level
	var/multitile_platform = FALSE

	///taken from our lift platforms. if true we go through each z level of platforms and attempt to make the lowest left corner platform
	///into one giant multitile object the size of all other platforms on that z level.
	var/create_multitile_platform = FALSE

	///lift platforms have already been sorted in order of z level.
	var/z_sorted = FALSE

	///lift_id taken from our base lift platform, used to put us into GLOB.active_lifts_by_type
	var/lift_id = BASIC_LIFT_ID

	///overridable ID string to link control units to this specific lift_master datum. created by placing a lift id landmark object
	///somewhere on the tram, if its anywhere on the tram we'll find it in init and set this to whatever it specifies
	var/specific_lift_id

	///if true, the lift cannot be manually moved.
	var/controls_locked = FALSE

/datum/lift_master/New(obj/structure/industrial_lift/lift_platform)
	lift_id = lift_platform.lift_id
	create_multitile_platform = lift_platform.create_multitile_platform

	Rebuild_lift_plaform(lift_platform)
	ignored_smashthroughs = typecacheof(ignored_smashthroughs)

	LAZYADDASSOCLIST(GLOB.active_lifts_by_type, lift_id, src)

	for(var/obj/structure/industrial_lift/lift as anything in lift_platforms)
		lift.add_initial_contents()

/datum/lift_master/Destroy()
	for(var/obj/structure/industrial_lift/lift_platform as anything in lift_platforms)
		lift_platform.lift_master_datum = null
	lift_platforms = null

	LAZYREMOVEASSOC(GLOB.active_lifts_by_type, lift_id, src)
	if(isnull(GLOB.active_lifts_by_type))
		GLOB.active_lifts_by_type = list()//im lazy

	return ..()

/datum/lift_master/proc/add_lift_platforms(obj/structure/industrial_lift/new_lift_platform)
	if(new_lift_platform in lift_platforms)
		return
	for(var/obj/structure/industrial_lift/other_platform in new_lift_platform.loc)
		if(other_platform != new_lift_platform)
			stack_trace("there is more than one lift platform on a tile when a lift_master adds it. this causes problems")
			qdel(other_platform)

	new_lift_platform.lift_master_datum = src
	LAZYADD(lift_platforms, new_lift_platform)
	RegisterSignal(new_lift_platform, COMSIG_PARENT_QDELETING, PROC_REF(remove_lift_platforms))

	check_for_landmarks(new_lift_platform)

	if(z_sorted)//make sure we dont lose z ordering if we get additional platforms after init
		order_platforms_by_z_level()

/datum/lift_master/proc/remove_lift_platforms(obj/structure/industrial_lift/old_lift_platform)
	SIGNAL_HANDLER

	if(!(old_lift_platform in lift_platforms))
		return

	old_lift_platform.lift_master_datum = null
	LAZYREMOVE(lift_platforms, old_lift_platform)
	UnregisterSignal(old_lift_platform, COMSIG_PARENT_QDELETING)
	if(!length(lift_platforms))
		qdel(src)

///Collect all bordered platforms via a simple floodfill algorithm. allows multiz trams because its funny
/datum/lift_master/proc/Rebuild_lift_plaform(obj/structure/industrial_lift/base_lift_platform)
	add_lift_platforms(base_lift_platform)
	var/list/possible_expansions = list(base_lift_platform)

	while(possible_expansions.len)
		for(var/obj/structure/industrial_lift/borderline as anything in possible_expansions)
			var/list/result = borderline.lift_platform_expansion(src)
			if(length(result))
				for(var/obj/structure/industrial_lift/lift_platform as anything in result)
					if(lift_platforms.Find(lift_platform))
						continue

					add_lift_platforms(lift_platform)
					possible_expansions |= lift_platform

			possible_expansions -= borderline

///check for any landmarks placed inside the locs of the given lift_platform
/datum/lift_master/proc/check_for_landmarks(obj/structure/industrial_lift/new_lift_platform)
	SHOULD_CALL_PARENT(TRUE)

	for(var/turf/platform_loc as anything in new_lift_platform.locs)
		var/obj/effect/landmark/lift_id/id_giver = locate() in platform_loc

		if(id_giver)
			set_info_from_id_landmark(id_giver)

///set vars and such given an overriding lift_id landmark
/datum/lift_master/proc/set_info_from_id_landmark(obj/effect/landmark/lift_id/landmark)
	SHOULD_CALL_PARENT(TRUE)

	if(!istype(landmark, /obj/effect/landmark/lift_id))//lift_master subtypes can want differnet id's than the base type wants
		return

	if(landmark.specific_lift_id)
		specific_lift_id = landmark.specific_lift_id

	qdel(landmark)

///orders the lift platforms in order of lowest z level to highest z level.
/datum/lift_master/proc/order_platforms_by_z_level()
	//contains nested lists for every z level in the world. why? because its really easy to sort
	var/list/platforms_by_z = list()
	platforms_by_z.len = world.maxz

	for(var/z in 1 to world.maxz)
		platforms_by_z[z] = list()

	for(var/obj/structure/industrial_lift/lift_platform as anything in lift_platforms)
		if(QDELETED(lift_platform) || !lift_platform.z)
			lift_platforms -= lift_platform
			continue

		platforms_by_z[lift_platform.z] += lift_platform

	if(create_multitile_platform)
		for(var/list/z_list as anything in platforms_by_z)
			if(!length(z_list))
				continue

			create_multitile_platform_for_z_level(z_list)//this will subtract all but one platform from the list

	var/list/output = list()

	for(var/list/z_list as anything in platforms_by_z)
		output += z_list

	lift_platforms = output

	z_sorted = TRUE

///goes through all platforms in the given list and finds the one in the lower left corner
/datum/lift_master/proc/create_multitile_platform_for_z_level(list/obj/structure/industrial_lift/platforms_in_z)
	var/min_x = INFINITY
	var/max_x = 0

	var/min_y = INFINITY
	var/max_y = 0

	var/z = 0

	for(var/obj/structure/industrial_lift/lift_to_sort as anything in platforms_in_z)
		if(!z)
			if(!lift_to_sort.z)
				stack_trace("create_multitile_platform_for_z_level() was given a platform in nullspace or not on a turf!")
				platforms_in_z -= lift_to_sort
				continue

			z = lift_to_sort.z

		if(z != lift_to_sort.z)
			stack_trace("create_multitile_platform_for_z_level() was given lifts on different z levels!")
			platforms_in_z -= lift_to_sort
			continue

		min_x = min(min_x, lift_to_sort.x)
		max_x = max(max_x, lift_to_sort.x)

		min_y = min(min_y, lift_to_sort.y)
		max_y = max(max_y, lift_to_sort.y)

	var/turf/lower_left_corner_loc = locate(min_x, min_y, z)
	if(!lower_left_corner_loc)
		CRASH("was unable to find a turf at the lower left corner of this z")

	var/obj/structure/industrial_lift/lower_left_corner_lift = locate() in lower_left_corner_loc

	if(!lower_left_corner_lift)
		CRASH("there was no lift in the lower left corner of the given lifts")

	platforms_in_z.Cut()
	platforms_in_z += lower_left_corner_lift//we want to change the list given to us not create a new one. so we do this

	lower_left_corner_lift.create_multitile_platform(min_x, min_y, max_x, max_y, z)

///returns the closest lift to the specified atom, prioritizing lifts on the same z level. used for comparing distance
/datum/lift_master/proc/return_closest_platform_to(atom/comparison, allow_multiple_answers = FALSE)
	if(!istype(comparison) || !comparison.z)
		return FALSE

	var/list/obj/structure/industrial_lift/candidate_platforms = list()

	for(var/obj/structure/industrial_lift/platform as anything in lift_platforms)
		if(platform.z == comparison.z)
			candidate_platforms += platform

	var/obj/structure/industrial_lift/winner = candidate_platforms[1]
	var/winner_distance = get_dist(comparison, winner)

	var/list/tied_winners = list(winner)

	for(var/obj/structure/industrial_lift/platform_to_sort as anything in candidate_platforms)
		var/platform_distance = get_dist(comparison, platform_to_sort)

		if(platform_distance < winner_distance)
			winner = platform_to_sort
			winner_distance = platform_distance

			if(allow_multiple_answers)
				tied_winners = list(winner)

		else if(platform_distance == winner_distance && allow_multiple_answers)
			tied_winners += platform_to_sort

	if(allow_multiple_answers)
		return tied_winners

	return winner

/// Returns a lift platform on the z-level which is vertically closest to the passed target_z
/datum/lift_master/proc/return_closest_platform_to_z(target_z)
	var/obj/structure/industrial_lift/found_platform
	for(var/obj/structure/industrial_lift/lift as anything in lift_platforms)
		// Already at the same Z-level, we can stop
		if(lift.z == target_z)
			found_platform = lift
			break

		// Set up an initial lift to compare to
		if(!found_platform)
			found_platform = lift
			continue

		// Same level, we can go with the one we currently have
		if(lift.z == found_platform.z)
			continue

		// If the difference between the current found platform and the target
		// if less than the distance between the next lift and the target,
		// our current platform is closer to the target than the next one, so we can skip it
		if(abs(found_platform.z - target_z) < abs(lift.z - target_z))
			continue

		// The difference is smaller for this lift, so it's closer
		found_platform = lift

	return found_platform

/// Returns a list of all the z-levels our lift is currently on.
/datum/lift_master/proc/get_zs_we_are_on()
	var/list/zs_we_are_present_on = list()
	for(var/obj/structure/industrial_lift/lift as anything in lift_platforms)
		zs_we_are_present_on |= lift.z
	return zs_we_are_present_on

///returns all industrial_lifts associated with this tram on the given z level or given atoms z level
/datum/lift_master/proc/get_platforms_on_level(atom/atom_reference_OR_z_level_number)
	var/z = atom_reference_OR_z_level_number
	if(isatom(atom_reference_OR_z_level_number))
		z = atom_reference_OR_z_level_number.z

	if(!isnum(z) || z < 0 || z > world.maxz)
		return null

	var/list/platforms_in_z = list()

	for(var/obj/structure/industrial_lift/lift_to_check as anything in lift_platforms)
		if(lift_to_check.z)
			platforms_in_z += lift_to_check

	return platforms_in_z

/**
 * Moves the lift UP or DOWN, this is what users invoke with their hand.
 * This is a SAFE proc, ensuring every part of the lift moves SANELY.
 *
 * Arguments:
 * going - UP or DOWN directions, where the lift should go. Keep in mind by this point checks of whether it should go up or down have already been done.
 * user - Whomever made the lift movement.
 */
/datum/lift_master/proc/move_lift_vertically(going, mob/user)
	//lift_platforms are sorted in order of lowest z to highest z, so going upwards we need to move them in reverse order to not collide
	if(going == UP)
		var/obj/structure/industrial_lift/platform_to_move
		var/current_index = length(lift_platforms)

		while(current_index > 0)
			platform_to_move = lift_platforms[current_index]
			current_index--

			platform_to_move.travel(going)

	else if(going == DOWN)
		for(var/obj/structure/industrial_lift/lift_platform as anything in lift_platforms)
			lift_platform.travel(going)

/**
 * Moves the lift after a passed delay.
 *
 * This is a more "user friendly" or "realistic" lift move.
 * It includes things like:
 * - Allowing lift "travel time"
 * - Shutting elevator safety doors
 * - Sound effects while moving
 * - Safety warnings for anyone below the lift (while it's moving downwards)
 *
 * Arguments:
 * duration - required, how long do we wait to move the lift?
 * door_duration - optional, how long should we wait to open the doors after arriving? If null, we won't open or close doors
 * direction - which direction are we moving the lift?
 * user - optional, who is moving the lift?
 */
/datum/lift_master/proc/move_after_delay(lift_move_duration, door_duration, direction, mob/user)
	if(!isnum(lift_move_duration))
		CRASH("[type] move_after_delay called with invalid duration ([lift_move_duration]).")
	if(lift_move_duration <= 0 SECONDS)
		move_lift_vertically(direction, user)
		return

	// Get the lowest or highest lift according to which direction we're moving
	var/obj/structure/industrial_lift/prime_lift = return_closest_platform_to_z(direction == UP ? world.maxz : 0)

	// If anyone changes the hydraulic sound effect I sure hope they update this variable...
	var/hydraulic_sfx_duration = 2 SECONDS
	// ...because we use the duration of the sound effect to make it last for roughly the duration of the lift travel
	playsound(prime_lift, 'sound/mecha/hydraulic.ogg', 25, vary = TRUE, frequency = clamp(hydraulic_sfx_duration / lift_move_duration, 0.33, 3))

	// Move the lift after a timer
	addtimer(CALLBACK(src, PROC_REF(move_lift_vertically), direction, user), lift_move_duration, TIMER_UNIQUE)
	// Open doors after the set duration if supplied
	if(isnum(door_duration))
		addtimer(CALLBACK(src, PROC_REF(open_lift_doors_callback)), door_duration, TIMER_UNIQUE)

	// Here on we only care about lifts going DOWN
	if(direction != DOWN)
		return

	// Okay we're going down, let's try to display some warnings to people below
	var/list/turf/lift_locs = list()
	for(var/obj/structure/industrial_lift/going_to_move as anything in lift_platforms)
		// This lift has no warnings so we don't even need to worry about it
		if(!going_to_move.warns_on_down_movement)
			continue
		// Collect all the turfs our lift is found at
		lift_locs |= going_to_move.locs

	for(var/turf/moving in lift_locs)
		// Find what's below the turf that's moving
		var/turf/below_us = get_step_multiz(moving, DOWN)
		// Hold up the turf below us is also in our locs list. Multi-z lift? Don't show a warning
		if(below_us in lift_locs)
			continue
		// Display the warning for until we land
		new /obj/effect/temp_visual/telegraphing/lift_travel(below_us, lift_move_duration)

/**
 * Simple wrapper for checking if we can move 1 zlevel, and if we can, do said move.
 * Locks controls, closes all doors, then moves the lift and re-opens the doors afterwards.
 *
 * Arguments:
 * direction - which direction are we moving?
 * lift_move_duration - how long does the move take? can be 0 or null for instant move.
 * door_duration - how long does it take for the doors to open after a move?
 * user - optional, who moved it?
 */
/datum/lift_master/proc/simple_move_wrapper(direction, lift_move_duration, mob/user)
	if(!Check_lift_move(direction))
		return FALSE

	// Lock controls, to prevent moving-while-moving memes
	set_controls(LIFT_PLATFORM_LOCKED)
	// Send out a signal that we're going
	SEND_SIGNAL(src, COMSIG_LIFT_SET_DIRECTION, direction)
	// Close all lift doors
	update_lift_doors(action = CLOSE_DOORS)

	if(isnull(lift_move_duration) || lift_move_duration <= 0 SECONDS)
		// Do an instant move
		move_lift_vertically(direction, user)
		// Open doors on the zs we arrive at
		update_lift_doors(get_zs_we_are_on(), action = OPEN_DOORS)
		// And unlock the controls after
		set_controls(LIFT_PLATFORM_UNLOCKED)
		return TRUE

	// Do a delayed move
	move_after_delay(
		lift_move_duration = lift_move_duration,
		door_duration = lift_move_duration * 1.5,
		direction = direction,
		user = user,
	)

	addtimer(CALLBACK(src, PROC_REF(finish_simple_move_wrapper)), lift_move_duration * 1.5)
	return TRUE

/**
 * Wrap everything up from simple_move_wrapper finishing its movement
 */
/datum/lift_master/proc/finish_simple_move_wrapper()
	SEND_SIGNAL(src, COMSIG_LIFT_SET_DIRECTION, 0)
	set_controls(LIFT_PLATFORM_UNLOCKED)

/**
 * Moves the lift to the passed z-level.
 *
 * Checks for validity of the move: Are we moving to the same z-level, can we actually move to that z-level?
 * Does NOT check if the lift controls are currently locked.
 *
 * Moves to the passed z-level by calling move_after_delay repeatedly until the passed z-level is reached.
 * This proc sleeps as it moves.
 *
 * Arguments:
 * target_z - required, the Z we want to move to
 * loop_callback - optional, an additional callback invoked during the l oop that allows the move to cancel.
 * user - optional, who started the move
 */
/datum/lift_master/proc/move_to_zlevel(target_z, datum/callback/loop_callback, mob/user)
	if(!isnum(target_z) || target_z <= 0)
		CRASH("[type] move_to_zlevel was passed an invalid target_z ([target_z]).")

	var/obj/structure/industrial_lift/prime_lift = return_closest_platform_to_z(target_z)
	var/lift_z = prime_lift.z
	// We're already at the desired z-level!
	if(target_z == lift_z)
		return FALSE

	// The amount of z levels between the our and target_z
	var/z_difference = abs(target_z - lift_z)
	// Direction (up/down) needed to go to reach target_z
	var/direction = lift_z < target_z ? UP : DOWN

	// We can't go that way anymore, or possibly ever
	if(!Check_lift_move(direction))
		return FALSE

	// Okay we're ready to start moving now.
	set_controls(LIFT_PLATFORM_LOCKED)
	// Send out a signal that we're going
	SEND_SIGNAL(src, COMSIG_LIFT_SET_DIRECTION, direction)
	var/travel_speed = prime_lift.elevator_vertical_speed

	// Close all lift doors
	update_lift_doors(action = CLOSE_DOORS)
	// Approach the desired z-level one step at a time
	for(var/i in 1 to z_difference)
		if(!Check_lift_move(direction))
			break
		if(loop_callback && !loop_callback.Invoke())
			break
		// move_after_delay will set up a timer and cause us to move after a time
		move_after_delay(
			lift_move_duration = travel_speed,
			direction = direction,
			user = user,
		)
		// and we don't want to send another request until the timer's done
		stoplag(travel_speed + 0.1 SECONDS)
		if(QDELETED(src) || QDELETED(prime_lift))
			return

	addtimer(CALLBACK(src, PROC_REF(open_lift_doors_callback)), 2 SECONDS)
	SEND_SIGNAL(src, COMSIG_LIFT_SET_DIRECTION, 0)
	set_controls(LIFT_PLATFORM_UNLOCKED)
	return TRUE

/**
 * Updates all blast doors and shutters that share an ID with our lift.
 *
 * Arguments:
 * on_z_level - optional, only open doors on this z-level or list of z-levels
 * action - how do we update the doors? OPEN_DOORS to make them open, CLOSE_DOORS to make them shut
 */
/datum/lift_master/proc/update_lift_doors(on_z_level, action)

	if(!isnull(on_z_level) && !islist(on_z_level))
		on_z_level = list(on_z_level)

	var/played_ding = FALSE
	for(var/obj/machinery/door/poddoor/elevator_door in GLOB.machines)
		if(elevator_door.id != specific_lift_id)
			continue
		if(on_z_level && !(elevator_door.z in on_z_level))
			continue

		switch(action)
			if(OPEN_DOORS)
				INVOKE_ASYNC(elevator_door, TYPE_PROC_REF(/obj/machinery/door/poddoor, open))

			if(CLOSE_DOORS)
				INVOKE_ASYNC(elevator_door, TYPE_PROC_REF(/obj/machinery/door/poddoor, close))

			else
				stack_trace("Elevator lift update_lift_doors called with an improper action ([action]).")

		if(!played_ding)
			playsound(elevator_door, 'sound/machines/ding.ogg', 50, TRUE)
			played_ding = TRUE

/// Helper used in callbacks to open all the doors our lift is on
/datum/lift_master/proc/open_lift_doors_callback()
	update_lift_doors(get_zs_we_are_on(), action = OPEN_DOORS)

/**
 * Moves the lift, this is what users invoke with their hand.
 * This is a SAFE proc, ensuring every part of the lift moves SANELY.
 * It also locks controls for the (miniscule) duration of the movement, so the elevator cannot be broken by spamming.
 */
/datum/lift_master/proc/move_lift_horizontally(going)
	set_controls(LIFT_PLATFORM_LOCKED)

	if(multitile_platform)
		for(var/obj/structure/industrial_lift/platform_to_move as anything in lift_platforms)
			platform_to_move.travel(going)

		set_controls(LIFT_PLATFORM_UNLOCKED)
		return

	var/max_x = 0
	var/max_y = 0
	var/max_z = 0
	var/min_x = world.maxx
	var/min_y = world.maxy
	var/min_z = world.maxz

	for(var/obj/structure/industrial_lift/lift_platform as anything in lift_platforms)
		max_z = max(max_z, lift_platform.z)
		min_z = min(min_z, lift_platform.z)

		min_x = min(min_x, lift_platform.x)
		max_x = max(max_x, lift_platform.x)
		//this assumes that all z levels have identical horizontal bounding boxes
		//but if youre still using a non multitile tram platform at this point
		//then its your own problem. it wont runtime it will jsut be slower than it needs to be if this assumption isnt
		//the case

		min_y = min(min_y, lift_platform.y)
		max_y = max(max_y, lift_platform.y)

	for(var/z in min_z to max_z)
		//This must be safe way to border tile to tile move of bordered platforms, that excludes platform overlapping.
		if(going & WEST)
			//Go along the X axis from min to max, from left to right
			for(var/x in min_x to max_x)
				if(going & NORTH)
					//Go along the Y axis from max to min, from up to down
					for(var/y in max_y to min_y step -1)
						var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
						lift_platform?.travel(going)

				else if(going & SOUTH)
					//Go along the Y axis from min to max, from down to up
					for(var/y in min_y to max_y)
						var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
						lift_platform?.travel(going)

				else
					for(var/y in min_y to max_y)
						var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
						lift_platform?.travel(going)
		else
			//Go along the X axis from max to min, from right to left
			for(var/x in max_x to min_x step -1)
				if(going & NORTH)
					//Go along the Y axis from max to min, from up to down
					for(var/y in max_y to min_y step -1)
						var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
						lift_platform?.travel(going)

				else if (going & SOUTH)
					for(var/y in min_y to max_y)
						var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
						lift_platform?.travel(going)

				else
					//Go along the Y axis from min to max, from down to up
					for(var/y in min_y to max_y)
						var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
						lift_platform?.travel(going)

	set_controls(LIFT_PLATFORM_UNLOCKED)

///Check destination turfs
/datum/lift_master/proc/Check_lift_move(check_dir)
	for(var/obj/structure/industrial_lift/lift_platform as anything in lift_platforms)
		for(var/turf/bound_turf in lift_platform.locs)
			var/turf/T = get_step_multiz(lift_platform, check_dir)
			if(!T)//the edges of multi-z maps
				return FALSE
			if(check_dir == UP && !istype(T, /turf/open/openspace)) // We don't want to go through the ceiling!
				return FALSE
			if(check_dir == DOWN && !istype(get_turf(lift_platform), /turf/open/openspace)) // No going through the floor!
				return FALSE
	return TRUE

/**
 * Sets all lift parts's controls_locked variable. Used to prevent moving mid movement, or cooldowns.
 */
/datum/lift_master/proc/set_controls(state)
	controls_locked = state

/**
 * resets the contents of all platforms to their original state in case someone put a bunch of shit onto the tram.
 * intended to be called by admins. passes all arguments to reset_contents() for each of our platforms.
 *
 * Arguments:
 * * consider_anything_past - number. if > 0 our platforms will only handle foreign contents that exceed this number in each of their locs
 * * foreign_objects - bool. if true our platforms will consider /atom/movable's that arent mobs as part of foreign contents
 * * foreign_non_player_mobs - bool. if true our platforms consider mobs that dont have a mind to be foreign
 * * consider_player_mobs - bool. if true our platforms consider player mobs to be foreign. only works if foreign_non_player_mobs is true as well
 */
/datum/lift_master/proc/reset_lift_contents(consider_anything_past = 0, foreign_objects = TRUE, foreign_non_player_mobs = TRUE, consider_player_mobs = FALSE)
	for(var/obj/structure/industrial_lift/lift_to_reset in lift_platforms)
		lift_to_reset.reset_contents(consider_anything_past, foreign_objects, foreign_non_player_mobs, consider_player_mobs)

	return TRUE
