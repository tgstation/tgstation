/datum/round_event_control/anomaly/anomaly_vortex
	name = "Vortex Anomaly"
	typepath = /datum/round_event/anomaly/anomaly_vortex
	max_occurrences = 5
	weight = 2

/datum/round_event/anomaly/anomaly_vortex
	startWhen = 10
	announceWhen = 3
	endWhen = 80


/datum/round_event/anomaly/anomaly_vortex/announce()
	priority_announce("Localized high-intensity vortex anomaly detected on long range scanners. Expected location: [impact_area.name]", "Anomaly Alert")

/datum/round_event/anomaly/anomaly_vortex/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/bhole(T.loc)