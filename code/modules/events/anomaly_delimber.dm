/datum/round_event_control/anomaly/anomaly_delimber
	name = "Anomaly: Delimber"
	typepath = /datum/round_event/anomaly/anomaly_delimber

	min_players = 10
	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_delimber
	startWhen = 10
	announceWhen = 3
	anomaly_path = /obj/effect/anomaly/delimber

/datum/round_event/anomaly/anomaly_delimber/announce(fake)
	priority_announce("Localized limb swapping agent. Expected location: [impact_area.name]. Wear biosuits to counter the effects. Calculated half-life of %9£$T$%F3 years", "Anomaly Alert")
