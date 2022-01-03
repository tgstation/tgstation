
/proc/create_all_lighting_objects()
	for(var/area/A in world)
		if(!A.static_lighting)
			continue

		for(var/turf/T in A)
			if(T.always_lit)
				continue
			new/datum/lighting_object(T)
			CHECK_TICK
		CHECK_TICK
