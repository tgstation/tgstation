/datum/round_event_control/anomaly/anomaly_monkey
	name = "Anomaly: Monkey"
	typepath = /datum/round_event/anomaly/anomaly_monkey
	min_players = 20 //This one is legitimately more deadly and harder to escape than the pyro anomaly.
	max_occurrences = 1
	weight = 5

/datum/round_event/anomaly/anomaly_monkey
	startWhen = 1
	anomaly_path = /obj/effect/anomaly/monkey

/datum/round_event/anomaly/anomaly_monkey/announce(fake)
	priority_announce("Random Chimp Event detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", SSstation.announcer.get_rand_alert_sound())
