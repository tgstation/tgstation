/datum/round_event_control/meteor_wave/dust
	name = "Minor Space Dust"
	typepath = /datum/round_event/meteor_wave/dust
	weight = 50		// A lot, but not so much that it’s a constant hazard.
	max_occurrences = 1000
	earliest_start = 3000	// Five minuets 
	alertadmins = 1 	// This is surprisingly lethal. Plus no announcement.

/datum/round_event/meteor_wave/dust
	startWhen		= 1
	endWhen			= 2
	announceWhen	= 0

/datum/round_event/meteor_wave/dust/announce()
	return

/datum/round_event/meteor_wave/dust/start()
	spawn_meteors(1, meteorsC)

/datum/round_event/meteor_wave/dust/tick()
	return
