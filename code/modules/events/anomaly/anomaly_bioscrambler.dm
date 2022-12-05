/datum/round_event_control/anomaly/anomaly_bioscrambler
	name = "Anomaly: Bioscrambler"
	typepath = /datum/round_event/anomaly/anomaly_bioscrambler

	min_players = 10
	max_occurrences = 5
	weight = 20
	description = "This anomaly replaces the limbs of nearby people."

/datum/round_event/anomaly/anomaly_bioscrambler
	start_when = 10
	announce_when = 3
	anomaly_path = /obj/effect/anomaly/bioscrambler

/datum/round_event/anomaly/anomaly_bioscrambler/announce(fake)
	priority_announce("Localized limb swapping agent. Expected location: [impact_area.name]. Wear biosuits to counter the effects. Calculated half-life of %9£$T$%F3 years", "Anomaly Alert")
