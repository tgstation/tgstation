/datum/round_event_control/anomaly
	name = "Anomaly: Energetic Flux"
	typepath = /datum/round_event/anomaly

	min_players = 1
	max_occurrences = 0 //This one probably shouldn't occur! It'd work, but it wouldn't be very fun.
	weight = 15

/datum/round_event/anomaly
	var/area/impact_area
	var/obj/effect/anomaly/newAnomaly
	announceWhen	= 1


/datum/round_event/anomaly/proc/findEventArea()
	//Places that shouldn't explode
	var/static/list/safe_area_types = typecacheof(list(
	/area/ai_monitored/turret_protected/ai,
	/area/ai_monitored/turret_protected/ai_upload,
	/area/engine,
	/area/solar,
	/area/holodeck,
	/area/shuttle)
	)

	//Subtypes from the above that actually should explode.
	var/static/list/unsafe_area_subtypes = typecacheof(/area/engine/break_room)

	var/static/list/allowed_areas
	if(!allowed_areas)
		allowed_areas = list()
		for(var/areatype in GLOB.the_station_areas)
			if(safe_area_types[areatype] && !unsafe_area_subtypes[areatype])
				continue
			else
				allowed_areas[areatype] = TRUE

	return safepick(typecache_filter_list(GLOB.sortedAreas,allowed_areas))

/datum/round_event/anomaly/setup(loop=0)
	impact_area = findEventArea()
	if(!impact_area)
		CRASH("No valid areas for anomaly found.")
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test.len)
		CRASH("Anomaly : No valid turfs found for [impact_area] - [impact_area.type]")

/datum/round_event/anomaly/announce(fake)
	priority_announce("Localized energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/start()
	var/turf/T = safepick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/flux(T)

