
/proc/create_all_lighting_objects()
	for(var/area/A as anything in GLOB.areas)
		if(!A.static_lighting)
			continue

		for(var/turf/T as anything in A.get_contained_turfs())
			if(T.space_lit)
				continue
			new/datum/lighting_object(T)
			CHECK_TICK
		CHECK_TICK
