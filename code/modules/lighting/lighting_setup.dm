/proc/create_all_lighting_overlays()
	for (var/zlevel = 1 to world.maxz)
		create_lighting_overlays_zlevel(zlevel)

/proc/create_lighting_overlays_zlevel(var/zlevel)
	ASSERT(zlevel)

	for (var/turf/T in block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel)))
		if (!IS_DYNAMIC_LIGHTING(T))
			continue

		var/area/A = T.loc
		if (!IS_DYNAMIC_LIGHTING(A))
			continue

		new/atom/movable/lighting_overlay(T, TRUE)
