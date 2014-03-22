/datum/round_event_control/anomaly
	name = "Energetic Flux"
	typepath = /datum/round_event/anomaly
	max_occurrences = 0 //This one probably shouldn't occur! It'd work, but it wouldn't be very fun.
	weight = 15

/datum/round_event/anomaly
	var/area/impact_area
	var/obj/effect/anomaly/newAnomaly


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

/datum/round_event/anomaly/announce()
	command_alert("Localized hyper-energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/flux(T.loc)

/datum/round_event/anomaly/tick()
	if(!newAnomaly)
		kill()
		return
	newAnomaly.anomalyEffect()

/datum/round_event/anomaly/end()
	if(newAnomaly)//Kill the anomaly if it still exists at the end.
		qdel(newAnomaly)