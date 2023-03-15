/datum/round_event_control/anomaly/anomaly_radioactive
	name = "Anomaly: Radioactive"
	typepath = /datum/round_event/anomaly/anomaly_radioactive

	max_occurrences = 3
	weight = 10

/datum/round_event/anomaly/anomaly_radioactive
	startWhen = 1
	anomaly_path = /obj/effect/anomaly/radioactive

/datum/round_event/anomaly/anomaly_radioactive/announce(fake)
	priority_announce("Radioactive anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
