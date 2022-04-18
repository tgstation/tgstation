/*/turf/CanPass(atom/movable/mover, , height=1.5,air_group=0)
	if(target.blocks_air||blocks_air)
		return 0

	for(var/obj/obstacle in src)
		if(!obstacle.CanPass(mover, target, height, air_group))
			return 0
	if(target != src)
		for(var/obj/obstacle in target)
			if(!obstacle.CanPass(mover, src, height, air_group))
				return 0

	return ..()
*/

//Convenience function for atoms to update turfs they occupy
/atom/movable/proc/update_nearby_tiles(need_rebuild)
	//for(var/turf/simulated/turf in locs) ZASTURF
	for(var/turf/turf in locs)
		if(istype(turf, /turf/open/space))
			continue
		SSzas.mark_for_update(turf)

	return 1

//Basically another way of calling CanPass(null, other, 0, 0) and CanPass(null, other, 1.5, 1).
//Returns:
// 0 - Not blocked
// AIR_BLOCKED - Blocked
// ZONE_BLOCKED - Not blocked, but zone boundaries will not cross.
// BLOCKED - Blocked, zone boundaries will not cross even if opened.
/atom/proc/c_airblock(turf/other)
	#ifdef ZASDBG
	ASSERT(isturf(other))
	#endif
	return (AIR_BLOCKED*!CanPass(null, other, 0, 0))|(ZONE_BLOCKED*!CanPass(null, other, 1.5, 1))

// This is a legacy proc only here for compatibility - you probably should just use ATMOS_CANPASS_TURF directly.
/turf/c_airblock(turf/other)
	#ifdef ZASDBG
	ASSERT(isturf(other))
	#endif

	. = 0
	ATMOS_CANPASS_TURF(., src, other)

/atom/proc/zas_mark_update()
	var/turf/local_turf = get_turf(loc)
	if(!local_turf)
		return
	SSzas.mark_for_update(local_turf)

/atom
	var/simulated = TRUE
	var/can_atmos_pass = ATMOS_PASS_YES

/atom/proc/c_block(turf/target_turf, vertical = FALSE)
	return
