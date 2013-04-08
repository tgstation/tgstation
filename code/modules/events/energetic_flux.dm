/datum/round_event_control/energetic_flux
	name = "Energetic Flux"
	typepath = /datum/round_event/energetic_flux
	max_occurrences = 2
	weight = 15

/datum/round_event/energetic_flux
	startWhen	= 30

	var/area/impact_area


/datum/round_event/energetic_flux/setup()
	var/list/safe_areas = list(
	/area/turret_protected/ai,
	/area/turret_protected/ai_upload,
	/area/engine,
	/area/solar,
	/area/holodeck,
	/area/shuttle/arrival,
	/area/shuttle/escape/station,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod5/station,
	/area/shuttle/mining/station,
	/area/shuttle/transport1/station,
	/area/shuttle/prison/station,
	/area/shuttle/specops/station)

	//These are needed because /area/engine has to be removed from the list, but we still want these areas to get fucked up.
	var/list/danger_areas = list(
	/area/engine/break_room,
	/area/engine/chiefs_office)


	impact_area = locate(pick((the_station_areas - safe_areas) + danger_areas))	//need to locate() as it's just a list of paths.


/datum/round_event/energetic_flux/announce()
	command_alert("Warning! Localized hyper-energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name]. Vacate [impact_area.name].", "Anomaly Alert")


/datum/round_event/energetic_flux/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		explosion(T, -1, 2, 4, 5)