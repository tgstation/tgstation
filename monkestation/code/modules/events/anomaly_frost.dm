/datum/round_event_control/anomaly/anomaly_frost
	name = "Anomaly: Frost"
	typepath = /datum/round_event/anomaly/anomaly_frost
	min_players = 20
	max_occurrences = 3
	weight = 10

/datum/round_event/anomaly/anomaly_frost
	startWhen = 1
	anomaly_path = /obj/effect/anomaly/frost

/datum/round_event/anomaly/anomaly_frost/announce(fake)
	priority_announce("Frost Anomaly detected in: [impact_area.name]. Brace for the cold.", "Anomaly Alert", 'monkestation/sound/misc/frost_horn.ogg')
