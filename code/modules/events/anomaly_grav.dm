/datum/round_event_control/anomaly/anomaly_grav
	name = "Anomaly: Gravitational"
	typepath = /datum/round_event/anomaly/anomaly_grav

	max_occurrences = 5
	weight = 25

/datum/round_event/anomaly/anomaly_grav
	startWhen = 3
	announceWhen = 20
	anomaly_path = /obj/effect/anomaly/grav

/datum/round_event_control/anomaly/anomaly_grav/high
	name = "Anomaly: Gravitational (High Intensity)"
	typepath = /datum/round_event/anomaly/anomaly_grav/high
	weight = 15
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/anomaly/anomaly_grav/high
	startWhen = 3
	announceWhen = 20
	anomaly_path = /obj/effect/anomaly/grav/high

/datum/round_event/anomaly/anomaly_grav/announce(fake)
	priority_announce("Gravitational anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")
