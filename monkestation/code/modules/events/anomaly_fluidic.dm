/datum/round_event_control/anomaly/anomaly_fluidic
	name = "Anomaly: Fluidic"
	typepath = /datum/round_event/anomaly/anomaly_fluidic

	max_occurrences = 4
	weight = 20

/datum/round_event/anomaly/anomaly_fluidic
	startWhen = 1
	anomaly_path = /obj/effect/anomaly/fluid

/datum/round_event/anomaly/anomaly_fluidic/announce(fake)
	priority_announce("Fluidic anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
