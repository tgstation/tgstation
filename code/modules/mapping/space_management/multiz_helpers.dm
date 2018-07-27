/proc/get_step_multiz(ref, dir)
	if(dir == UP)
		return get_turf_above(get_turf(ref))
	if(dir == DOWN)
		return get_turf_below(get_turf(ref))
	return get_step(ref, dir)

/turf/proc/above()
	return get_step_multiz(src, UP)

/turf/proc/below()
	return get_step_multiz(src, DOWN)
