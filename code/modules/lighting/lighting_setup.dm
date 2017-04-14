/proc/create_all_lighting_objects()
	for (var/zlevel = 1 to world.maxz)
		create_lighting_objects_zlevel(zlevel)

/proc/create_lighting_objects_zlevel(zlevel)
	ASSERT(zlevel)
	var/turf/T
	var/thing
	for (thing in block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel)))
		T = thing
		if (!IS_DYNAMIC_LIGHTING(T))
			continue

		var/area/A = T.loc
		if (!IS_DYNAMIC_LIGHTING(A))
			continue

		new/atom/movable/lighting_object(T, TRUE)
		CHECK_TICK
