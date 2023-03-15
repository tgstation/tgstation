/datum/round_event_control/anomaly/anomaly_clown
	name = "Anomaly: Clowns"
	typepath = /datum/round_event/anomaly/anomaly_clown

	max_occurrences = 1
	weight = 20

/datum/round_event/anomaly/anomaly_clown
	startWhen = 1
	anomaly_path = /obj/effect/anomaly/clown

/datum/round_event/anomaly/anomaly_clown/announce(fake)
	priority_announce("There should be clowns. Where are the clowns? [impact_area.name]. Send in the clowns.", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
