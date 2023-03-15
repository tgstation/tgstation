/datum/round_event_control/anomaly/anomaly_storm
	name = "Anomaly: Storm"
	typepath = /datum/round_event/anomaly/anomaly_storm
	min_players = 25
	max_occurrences = 3
	weight = 5

/datum/round_event/anomaly/anomaly_storm
	startWhen = 1
	anomaly_path = /obj/effect/anomaly/storm

/datum/round_event/anomaly/anomaly_storm/announce(fake)
	priority_announce("Powerful Storm anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
