/turf/proc/CanAtmosPass(turf/T)

/turf/closed/CanAtmosPass(turf/T)
	return 0

/turf/open/CanAtmosPass(turf/T)
	var/R
	if(blocks_air || T.blocks_air)
		R = 1

	for(var/obj/O in contents+T.contents)
		var/turf/other = (O.loc == src ? T : src)
		if(!O.CanAtmosPass(other))
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

/atom/movable/proc/CanAtmosPass()
	return 1

/atom/proc/CanPass(atom/movable/mover, turf/target, height=1.5)
	return (!density || !height)

/turf/CanPass(atom/movable/mover, turf/target, height=1.5)
	if(!target) return 0

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

	else // Now, doing more detailed checks for air movement and air group formation
		if(target.blocks_air||blocks_air)
			return 0

		for(var/obj/obstacle in src)
			if(!obstacle.CanPass(mover, target, height))
				return 0
		for(var/obj/obstacle in target)
			if(!obstacle.CanPass(mover, src, height))
				return 0

		return 1

/atom/movable/proc/BlockSuperconductivity() // objects that block air and don't let superconductivity act. Only firelocks atm.
	return 0

/turf/proc/CalculateAdjacentTurfs()
	for(var/direction in cardinal)
		var/turf/open/T = get_step(src, direction)
		if(!istype(T))
			continue
		if(CanAtmosPass(T))
			atmos_adjacent_turfs |= T
			T.atmos_adjacent_turfs |= src
		else
			atmos_adjacent_turfs -= T
			T.atmos_adjacent_turfs -= src

//returns a list of adjacent turfs that can share air with this one.
//alldir includes adjacent diagonal tiles that can share
//	air with both of the related adjacent cardinal tiles
/turf/proc/GetAtmosAdjacentTurfs(alldir = 0)
	var/adjacent_turfs = atmos_adjacent_turfs.Copy()
	if (!alldir)
		return adjacent_turfs
	var/turf/curloc = src

	for (var/direction in diagonals)
		var/matchingDirections = 0
		var/turf/S = get_step(curloc, direction)

		for (var/checkDirection in cardinal)
			var/turf/checkTurf = get_step(S, checkDirection)
			if(!(checkTurf in S.atmos_adjacent_turfs))
				continue

			if (checkTurf in adjacent_turfs)
				matchingDirections++

			if (matchingDirections >= 2)
				adjacent_turfs += S
				break

	return adjacent_turfs

/atom/movable/proc/air_update_turf(command = 0)
	if(!istype(loc,/turf) && command)
		return
	var/turf/T = get_turf(loc)
	T.air_update_turf(command)

/turf/proc/air_update_turf(command = 0)
	if(command)
		CalculateAdjacentTurfs()
	SSair.add_to_active(src,command)

/atom/movable/proc/move_update_air(turf/T)
    if(istype(T,/turf))
        T.air_update_turf(1)
    air_update_turf(1)

/atom/movable/proc/atmos_spawn_air(text) //because a lot of people loves to copy paste awful code lets just make a easy proc to spawn your plasma fires
	var/turf/open/T = get_turf(src)
	if(!istype(T))
		return
	T.atmos_spawn_air(text)

/turf/open/proc/atmos_spawn_air(text)
	if(!text || !air)
		return

	var/datum/gas_mixture/G = new
	G.parse_gas_string(text)

	air.merge(G)
	SSair.add_to_active(src, 0)
