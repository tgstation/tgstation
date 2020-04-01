

// Called from sound.dm to find a track to play
/client/proc/returncreditsmusic() // FULPSTATION
	if (prob(15))
		return 'sound/Fulpsounds/Fulp_Uhoh_Stinky.ogg'
	if (prob(5))
		return 'sound/Fulpsounds/Fulp_Piano_Old.ogg'
	return 'sound/Fulpsounds/Fulp_Piano.ogg'


// Can someone see the turf indicated? //
//
/proc/check_location_seen(atom/subject, turf/T)
	if (!isturf(T)) // Only check if I wasn't given a locker or something
		return FALSE
	// A) Check for Darkness
	if(T && T.lighting_object && T.get_lumcount()>= 0.1)
		// B) Check for Viewers
		for(var/mob/living/M in viewers(T))
			if(M != subject && isliving(M) && M.mind && !M.has_unlimited_silicon_privilege && !M.eye_blind) // M.client <--- add this in after testing!
				return TRUE
	return FALSE



// Return list of valid, non-dense turfs in range
//
/proc/return_valid_floors_in_range(atom/A, checkRange = 8, minRange = 0, checkFloor = TRUE) // THIS IS A COSTLY PROC!!
	// THIS IS A COSTLY PROC!!
	var/list/turf/possible_turfs = list()
	for(var/turf/T in range(A, checkRange))
		if (check_turf_is_valid(T, A, minRange, checkFloor))
			possible_turfs += T
	return possible_turfs

/proc/return_valid_floor_in_range(atom/A, checkRange = 8, minRange = 0, checkFloor = TRUE)
	// Move check in a random direction
	if (minRange > 0)
		// Step 1) Determine where to search from
		var/distanceAway = (checkRange + minRange) / 2
		// 	NOTE: What does this do?
		// 		We are starting our search a distance away that accounts for your minimum and maximum ranges.
		//		Basically, we're trying to find the halfway point between min distance and max distance, so we
		//		can run our search from there instead (at a reduced range)
		//      If our max is 20 and min is 6, then we'll start searching from 13 tiles away.

		// Step 2) Find New Turf in Random Direction
		var/randDir = rand(0,7) // Get a random direction.
		var/i
		var/turf/newT
		for (i = 0, i < distanceAway, i ++)
			newT = get_step(A, randDir)
			// Advance A one step in the correct direction
			if (istype(newT))
				A = newT
			// FAIL: Close enough.
			else
				break

		// Reset Check Range
		checkRange = (checkRange - minRange) / 2
		// NOTE: What does this do?
		//		Now that we're searching from the halfway point between min and max range, we only need to search
		//		half as far as we used to.
		//		So if checkRange WAS 20, and min is 6, then it should now be 7. We're only searching at a range of 7,
		//		but this is 7 tiles away from a point that is actually 13 tiles away.

	// FAIL: Atom doesn't exist
	if (!istype(A))
		return null


	// Pick Random Turf from A
	var/list/turf/possible_turfs = return_valid_floors_in_range(A, checkRange, 0, checkFloor)
	if (possible_turfs.len == 0)
		return null
	return pick(possible_turfs)
	//var/list/turf/T = locate(/turf/open/floor) in range(A, checkRange)//pick(range(A, checkRange))
	//if (check_turf_is_valid(T, A, 0, checkFloor)) // Cancel Minimum Range
	//	return T
	//return null

/proc/check_turf_is_valid(turf/T, atom/A, minRange = 0, checkFloor = TRUE)
	// Checking for Floor...
	if (checkFloor && !istype(T, /turf/open/floor))
		return FALSE
	// Checking for Density...
	if(T.density)
		return FALSE
	// Checking Min Distance...
	if (minRange > 0 && get_dist(T, A) > minRange)//(locate(T) in range(A, minRange)))
		return FALSE
	// Checking for Objects...
	for(var/obj/O in T)
		if(O.density)
			return FALSE
	return TRUE


// Return a xeno_spawn location in an area - use for additional jobspawns
//
proc/get_fulp_spawn(area/dept)
	for(var/obj/effect/landmark/S in GLOB.xeno_spawn)
		if(get_area(S) == dept)
			return S
