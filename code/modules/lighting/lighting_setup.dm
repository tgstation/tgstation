/proc/create_all_lighting_objects()
	var/config_dynamic_lighting = config.starlight
	for(var/I in GLOB.sortedAreas)
		var/area/A = I

		if(!IS_DYNAMIC_LIGHTING_CONFIGURED(A, config_dynamic_lighting))
			continue

		for(var/J in A)
			var/turf/T = J

			if(!IS_DYNAMIC_LIGHTING_CONFIGURED(T, config_dynamic_lighting))
				continue

			new/atom/movable/lighting_object(T, TRUE)
			CHECK_TICK
		CHECK_TICK
