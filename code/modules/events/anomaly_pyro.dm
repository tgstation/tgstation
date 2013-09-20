/datum/round_event_control/anomaly_pyro
	name = "Pyroclastic Anomaly"
	typepath = /datum/round_event/anomaly_pyro
	max_occurrences = 2
	weight = 15

/datum/round_event/anomaly_pyro
	startWhen = 10
	announceWhen = 3
	endWhen = 70

	var/area/impact_area
	var/obj/effect/anomaly/pyro/newpyro


/datum/round_event/anomaly_pyro/setup()//TODO: Make this location stuff into a helper proc to be used in other events.
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


/datum/round_event/anomaly_pyro/announce()
	command_alert("Atmospheric anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly_pyro/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newpyro = new /obj/effect/anomaly/pyro(T.loc)

/datum/round_event/anomaly_pyro/tick()
	if(!newpyro)
		kill()
		return
	if(IsMultiple(activeFor, 5))
		newpyro.anomalyEffect()

/datum/round_event/anomaly_pyro/end()
	if(newpyro)//It's possible it could have been neutralized before this point.
		del(newpyro)