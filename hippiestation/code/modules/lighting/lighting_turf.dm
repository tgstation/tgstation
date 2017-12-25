/turf/proc/get_rgb_lumcount(var/minlum = 0, var/maxlum = 1, var/r_mul = 1, var/g_mul = 1, var/b_mul = 1)
	if (!lighting_object)
		return 1

	var/totallums = 0
	var/thing
	var/datum/lighting_corner/L
	for (thing in corners)
		if(!thing)
			continue
		L = thing
		totallums += (L.lum_r * r_mul) + (L.lum_b * b_mul) + (L.lum_g * g_mul)

	totallums /= 12 // 4 corners, each with 3 channels, get the average.

	totallums = (totallums - minlum) / (maxlum - minlum)

	return CLAMP01(totallums)