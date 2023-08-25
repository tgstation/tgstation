/proc/get_step_multiz(ref, dir)
	if(dir & UP)
		dir &= ~UP
		return get_step(GET_TURF_ABOVE(get_turf(ref)), dir)
	if(dir & DOWN)
		dir &= ~DOWN
		return get_step(GET_TURF_BELOW(get_turf(ref)), dir)
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
	return GET_TURF_ABOVE(src)

/turf/proc/below()
	return GET_TURF_BELOW(src)

/proc/get_lowest_turf(atom/ref)
	var/turf/us = get_turf(ref)
	var/next = GET_TURF_BELOW(us)
	while(next)
		us = next
		next = GET_TURF_BELOW(us)
	return us

// I wish this was lisp
/proc/get_highest_turf(atom/ref)
	var/turf/us = get_turf(ref)
	var/next = GET_TURF_ABOVE(us)
	while(next)
		us = next
		next = GET_TURF_ABOVE(us)
	return us
