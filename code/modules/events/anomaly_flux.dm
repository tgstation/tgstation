/datum/round_event_control/anomaly_flux
	name = "Energetic Flux"
	typepath = /datum/round_event/anomaly_flux
	max_occurrences = 2
	weight = 15

/datum/round_event/anomaly_flux
	startWhen = 3
	announceWhen = 20
	endWhen = 60

	var/area/impact_area
	var/obj/effect/anomaly/flux/newflux


/datum/round_event/anomaly_flux/setup()
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


/datum/round_event/anomaly_flux/announce()
	command_alert("Localized hyper-energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly_flux/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newflux = new /obj/effect/anomaly/flux(T.loc)

/datum/round_event/anomaly_flux/tick()
	if(!newflux)
		kill()
		return
	newflux.anomalyEffect()

/datum/round_event/anomaly_flux/end()
	if(newflux)//If it hasn't been neutralized, it's time to blow up.
		explosion(newflux, -1, 3, 5, 5)
		del(newflux)