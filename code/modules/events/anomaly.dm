/datum/round_event_control/anomaly
	name = "Anomaly: Energetic Flux"
	typepath = /datum/round_event/anomaly

	min_players = 1
	max_occurrences = 0 //This one probably shouldn't occur! It'd work, but it wouldn't be very fun.
	weight = 15

/datum/round_event/anomaly
	var/area/impact_area
	var/obj/effect/anomaly/newAnomaly = /obj/effect/anomaly/flux
	announceWhen	= 1


/datum/round_event/anomaly/setup(loop=0)
	var/safety_loop = loop + 1
	if(safety_loop > 50)
		kill()
		end()
	impact_area = findEventArea()
	if(!impact_area)
		setup(safety_loop)
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test.len)
		setup(safety_loop)

/datum/round_event/anomaly/announce(fake)
	priority_announce("Localized energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/start()
	var/list/aturfs = get_area_turfs(impact_area)
	for(var/turf/T in aturfs)
		if(T.density)
			aturfs -= T
	var/turf/T = safepick(aturfs)
	if(ispath(newAnomaly) && T)
		newAnomaly = new newAnomaly(T)
		newAnomaly.layer = GASFIRE_LAYER+0.01
