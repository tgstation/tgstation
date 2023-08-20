/proc/get_step_multiz(ref, dir)
	var/turf/us = get_turf(ref)
	if(dir & UP)
		dir &= ~UP
		return get_step(us.above(), dir)
	if(dir & DOWN)
		dir &= ~DOWN
		return get_step(us.below(), dir)
	return get_step(ref, dir)

/proc/get_dir_multiz(turf/us, turf/them)
	us = get_turf(us)
	them = get_turf(them)
	if(!us || !them)
		return NONE
	if(us.z == them.z)
		return get_dir(us, them)
	else
		var/turf/T = us.above()
		var/dir = NONE
		if(T && (T.z == them.z))
			dir = UP
		else
			T = us.below()
			if(T && (T.z == them.z))
				dir = DOWN
			else
				return get_dir(us, them)
		return (dir | get_dir(us, them))

/turf/proc/above()
	if(turf_flags & RESERVATION_TURF)
		var/datum/turf_reservation/map_reserve = SSmapping.get_reservation_from_turf(src)
		return map_reserve.get_turf_above(src)
	return GET_TURF_ABOVE(src)

/turf/proc/below()
	if(turf_flags & RESERVATION_TURF)
		var/datum/turf_reservation/map_reserve = SSmapping.get_reservation_from_turf(src)
		return map_reserve.get_turf_below(src)
	return GET_TURF_BELOW(src)

/proc/get_lowest_turf(atom/ref)
	var/turf/us = get_turf(ref)
	var/turf/next = us.below()
	while(next)
		us = next
		next = us.below()
	return us

// I wish this was lisp
/proc/get_highest_turf(atom/ref)
	var/turf/us = get_turf(ref)
	var/turf/next = us.above()
	while(next)
		us = next
		next = us.above()
	return us
