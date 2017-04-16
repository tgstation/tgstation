/datum/round_event_control/anomaly/anomaly_pyro
	name = "Anomaly: Pyroclastic"
	typepath = /datum/round_event/anomaly/anomaly_pyro
	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_pyro
	startWhen = 3
	announceWhen = 10

/datum/round_event/anomaly/anomaly_pyro/announce()
	priority_announce("Pyroclastic anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/anomaly_pyro/start()
	var/turf/T = safepick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/pyro(T)
