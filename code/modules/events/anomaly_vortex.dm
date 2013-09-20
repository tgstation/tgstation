/datum/round_event_control/anomaly_vortex
	name = "Vortex Anomaly"
	typepath = /datum/round_event/anomaly_vortex
	max_occurrences = 5
	weight = 2

/datum/round_event/anomaly_vortex
	startWhen = 10
	announceWhen = 3
	endWhen = 80

	var/area/impact_area
	var/obj/effect/anomaly/bhole/vortex


/datum/round_event/anomaly_vortex/setup()
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
	/area/shuttle/specops/station)

	//These are needed because /area/engine has to be removed from the list, but we still want these areas to get fucked up.
	var/list/danger_areas = list(
	/area/engine/break_room,
	/area/engine/chiefs_office)


	impact_area = locate(pick((the_station_areas - safe_areas) + danger_areas))	//need to locate() as it's just a list of paths.

/datum/round_event/anomaly_vortex/announce()
	command_alert("Localized high-intensity vortex anomaly detected on long range scanners. Expected location: [impact_area.name]", "Anomaly Alert")

/datum/round_event/anomaly_vortex/start()
//	var/turf/T = pick(blobstart)
//	vortex = new /obj/effect/anomaly/bhole(T.loc)
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		vortex = new /obj/effect/anomaly/bhole(T.loc)


/datum/round_event/anomaly_vortex/tick()
	if(!vortex)
		kill()
		return
	vortex.anomalyEffect()

/datum/round_event/anomaly_vortex/end()
	if(vortex)
		del(vortex)