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
					var/atom/movable/lighting_overlay/O = new(T)
					O.icon_state = state
					all_lighting_overlays |= O
					T.lighting_overlays |= O
					#else
					for(var/i = 0; i < LIGHTING_RESOLUTION; i++)
						for(var/j = 0; j < LIGHTING_RESOLUTION; j++)
							var/atom/movable/lighting_overlay/O = new(T)
							O.pixel_x = i * (32 / LIGHTING_RESOLUTION)
							O.pixel_y = j * (32 / LIGHTING_RESOLUTION)
							O.xoffset = (((2*i + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
							O.yoffset = (((2*j + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
							O.icon_state = state
							all_lighting_overlays |= O
							T.lighting_overlays |= O
					#endif
	else
		for(var/x = 1; x <= world.maxx; x++)
			for(var/y = 1; y <= world.maxy; y++)
				var/turf/T = locate(x, y, zlevel)
				if(T.dynamic_lighting)
					A = T.loc
					if(A.lighting_use_dynamic)
						#if LIGHTING_RESOLUTION == 1
						var/atom/movable/lighting_overlay/O = new(T)
						O.icon_state = state
						all_lighting_overlays |= O
						T.lighting_overlays |= O
						#else
						for(var/i = 0; i < LIGHTING_RESOLUTION; i++)
							for(var/j = 0; j < LIGHTING_RESOLUTION; j++)
								var/atom/movable/lighting_overlay/O = new(T)
								O.pixel_x = i * (32 / LIGHTING_RESOLUTION)
								O.pixel_y = j * (32 / LIGHTING_RESOLUTION)
								O.xoffset = (((2*i + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
								O.yoffset = (((2*j + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
								O.icon_state = state
								all_lighting_overlays |= O
								T.lighting_overlays |= O
						#endif
