
// MOVED HERE FROM ULTRALIGHT WHICH IS PROBABLY A BAD THING
#define UL_I_FALLOFF_SQUARE 0
#define UL_I_FALLOFF_ROUND 1
#define ul_FalloffStyle UL_I_FALLOFF_ROUND // Sets the lighting falloff to be either squared or circular.
var/list/ul_FastRoot = list(0, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5,
							5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
							7, 7)

atom/proc/ul_FalloffAmount(var/atom/ref)
	if (ul_FalloffStyle == UL_I_FALLOFF_ROUND)
		var/delta_x = (ref.x - src.x)
		var/delta_y = (ref.y - src.y)

		#ifdef ul_LightingResolution
		if (round((delta_x*delta_x + delta_y*delta_y)*ul_LightingResolutionSqrt,1) > ul_FastRoot.len)
			for(var/i = ul_FastRoot.len, i <= round(delta_x*delta_x+delta_y*delta_y*ul_LightingResolutionSqrt,1), i++)
				ul_FastRoot += round(sqrt(i))
		return ul_FastRoot[round((delta_x*delta_x + delta_y*delta_y)*ul_LightingResolutionSqrt, 1) + 1]/ul_LightingResolution

		#else
		if ((delta_x*delta_x + delta_y*delta_y) > ul_FastRoot.len)
			for(var/i = ul_FastRoot.len, i <= delta_x*delta_x+delta_y*delta_y, i++)
				ul_FastRoot += round(sqrt(i))
		return ul_FastRoot[delta_x*delta_x + delta_y*delta_y + 1]

		#endif

	else if (ul_FalloffStyle == UL_I_FALLOFF_SQUARE)
		return get_dist(src, ref)

	return 0