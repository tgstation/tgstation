/datum/round_event_control/meteor_wave
	name = "Meteor Wave"
	typepath = /datum/round_event/meteor_wave
	weight = 5
	max_occurrences = 3

/datum/round_event/meteor_wave
	startWhen		= 6
	endWhen			= 66
	announceWhen	= 1
	var/list/wave_type

/datum/round_event/meteor_wave/New()
	..()
	random_wave_type()

/datum/round_event/meteor_wave/proc/random_wave_type()
	var/picked_wave = pickweight(list("normal" = 50, "threatening" = 40, "catastrophic" = 10))
	switch(picked_wave)
		if("normal")
			wave_type = meteors_normal
		if("threatening")
			wave_type = meteors_threatening
		if("catastrophic")
			wave_type = meteors_catastrophic

/datum/round_event/meteor_wave/announce()
	priority_announce("Meteors have been detected on collision course with the station.", "Meteor Alert", 'sound/AI/meteors.ogg')


/datum/round_event/meteor_wave/tick()
	if(IsMultiple(activeFor, 3))
		spawn_meteors(5, wave_type) //meteor list types defined in gamemode/meteor/meteors.dm
