/var/list/lighting_update_lights	= list()	// List of light sources queued for update.
/var/list/lighting_update_overlays	= list()	// List of ligting overlays queued for update.
/var/list/all_lighting_overlays		= list()// Global list of lighting overlays.

/area/var/lighting_use_dynamic		= 1			// Disabling this variable on an area disables dynamic lighting.
// Duplicates lots of code, but this proc needs to be as fast as possible.
/proc/create_lighting_overlays(zlevel = 0)
	var/area/A
	var/count = 0
	if(zlevel == 0) // populate all zlevels
		for(var/turf/T in turfs)
			count++
			if(!(count % 50000)) sleep(world.tick_lag)
			if(T.dynamic_lighting)
				A = T.loc // Get the area.
				if(A.lighting_use_dynamic && !T.lighting_overlay)
					var/atom/movable/lighting_overlay/O = getFromPool(/atom/movable/lighting_overlay, T)
					all_lighting_overlays |= O
					T.lighting_overlay = O

	else
		for(var/x = 1; x <= world.maxx; x++)
			for(var/y = 1; y <= world.maxy; y++)
				count++
				if(!(count % 50000)) sleep(world.tick_lag)
				var/turf/T = locate(x, y, zlevel)
				if(T.dynamic_lighting)
					A = T.loc // Get the area.
					if(A.lighting_use_dynamic && !T.lighting_overlay)
						var/atom/movable/lighting_overlay/O = getFromPool(/atom/movable/lighting_overlay, T)
						all_lighting_overlays[count] = O
						T.lighting_overlay = O
