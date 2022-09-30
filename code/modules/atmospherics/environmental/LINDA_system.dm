/atom
	///Check if atmos can pass in this atom (ATMOS_PASS_YES, ATMOS_PASS_NO, ATMOS_PASS_DENSITY, ATMOS_PASS_PROC)
	var/can_atmos_pass = ATMOS_PASS_YES
	///Zlevel check for can_atmos_pass
	var/can_atmos_pass_vertical = ATMOS_PASS_YES

/atom/proc/can_atmos_pass(turf/target_turf)
	switch (can_atmos_pass)
		if (ATMOS_PASS_PROC)
			return ATMOS_PASS_YES
		if (ATMOS_PASS_DENSITY)
			return !density
		else
			return can_atmos_pass

/turf
	can_atmos_pass = ATMOS_PASS_NO
	can_atmos_pass_vertical = ATMOS_PASS_NO

/turf/open
	can_atmos_pass = ATMOS_PASS_PROC
	can_atmos_pass_vertical = ATMOS_PASS_PROC

//Do NOT use this to see if 2 turfs are connected, it mutates state, and we cache that info anyhow. Use TURFS_CAN_SHARE or TURF_SHARES depending on your usecase
/turf/open/can_atmos_pass(turf/target_turf, vertical = FALSE)
	var/direction = vertical ? get_dir_multiz(src, target_turf) : get_dir(src, target_turf)
	var/opposite_direction = REVERSE_DIR(direction)
	var/can_pass = FALSE
	if(vertical && !(zAirOut(direction, target_turf) && target_turf.zAirIn(direction, src)))
		can_pass = TRUE
	if(blocks_air || target_turf.blocks_air)
		can_pass = TRUE
	if (target_turf == src)
		return !can_pass
	for(var/obj/checked_object in contents + target_turf.contents)
		var/turf/other = (checked_object.loc == src ? target_turf : src)
		if(!(vertical? (CANVERTICALATMOSPASS(checked_object, other)) : (CANATMOSPASS(checked_object, other))))
			can_pass = TRUE
			if(checked_object.block_superconductivity()) //the direction and open/closed are already checked on can_atmos_pass() so there are no arguments
				atmos_supeconductivity |= direction
				target_turf.atmos_supeconductivity |= opposite_direction
				return FALSE //no need to keep going, we got all we asked

	atmos_supeconductivity &= ~direction
	target_turf.atmos_supeconductivity &= ~opposite_direction

	return !can_pass

/atom/movable/proc/block_superconductivity() // objects that block air and don't let superconductivity act
	return FALSE

/turf/proc/immediate_calculate_adjacent_turfs()
	var/canpass = CANATMOSPASS(src, src)
	var/canvpass = CANVERTICALATMOSPASS(src, src)
	for(var/direction in GLOB.cardinals_multiz)
		var/turf/current_turf = get_step_multiz(src, direction)
		if(!isopenturf(current_turf))
			continue
		if(!(blocks_air || current_turf.blocks_air) && ((direction & (UP|DOWN)) ? (canvpass && CANVERTICALATMOSPASS(current_turf, src)) : (canpass && CANATMOSPASS(current_turf, src))) )
			LAZYINITLIST(atmos_adjacent_turfs)
			LAZYINITLIST(current_turf.atmos_adjacent_turfs)
			atmos_adjacent_turfs[current_turf] = TRUE
			current_turf.atmos_adjacent_turfs[src] = TRUE
		else
			if (atmos_adjacent_turfs)
				atmos_adjacent_turfs -= current_turf
			if (current_turf.atmos_adjacent_turfs)
				current_turf.atmos_adjacent_turfs -= src
			UNSETEMPTY(current_turf.atmos_adjacent_turfs)
	UNSETEMPTY(atmos_adjacent_turfs)
	src.atmos_adjacent_turfs = atmos_adjacent_turfs

/**
 * returns a list of adjacent turfs that can share air with this one.
 * alldir includes adjacent diagonal tiles that can share
 * air with both of the related adjacent cardinal tiles
**/
/turf/proc/get_atmos_adjacent_turfs(alldir = 0)
	var/adjacent_turfs
	if (atmos_adjacent_turfs)
		adjacent_turfs = atmos_adjacent_turfs.Copy()
	else
		adjacent_turfs = list()

	if (!alldir)
		return adjacent_turfs

	var/turf/current_location = src

	for (var/direction in GLOB.diagonals_multiz)
		var/matching_directions = 0
		var/turf/checked_turf = get_step_multiz(current_location, direction)
		if(!checked_turf)
			continue

		for (var/check_direction in GLOB.cardinals_multiz)
			var/turf/secondary_turf = get_step(checked_turf, check_direction)
			if(!checked_turf.atmos_adjacent_turfs || !checked_turf.atmos_adjacent_turfs[secondary_turf])
				continue

			if (adjacent_turfs[secondary_turf])
				matching_directions++

			if (matching_directions >= 2)
				adjacent_turfs += checked_turf
				break

	return adjacent_turfs

/atom/proc/air_update_turf(update = FALSE, remove = FALSE)
	var/turf/local_turf = get_turf(loc)
	if(!local_turf)
		return
	local_turf.air_update_turf(update, remove)

/**
 * A helper proc for dealing with atmos changes
 *
 * Ok so this thing is pretty much used as a catch all for all the situations someone might wanna change something
 * About a turfs atmos. It's real clunky, and someone needs to clean it up, but not today.
 * Arguments:
 * * update - Has the state of the structures in the world changed? If so, update our adjacent atmos turf list, if not, don't.
 * * remove - Are you removing an active turf (Read wall), or adding one
*/
/turf/air_update_turf(update = FALSE, remove = FALSE)
	if(update)
		immediate_calculate_adjacent_turfs()
	if(remove)
		SSair.remove_from_active(src)
	else
		SSair.add_to_active(src)

/atom/movable/proc/move_update_air(turf/target_turf)
	if(isturf(target_turf))
		target_turf.air_update_turf(TRUE, FALSE) //You're empty now
	air_update_turf(TRUE, TRUE) //You aren't

/atom/proc/atmos_spawn_air(text) //because a lot of people loves to copy paste awful code lets just make an easy proc to spawn your plasma fires
	var/turf/open/local_turf = get_turf(src)
	if(!istype(local_turf))
		return
	local_turf.atmos_spawn_air(text)

/turf/open/atmos_spawn_air(text)
	if(!text || !air)
		return

	var/datum/gas_mixture/turf_mixture = new
	turf_mixture.parse_gas_string(text)

	air.merge(turf_mixture)
	archive()
	SSair.add_to_active(src)
