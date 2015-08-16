/datum/round_event_control/meteor_wave/dust
	name = "Minor Space Dust"
	typepath = /datum/round_event/meteor_wave/dust
	max_occurrences = 1000
	average_time = 5 //Minor event
	alertadmins = 0

/datum/round_event/meteor_wave/dust
	startWhen		= 1
	endWhen			= 2
	announceWhen	= 0

/datum/round_event/meteor_wave/dust/announce()
	return

/datum/round_event/meteor_wave/dust/start()
	spawn_meteors(5, meteorsC)	//Let's make it at least worth being an event.
								//Five space dusts will poke a few holes in maintenance.

/datum/round_event/meteor_wave/dust/tick()
	return
