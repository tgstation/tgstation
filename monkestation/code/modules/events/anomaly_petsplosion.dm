/datum/round_event_control/anomaly/anomaly_petsplosion
	name = "Anomaly: Petsplosion"
	typepath = /datum/round_event/anomaly/anomaly_petsplosion

	max_occurrences = 2
	weight = 15

/datum/round_event/anomaly/anomaly_petsplosion
	startWhen = 1
	anomaly_path = /obj/effect/anomaly/petsplosion

/datum/round_event/anomaly/anomaly_petsplosion/announce(fake)
	priority_announce("Lifebringer anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
