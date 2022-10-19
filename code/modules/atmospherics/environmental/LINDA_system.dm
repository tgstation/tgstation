/atom
	///Check if atmos can pass in this atom (ATMOS_PASS_YES, ATMOS_PASS_NO, ATMOS_PASS_DENSITY, ATMOS_PASS_PROC)
	var/can_atmos_pass = ATMOS_PASS_YES

/atom/proc/can_atmos_pass(turf/target_turf, vertical = FALSE)
	switch (can_atmos_pass)
		if (ATMOS_PASS_PROC)
			return ATMOS_PASS_YES
		if (ATMOS_PASS_DENSITY)
			return !density
		else
			return can_atmos_pass

/turf
	can_atmos_pass = ATMOS_PASS_NO

/turf/open
	can_atmos_pass = ATMOS_PASS_PROC

///Do NOT use this to see if 2 turfs are connected, it mutates state, and we cache that info anyhow.
///Use TURFS_CAN_SHARE or TURF_SHARES depending on your usecase
/turf/open/can_atmos_pass(turf/target_turf, vertical = FALSE)
	var/can_pass = TRUE
	var/direction = vertical ? get_dir_multiz(src, target_turf) : get_dir(src, target_turf)
	var/opposite_direction = REVERSE_DIR(direction)
	if(vertical && !(zAirOut(direction, target_turf) && target_turf.zAirIn(direction, src)))
		can_pass = FALSE
	if(blocks_air || target_turf.blocks_air)
		can_pass = FALSE
	//This path is a bit weird, if we're just checking with ourselves no sense asking objects on the turf
	if (target_turf == src)
		return can_pass

	//Can't just return if canpass is false here, we need to set superconductivity
	for(var/obj/checked_object in contents + target_turf.contents)
		var/turf/other = (checked_object.loc == src ? target_turf : src)
		if(CANATMOSPASS(checked_object, other, vertical))
			continue
		can_pass = FALSE
		//the direction and open/closed are already checked on can_atmos_pass() so there are no arguments
		if(checked_object.block_superconductivity())
			atmos_supeconductivity |= direction
			target_turf.atmos_supeconductivity |= opposite_direction
			return FALSE //no need to keep going, we got all we asked (Is this even faster? fuck you it's soul)

	//Superconductivity is a bitfield of directions we can't conduct with
	//Yes this is really weird. Fuck you
	atmos_supeconductivity &= ~direction
	target_turf.atmos_supeconductivity &= ~opposite_direction

	return can_pass

/atom/movable/proc/block_superconductivity() // objects that block air and don't let superconductivity act
	return FALSE

/// This proc is a more deeply optimized version of immediate_calculate_adjacent_turfs
/// It contains dumbshit, and also stuff I just can't do at runtime
/// If you're not editing behavior, just read that proc. It's less bad
/turf/proc/init_immediate_calculate_adjacent_turfs()
	//Basic optimization, if we can't share why bother asking other people ya feel?
	// You know it's gonna be stupid when they include a unit test in the atmos code
	// Yes, inlining the string concat does save 0.1 seconds
	#ifdef UNIT_TESTS
	ASSERT(UP == 16)
	ASSERT(DOWN == 32)
	#endif
	LAZYINITLIST(src.atmos_adjacent_turfs)
	var/list/atmos_adjacent_turfs = src.atmos_adjacent_turfs
	var/canpass = CANATMOSPASS(src, src, FALSE)
	// I am essentially inlineing two get_dir_multizs here, because they're way too slow on their own. I'm sorry brother
	var/list/z_traits = SSmapping.multiz_levels[z]
	for(var/direction in GLOB.cardinals_multiz)
		// Yes this is a reimplementation of get_step_mutliz. It's faster tho. fuck you
		// Oh also yes UP and DOWN do just point to +1 and -1 and not z offsets
		// Multiz is shitcode welcome home
		var/turf/current_turf = (direction & (UP|DOWN)) ? \
			(direction & UP) ? \
				(z_traits["16"]) ? \
					(get_step(locate(x, y, z + 1), NONE)) : \
				(null) : \
				(z_traits["32"]) ? \
					(get_step(locate(x, y, z - 1), NONE)) : \
				(null) : \
			(get_step(src, direction))
		if(!isopenturf(current_turf)) // not interested in you brother
			continue
		// The assumption is that ONLY DURING INIT if two tiles have the same cycle, there's no way canpass(a->b) will be different then canpass(b->a), so this is faster
		// Saves like 1.2 seconds
		// Note: current cycle here goes DOWN as we sleep. this is to ensure we can use the >= logic in the first step of process_cell
		// It's not a massive thing, and I'm sorry for the cursed code, but it be this way
		if(current_turf.current_cycle <= current_cycle)
			continue

		//Can you and me form a deeper relationship, or is this just a passing wind
		// (direction & (UP | DOWN)) is just "is this vertical" by the by
		if(canpass && CANATMOSPASS(current_turf, src, (direction & (UP|DOWN))) && !(blocks_air || current_turf.blocks_air))
			LAZYINITLIST(current_turf.atmos_adjacent_turfs)
			atmos_adjacent_turfs[current_turf] = TRUE
			current_turf.atmos_adjacent_turfs[src] = TRUE
		else
			atmos_adjacent_turfs -= current_turf
			if (current_turf.atmos_adjacent_turfs)
				current_turf.atmos_adjacent_turfs -= src
			UNSETEMPTY(current_turf.atmos_adjacent_turfs)
		SEND_SIGNAL(current_turf, COMSIG_TURF_CALCULATED_ADJACENT_ATMOS)

	UNSETEMPTY(atmos_adjacent_turfs)
	src.atmos_adjacent_turfs = atmos_adjacent_turfs
	SEND_SIGNAL(src, COMSIG_TURF_CALCULATED_ADJACENT_ATMOS)

/turf/proc/immediate_calculate_adjacent_turfs()
	LAZYINITLIST(src.atmos_adjacent_turfs)
	var/list/atmos_adjacent_turfs = src.atmos_adjacent_turfs
	var/canpass = CANATMOSPASS(src, src, FALSE)
	for(var/direction in GLOB.cardinals_multiz)
		var/turf/current_turf = get_step_multiz(src, direction)
		if(!isopenturf(current_turf)) // not interested in you brother
			continue

		//Can you and me form a deeper relationship, or is this just a passing wind
		// (direction & (UP | DOWN)) is just "is this vertical" by the by
		if(canpass && CANATMOSPASS(current_turf, src, (direction & (UP|DOWN))) && !(blocks_air || current_turf.blocks_air))
			LAZYINITLIST(current_turf.atmos_adjacent_turfs)
			atmos_adjacent_turfs[current_turf] = TRUE
			current_turf.atmos_adjacent_turfs[src] = TRUE
		else
			atmos_adjacent_turfs -= current_turf
			if (current_turf.atmos_adjacent_turfs)
				current_turf.atmos_adjacent_turfs -= src
			UNSETEMPTY(current_turf.atmos_adjacent_turfs)
		SEND_SIGNAL(current_turf, COMSIG_TURF_CALCULATED_ADJACENT_ATMOS)

	UNSETEMPTY(atmos_adjacent_turfs)
	src.atmos_adjacent_turfs = atmos_adjacent_turfs
	SEND_SIGNAL(src, COMSIG_TURF_CALCULATED_ADJACENT_ATMOS)

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

	var/datum/gas_mixture/turf_mixture = SSair.parse_gas_string(text, /datum/gas_mixture/turf)

	air.merge(turf_mixture)
	archive()
	SSair.add_to_active(src)
