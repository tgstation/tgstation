/proc/create_all_lighting_overlays()
	for (var/zlevel = 1 to world.maxz)
		create_lighting_overlays_zlevel(zlevel)

/proc/create_lighting_overlays_zlevel(var/zlevel)
	ASSERT(zlevel)

	for (var/turf/T in block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel)))
		if (!LIGHTING_IS_DYNAMIC(T))
			continue

		var/area/A = T.loc
		if (!LIGHTING_IS_DYNAMIC(A))
			continue

		PoolorNew(/atom/movable/lighting_overlay, T, TRUE)
