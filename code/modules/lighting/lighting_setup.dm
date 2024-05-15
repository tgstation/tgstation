
/proc/create_all_lighting_objects()
	for(var/area/area as anything in GLOB.areas)
		if(!area.static_lighting)
			continue
		for (var/list/zlevel_turfs as anything in area.get_zlevel_turf_lists())
			for(var/turf/area_turf as anything in zlevel_turfs)
				if(area_turf.space_lit)
					continue
				new /datum/lighting_object(area_turf)
			CHECK_TICK
		CHECK_TICK
