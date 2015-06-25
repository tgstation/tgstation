/var/list/lighting_update_lights = list()
/var/list/lighting_update_overlays = list()
/var/list/all_lighting_overlays = list()

/area/var/lighting_use_dynamic = 1

// duplicates lots of code, but this proc needs to be as fast as possible.
/proc/create_lighting_overlays(zlevel = 0)
	var/state = "light[LIGHTING_RESOLUTION]"
	var/area/A
	if(zlevel == 0) // populate all zlevels
		for(var/turf/T in turfs)
			if(T.dynamic_lighting)
				A = T.loc
				if(A.lighting_use_dynamic)
					#if LIGHTING_RESOLUTION == 1
					var/atom/movable/lighting_overlay/O = PoolOrNew(/atom/movable/lighting_overlay, T)
					O.icon_state = state
					all_lighting_overlays += O
					T.lighting_overlay = O
					#else
					for(var/i = 0; i < LIGHTING_RESOLUTION; i++)
						for(var/j = 0; j < LIGHTING_RESOLUTION; j++)
							var/atom/movable/lighting_overlay/O = PoolOrNew(/atom/movable/lighting_overlay, T)
							O.pixel_x = i * (32 / LIGHTING_RESOLUTION)
							O.pixel_y = j * (32 / LIGHTING_RESOLUTION)
							O.xoffset = (((2*i + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
							O.yoffset = (((2*j + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
							O.icon_state = state
							all_lighting_overlays += O
							T.lighting_overlays += O
					#endif
	else
		for(var/x = 1; x <= world.maxx; x++)
			for(var/y = 1; y <= world.maxy; y++)
				var/turf/T = locate(x, y, zlevel)
				if(T.dynamic_lighting)
					A = T.loc
					if(A.lighting_use_dynamic)
						#if LIGHTING_RESOLUTION == 1
						var/atom/movable/lighting_overlay/O = PoolOrNew(/atom/movable/lighting_overlay, T)
						O.icon_state = state
						all_lighting_overlays += O
						T.lighting_overlay = O
						#else
						for(var/i = 0; i < LIGHTING_RESOLUTION; i++)
							for(var/j = 0; j < LIGHTING_RESOLUTION; j++)
								var/atom/movable/lighting_overlay/O = PoolOrNew(/atom/movable/lighting_overlay, T)
								O.pixel_x = i * (32 / LIGHTING_RESOLUTION)
								O.pixel_y = j * (32 / LIGHTING_RESOLUTION)
								O.xoffset = (((2*i + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
								O.yoffset = (((2*j + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
								O.icon_state = state
								all_lighting_overlays += O
								T.lighting_overlays += O
						#endif






// Not actually used for lighting, but still here because I guess it was planned for lighting once upon a time
#define UL_I_FALLOFF_SQUARE 0
#define UL_I_FALLOFF_ROUND 1
#define ul_FalloffStyle UL_I_FALLOFF_ROUND // Sets the lighting falloff to be either squared or circular.
var/list/ul_FastRoot = list(0, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5,
							5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
							7, 7)  //Oy, isn't this off by one?

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