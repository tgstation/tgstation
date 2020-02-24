/datum/round_event_control/anomaly/anomaly_fluid
	name = "Anomaly: Fluescent"
	typepath = /datum/round_event/anomaly/anomaly_fluid

	min_players = 10
	max_occurrences = 5
	weight = 10

/datum/round_event/anomaly/anomaly_fluid
	startWhen = 10
	announceWhen = 3
	anomaly_path = /obj/effect/anomaly/fluid

/datum/round_event/anomaly/anomaly_fluid/announce(fake)
	priority_announce("Localized fluescent anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")
