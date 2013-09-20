/datum/round_event_control/anomaly/anomaly_pyro
	name = "Pyroclastic Anomaly"
	typepath = /datum/round_event/anomaly/anomaly_pyro
	max_occurrences = 2
	weight = 15

/datum/round_event/anomaly/anomaly_pyro
	startWhen = 10
	announceWhen = 3
	endWhen = 70

	var/obj/effect/anomaly/pyro/newpyro


/datum/round_event/anomaly/anomaly_pyro/announce()
	command_alert("Atmospheric anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/anomaly_pyro/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newpyro = new /obj/effect/anomaly/pyro(T.loc)

/datum/round_event/anomaly/anomaly_pyro/tick()
	if(!newpyro)
		kill()
		return
	if(IsMultiple(activeFor, 5))
		newpyro.anomalyEffect()

/datum/round_event/anomaly/anomaly_pyro/end()
	if(newpyro)
		del(newpyro)