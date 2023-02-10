/// Generates the global station area list, filling it with typepaths of unique areas found on the station Z.
/datum/controller/subsystem/mapping/generate_station_area_list()
	for(var/area/shuttle/station_area in GLOB.areas)
		if (!(station_area.area_flags & UNIQUE_AREA))
			continue
		if (is_station_level(station_area.z))
			GLOB.the_station_areas += station_area.type

	if(!GLOB.the_station_areas.len)
		log_world("ERROR: Station areas list failed to generate!")
