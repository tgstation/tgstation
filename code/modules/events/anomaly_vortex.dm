/datum/round_event_control/anomaly_vortex
	name = "Vortex Anomaly"
	typepath = /datum/round_event/anomaly_vortex
	max_occurrences = 5
	weight = 2

/datum/round_event/anomaly_vortex
	startWhen = 10
	var/obj/effect/anomaly/bhole/vortex


/datum/round_event/anomaly_vortex/announce()
	command_alert("Localized high-intensity gravitational anomaly detected on long range scanners.", "Anomaly Alert")
	for(var/mob/M in player_list)
		if(!istype(M,/mob/new_player))
			M << sound('sound/AI/granomalies.ogg')

/datum/round_event/anomaly_vortex/setup()
	endWhen = rand(20, 30)

/datum/round_event/anomaly_vortex/start()
	var/turf/T = pick(blobstart)
	vortex = new /obj/effect/anomaly/bhole(T.loc)

/datum/round_event/anomaly_vortex/tick()
	if(!vortex)
		kill()
		return
	vortex.anomalyEffect()

/datum/round_event/anomaly_vortex/end()
	if(vortex)
		del(vortex)