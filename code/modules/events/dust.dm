/datum/round_event_control/space_dust
	name = "Minor Space Dust"
	typepath = /datum/round_event/space_dust
	weight = 200
	max_occurrences = 1000
	earliest_start = 0
	alertadmins = 0

/datum/round_event/space_dust
	startWhen		= 1
	endWhen			= 2
	announceWhen	= 0

/datum/round_event/space_dust/start()
	spawn_meteors(1, meteorsC)
