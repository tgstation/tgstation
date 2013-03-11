/datum/event_control/meteor_wave
	name = "Meteor Wave"
	typepath = /datum/event/meteor_wave
	weight = 5
	max_occurrences = 3

/datum/event/meteor_wave
	startWhen		= 6
	endWhen			= 66

/datum/event/meteor_wave/announce()
	command_alert("Meteors have been detected on collision course with the station.", "Meteor Alert")
	world << sound('sound/AI/meteors.ogg')


/datum/event/meteor_wave/tick()
	if(IsMultiple(activeFor, 3))
		spawn_meteors(5)