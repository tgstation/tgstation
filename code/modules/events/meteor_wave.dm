/datum/event/meteor_wave
	startWhen		= 6
	endWhen			= 66

/datum/event/meteor_wave/announce()
	command_alert("Meteors have been detected on collision course with the station.", "Meteor Alert")
	world << sound('sound/AI/meteors.ogg')


/datum/event/meteor_wave/tick()
	if(IsMultiple(activeFor, 3))
		spawn_meteors(5)