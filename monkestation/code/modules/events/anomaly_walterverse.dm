/datum/round_event_control/anomaly/anomaly_walterverse
	name = "Anomaly: Walterverse"
	typepath = /datum/round_event/anomaly/anomaly_walterverse

	max_occurrences = 1
	weight = 5

/datum/round_event/anomaly/anomaly_walterverse
	startWhen = 1
	anomaly_path = /obj/effect/anomaly/walterverse

/datum/round_event/anomaly/anomaly_walterverse/announce(fake)
	priority_announce("The Walterverse has been opened. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
