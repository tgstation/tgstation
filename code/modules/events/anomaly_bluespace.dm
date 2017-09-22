/datum/round_event_control/anomaly/anomaly_bluespace
	name = "Anomaly: Bluespace"
	typepath = /datum/round_event/anomaly/anomaly_bluespace
	max_occurrences = 1
	weight = 5

/datum/round_event/anomaly/anomaly_bluespace
	startWhen = 3
	announceWhen = 10


/datum/round_event/anomaly/anomaly_bluespace/announce()
	priority_announce("Unstable bluespace anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")


/datum/round_event/anomaly/anomaly_bluespace/start()
	var/turf/T = safepick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/bluespace(T)
