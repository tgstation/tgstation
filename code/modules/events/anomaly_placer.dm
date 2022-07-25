/datum/anomaly_placer
	var/static/list/allowed_areas

/datum/anomaly_placer/proc/findValidArea()
	if(!allowed_areas)
		generateAllowedAreas()
	var/list/possible_areas = typecache_filter_list(GLOB.sortedAreas,allowed_areas)
	if (!length(possible_areas))
		CRASH("No valid areas for anomaly found.")

	var/area/landing_area = pick(possible_areas)
	var/list/turf_test = get_area_turfs(landing_area)
	if(!turf_test.len)
		CRASH("Anomaly : No valid turfs found for [landing_area] - [landing_area.type]")

	return landing_area

/datum/anomaly_placer/proc/generateAllowedAreas()
	//Places that shouldn't explode
	var/static/list/safe_area_types = typecacheof(list(
	/area/station/ai_monitored/turret_protected/ai,
	/area/station/ai_monitored/turret_protected/ai_upload,
	/area/station/engineering,
	/area/station/solars,
	/area/station/holodeck,
	/area/shuttle,
	/area/station/maintenance,))

	//Subtypes from the above that actually should explode.
	var/static/list/unsafe_area_subtypes = typecacheof(list(/area/station/engineering/break_room))

	allowed_areas = make_associative(GLOB.the_station_areas) - safe_area_types + unsafe_area_subtypes
