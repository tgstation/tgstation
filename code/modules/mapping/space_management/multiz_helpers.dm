/proc/get_step_multiz(ref, dir)
	if(dir & UP)
		dir &= ~UP
		return get_step(SSmapping.get_turf_above(get_turf(ref)), dir)
	if(dir & DOWN)
		dir &= ~DOWN
		return get_step(SSmapping.get_turf_below(get_turf(ref)), dir)
	return get_step(ref, dir)

/proc/get_dir_multiz(turf/src, turf/other)
	src = get_turf(src)
	other = get_turf(other)
	if(!src || !other)
		return NONE
	if(src.z == other.z)
		return get_dir(src, other)
	else
		var/turf/T = src.above()
		var/dir = NONE
		if(T && (T.z == other.z))
			dir = UP
		else
			T = src.below()
			if(T && (T.z == other.z))
				dir = DOWN
			else
				return get_dir(src, other)
		return (dir | get_dir(src, other))

/turf/proc/above()
	return get_step_multiz(src, UP)

/turf/proc/below()
	return get_step_multiz(src, DOWN)
