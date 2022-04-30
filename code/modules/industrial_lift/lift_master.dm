///Collect and command
/datum/lift_master
	///the /obj/structure/industrial_lift instances handled by us.
	var/list/lift_platforms
	/// Typepath list of what to ignore smashing through, controls all lifts
	var/static/list/ignored_smashthroughs = list(
		/obj/machinery/power/supermatter_crystal,
		/obj/structure/holosign,
		/obj/machinery/field,
	)

	///whether the lift handled by this lift_master datum is multitile as opposed to nxm platforms
	var/multitile_tram = FALSE
	///lift platforms have already been sorted in order of z level.
	var/z_sorted = FALSE

	///decisecond delay between horizontal movement. cannot make the tram move faster than 1 movement per world.tick_lag
	var/horizontal_speed = 0.5

	///decisecond delay between vertical movement. cannot make the tram move faster than 1 movement per world.tick_lag
	var/vertical_speed = 0.5

/datum/lift_master/New(obj/structure/industrial_lift/lift_platform)
	Rebuild_lift_plaform(lift_platform)
	ignored_smashthroughs = typecacheof(ignored_smashthroughs)

	horizontal_speed = lift_platform.horizontal_speed
	vertical_speed = lift_platform.vertical_speed

	order_platforms_by_z_level()

/datum/lift_master/Destroy()
	for(var/obj/structure/industrial_lift/lift_platform as anything in lift_platforms)
		lift_platform.lift_master_datum = null
	lift_platforms = null
	return ..()

/datum/lift_master/proc/add_lift_platforms(obj/structure/industrial_lift/new_lift_platform)
	if(new_lift_platform in lift_platforms)
		return
	new_lift_platform.lift_master_datum = src
	LAZYADD(lift_platforms, new_lift_platform)
	RegisterSignal(new_lift_platform, COMSIG_PARENT_QDELETING, .proc/remove_lift_platforms)

	if(z_sorted)//make sure we dont lose z ordering if we get additional platforms after init
		order_platforms_by_z_level()

/datum/lift_master/proc/remove_lift_platforms(obj/structure/industrial_lift/old_lift_platform)
	SIGNAL_HANDLER

	if(!(old_lift_platform in lift_platforms))
		return

	old_lift_platform.lift_master_datum = null
	LAZYREMOVE(lift_platforms, old_lift_platform)
	UnregisterSignal(old_lift_platform, COMSIG_PARENT_QDELETING)

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

///orders the lift platforms in order of lowest z level to highest z level
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

	var/list/output = list()

	for(var/list/z_list as anything in platforms_by_z)
		output += z_list

	lift_platforms = output

	z_sorted = TRUE

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
	for(var/obj/structure/industrial_lift/lift_platform as anything in lift_platforms)
		lift_platform.travel(going)
	set_controls(LIFT_PLATFORM_UNLOCKED)

/**
 * Moves the lift, this is what users invoke with their hand.
 * This is a SAFE proc, ensuring every part of the lift moves SANELY.
 * It also locks controls for the (miniscule) duration of the movement, so the elevator cannot be broken by spamming.
 */
/datum/lift_master/proc/MoveLiftHorizontal(going)
	if(SStramprocess.profile)
		world.Profile(PROFILE_START)
	var/max_x = 0
	var/max_y = 0
	var/max_z = 0
	var/min_x = world.maxx
	var/min_y = world.maxy
	var/min_z = world.maxz

	set_controls(LIFT_PLATFORM_LOCKED)

	if(multitile_tram)
		for(var/obj/structure/industrial_lift/platform_to_move as anything in lift_platforms)
			tram_platform.travel(going)

		if(SStramprocess.profile)
			world.Profile(PROFILE_STOP)
		return

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
		if( going & WEST )
			//Go along the X axis from min to max, from left to right
			for(var/x in min_x to max_x)
				if( going & NORTH )
					//Go along the Y axis from max to min, from up to down
					for(var/y in max_y to min_y step -1)
						var/obj/structure/industrial_lift/lift_platform = locate(/obj/structure/industrial_lift, locate(x, y, z))
						lift_platform?.travel(going)
				else if (going & SOUTH)
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
				if( going & NORTH )
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
	for(var/obj/structure/industrial_lift/lift_platform as anything in lift_platforms)
		lift_platform.controls_locked = state
