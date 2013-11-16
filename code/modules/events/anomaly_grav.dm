/datum/round_event_control/anomaly/anomaly_grav
	name = "Gravitational Anomaly"
	typepath = /datum/round_event/anomaly/anomaly_grav
	max_occurrences = 2
	weight = 15

/datum/round_event/anomaly/anomaly_grav
	startWhen = 3
	announceWhen = 20
	endWhen = 50


/datum/round_event/anomaly/anomaly_grav/announce()
	command_alert("Gravitational anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/anomaly_grav/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/grav(T.loc)