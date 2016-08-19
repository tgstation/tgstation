// Normal strength

/datum/round_event_control/meteor_wave
	name = "Meteor Wave: Normal"
	typepath = /datum/round_event/meteor_wave
	weight = 4
	min_players = 5
	max_occurrences = 3

/datum/round_event/meteor_wave
	startWhen		= 6
	endWhen			= 66
	announceWhen	= 1
	var/list/wave_type
	var/wave_name = "normal"

/datum/round_event/meteor_wave/New()
	..()
	if(!wave_type)
		determine_wave_type()

/datum/round_event/meteor_wave/proc/determine_wave_type()
	if(!wave_name)
		wave_name = pickweight(list(
			"normal" = 50,
			"threatening" = 40,
			"catastrophic" = 10))
	switch(wave_name)
		if("normal")
			wave_type = meteors_normal
		if("threatening")
			wave_type = meteors_threatening
		if("catastrophic")
			wave_type = meteors_catastrophic
		if("meaty")
			wave_type = meteorsB
		if("space dust")
			wave_type = meteorsC
		else
			WARNING("Wave name of [wave_name] not recognised.")
			kill()

/datum/round_event/meteor_wave/announce()
	priority_announce("Meteors have been detected on collision course with the station.", "Meteor Alert", 'sound/AI/meteors.ogg')

/datum/round_event/meteor_wave/tick()
	if(IsMultiple(activeFor, 3))
		spawn_meteors(5, wave_type) //meteor list types defined in gamemode/meteor/meteors.dm

/datum/round_event_control/meteor_wave/threatening
	name = "Meteor Wave: Threatening"
	typepath = /datum/round_event/meteor_wave/threatening
	weight = 2
	min_players = 5
	max_occurrences = 3

/datum/round_event/meteor_wave/threatening
	wave_name = "threatening"

/datum/round_event_control/meteor_wave/catastrophic
	name = "Meteor Wave: Catastrophic"
	typepath = /datum/round_event/meteor_wave/catastrophic
	weight = 1
	min_players = 5
	max_occurrences = 3

/datum/round_event/meteor_wave/catastrophic
	wave_name = "catastrophic"
