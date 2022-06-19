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
	///what directions we're allowed to move
	var/allowed_travel_directions = ALL

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
	RegisterSignal(new_lift_platform, COMSIG_PARENT_QDELETING, .proc/remove_lift_platforms)

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
 * It also locks controls for the (miniscule) duration of the movement, so the elevator cannot be broken by spamming.
 * Arguments:
 * going - UP or DOWN directions, where the lift should go. Keep in mind by this point checks of whether it should go up or down have already been done.
 * user - Whomever made the lift movement.
 */
/datum/lift_master/proc/MoveLift(going, mob/user)
	set_controls(LIFT_PLATFORM_LOCKED)
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
	set_controls(LIFT_PLATFORM_UNLOCKED)

/**
 * Moves the lift, this is what users invoke with their hand.
 * This is a SAFE proc, ensuring every part of the lift moves SANELY.
 * It also locks controls for the (miniscule) duration of the movement, so the elevator cannot be broken by spamming.
 */
/datum/lift_master/proc/MoveLiftHorizontal(going)
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
