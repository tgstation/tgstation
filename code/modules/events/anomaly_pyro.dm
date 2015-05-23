/datum/round_event_control/anomaly/anomaly_pyro
	name = "Anomaly: Pyroclastic"
	typepath = /datum/round_event/anomaly/anomaly_pyro
	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_pyro
	startWhen = 10
	announceWhen = 3
	endWhen = 85


/datum/round_event/anomaly/anomaly_pyro/announce()
	priority_announce("Pyroclastic anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/anomaly_pyro/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/pyro(T.loc)

/datum/round_event/anomaly/anomaly_pyro/tick()
	if(!newAnomaly)
		kill()
		return
	if(IsMultiple(activeFor, 5))
		newAnomaly.anomalyEffect()


/datum/round_event/anomaly/anomaly_pyro/end()
	if(newAnomaly.loc)
		explosion(get_turf(newAnomaly), -1,0,3, flame_range = 4)

		var/mob/living/simple_animal/slime/S = new/mob/living/simple_animal/slime(get_turf(newAnomaly))
		S.colour = pick("red", "orange")

		qdel(newAnomaly)