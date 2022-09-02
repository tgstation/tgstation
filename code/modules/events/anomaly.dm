/datum/round_event_control/anomaly
	name = "Anomaly: Energetic Flux"
	typepath = /datum/round_event/anomaly

	min_players = 1
	max_occurrences = 0 //This one probably shouldn't occur! It'd work, but it wouldn't be very fun.
	weight = 15
	category = EVENT_CATEGORY_ANOMALIES
	description = "This anomaly shocks and explodes. This is the base type."

/datum/round_event/anomaly
	var/area/impact_area
	var/datum/anomaly_placer/placer = new()
	var/obj/effect/anomaly/anomaly_path = /obj/effect/anomaly/flux
	announce_when = 1

/datum/round_event/anomaly/setup()
	impact_area = placer.findValidArea()

/datum/round_event/anomaly/announce(fake)
	priority_announce("Localized energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/start()
	var/turf/anomaly_turf = placer.findValidTurf(impact_area)
	var/newAnomaly
	if(anomaly_turf)
		newAnomaly = new anomaly_path(anomaly_turf)
	if (newAnomaly)
		announce_to_ghosts(newAnomaly)
