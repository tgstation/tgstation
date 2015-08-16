/datum/round_event_control/meteor_wave
	name = "Meteor Wave"
	typepath = /datum/round_event/meteor_wave
	average_time = 35
	max_occurrences = 3

/datum/round_event/meteor_wave
	startWhen		= 6
	endWhen			= 66
	announceWhen	= 1
	var/list/wave_type

/datum/round_event/meteor_wave/New()
	init_meteors()
	..()

/datum/round_event/meteor_wave/proc/init_meteors()
	wave_type = meteors_normal

/datum/round_event/meteor_wave/announce()
	priority_announce("Meteors have been detected on collision course with the station.", "Meteor Alert", 'sound/AI/meteors.ogg')

/datum/round_event/meteor_wave/tick()
	if(IsMultiple(activeFor, 3))
		spawn_meteors(5, wave_type) //meteor list types defined in gamemode/meteor/meteors.dm



/datum/round_event_control/meteor_wave/threatening
	average_time = 55
	typepath = /datum/round_event/meteor_wave/threatening

/datum/round_event/meteor_wave/threatening/init_meteors()
	wave_type = meteors_threatening



/datum/round_event_control/meteor_wave/catastrophic
	average_time = 70
	typepath = /datum/round_event/meteor_wave/catastrophic

/datum/round_event/meteor_wave/catastrophic/init_meteors()
	wave_type = meteors_catastrophic



/datum/round_event_control/meteor_wave/meaty
	name = "Meaty Ore Wave"
	typepath = /datum/round_event/meteor_wave/meaty
	max_occurrences = 0

/datum/round_event/meteor_wave/meaty/init_meteors()
	wave_type = meteorsB

/datum/round_event/meteor_wave/meaty/announce()
	priority_announce("Meaty ores have been detected on collision course with the station.", "Oh crap, get the mop.",'sound/AI/meteors.ogg')