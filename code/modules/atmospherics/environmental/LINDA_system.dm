/atom/var/CanAtmosPass = ATMOS_PASS_YES
/atom/proc/CanAtmosPass(turf/T)
	switch (CanAtmosPass)
		if (ATMOS_PASS_PROC)
			return ATMOS_PASS_YES
		if (ATMOS_PASS_DENSITY)
			return !density
		else
			return CanAtmosPass

/turf/closed/CanAtmosPass = ATMOS_PASS_NO

/turf/open/CanAtmosPass = ATMOS_PASS_PROC
/turf/open/CanAtmosPass(turf/T)
	var/R
	if(blocks_air || T.blocks_air)
		R = 1

	for(var/obj/O in contents+T.contents)
		var/turf/other = (O.loc == src ? T : src)
		if(!CANATMOSPASS(O, other))
			R = 1
			if(O.BlockSuperconductivity()) 	//the direction and open/closed are already checked on CanAtmosPass() so there are no arguments
				var/D = get_dir(src, T)
				atmos_supeconductivity |= D
				D = get_dir(T, src)
				T.atmos_supeconductivity |= D
				return 0						//no need to keep going, we got all we asked

	atmos_supeconductivity &= ~get_dir(src, T)
	T.atmos_supeconductivity &= ~get_dir(T, src)

	return !R



/atom/movable/proc/BlockSuperconductivity() // objects that block air and don't let superconductivity act. Only firelocks atm.
	return 0

/turf/proc/CalculateAdjacentTurfs()
	var/list/atmos_adjacent_turfs = src.atmos_adjacent_turfs
	for(var/direction in cardinal)
		var/turf/T = get_step(src, direction)
		if(!T)
			continue
		if(CANATMOSPASS(T, src))
			LAZYINITLIST(atmos_adjacent_turfs)
			LAZYINITLIST(T.atmos_adjacent_turfs)
			atmos_adjacent_turfs[T] = TRUE
			T.atmos_adjacent_turfs[src] = TRUE
		else
			if (atmos_adjacent_turfs)
				atmos_adjacent_turfs -= T
			if (T.atmos_adjacent_turfs)
				T.atmos_adjacent_turfs -= src
			UNSETEMPTY(T.atmos_adjacent_turfs)
	UNSETEMPTY(atmos_adjacent_turfs)
	src.atmos_adjacent_turfs = atmos_adjacent_turfs

//returns a list of adjacent turfs that can share air with this one.
//alldir includes adjacent diagonal tiles that can share
//	air with both of the related adjacent cardinal tiles
/turf/proc/GetAtmosAdjacentTurfs(alldir = 0)
	var/adjacent_turfs
	if (atmos_adjacent_turfs)
		adjacent_turfs = atmos_adjacent_turfs.Copy()
	else
		adjacent_turfs = list()

	if (!alldir)
		return adjacent_turfs

	var/turf/curloc = src

	for (var/direction in diagonals)
		var/matchingDirections = 0
		var/turf/S = get_step(curloc, direction)

		for (var/checkDirection in cardinal)
			var/turf/checkTurf = get_step(S, checkDirection)
			if(!S.atmos_adjacent_turfs || !S.atmos_adjacent_turfs[checkTurf])
				continue

			if (adjacent_turfs[checkTurf])
				matchingDirections++

			if (matchingDirections >= 2)
				adjacent_turfs += S
				break

	return adjacent_turfs

/atom/proc/air_update_turf(command = 0)
	if(!isturf(loc) && command)
		return
	var/turf/T = get_turf(loc)
	T.air_update_turf(command)

/turf/air_update_turf(command = 0)
	if(command)
		CalculateAdjacentTurfs()
	SSair.add_to_active(src,command)

/atom/movable/proc/move_update_air(turf/T)
    if(isturf(T))
        T.air_update_turf(1)
    air_update_turf(1)

/atom/proc/atmos_spawn_air(text) //because a lot of people loves to copy paste awful code lets just make a easy proc to spawn your plasma fires
	var/turf/open/T = get_turf(src)
	if(!istype(T))
		return
	T.atmos_spawn_air(text)

/turf/open/atmos_spawn_air(text)
	if(!text || !air)
		return

	var/datum/gas_mixture/G = new
	G.parse_gas_string(text)

	air.merge(G)
	SSair.add_to_active(src, 0)
