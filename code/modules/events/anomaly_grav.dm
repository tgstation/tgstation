/datum/round_event_control/anomaly/anomaly_grav
	name = "Gravitational Anomaly"
	typepath = /datum/round_event/anomaly/anomaly_grav
	max_occurrences = 2
	weight = 15

/datum/round_event/anomaly/anomaly_grav
	startWhen = 3
	announceWhen = 20
	endWhen = 50

	var/obj/effect/anomaly/grav/newgrav


/datum/round_event/anomaly/anomaly_grav/announce()
	command_alert("Gravitational anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/anomaly_grav/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newgrav = new /obj/effect/anomaly/grav(T.loc)

/datum/round_event/anomaly/anomaly_grav/tick()
	if(!newgrav)
		kill()
		return
	newgrav.anomalyEffect()

/datum/round_event/anomaly/anomaly_grav/end()
	if(newgrav)//It's possible it could have been neutralized before this point.
		del(newgrav)