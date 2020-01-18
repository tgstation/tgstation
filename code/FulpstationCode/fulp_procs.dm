

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
/proc/return_valid_floor_in_range(atom/A, checkRange = 8, minRange = 0, checkFloor = TRUE)
	var/list/turf/possible_turfs = list()
	for(var/turf/T in range(A, checkRange))
		// Checking for Floor...
		if (checkFloor && !istype(T, /turf/open/floor))
			continue
		// Checking for Density...
		if(T.density)
			continue
		// Checking Min Distance...
		if (minRange > 0 && (locate(T) in range(A, minRange)))
			continue
		// Checking for Objects...
		var/clear = TRUE
		for(var/obj/O in T)
			if(O.density)
				clear = FALSE
				break
		if(clear)
			possible_turfs += T
	return possible_turfs


// Return a xeno_spawn location in an area - use for additional jobspawns
//
proc/get_fulp_spawn(area/dept)
	for(var/obj/effect/landmark/S in GLOB.xeno_spawn)
		if(get_area(S) == dept)
			return S
