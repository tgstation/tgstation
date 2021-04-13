// Normal strength

/datum/round_event_control/meteor_wave
	name = "Meteor Wave: Normal"
	typepath = /datum/round_event/meteor_wave
	weight = 4
	min_players = 15
	max_occurrences = 3
	earliest_start = 25 MINUTES

/datum/round_event/meteor_wave
	startWhen = 6
	endWhen = 66 // THE NUMBER OF DA BEAST
	announceWhen = 1
	var/list/wave_type
	var/wave_name = "normal"
	var/wave_amount = 3
	var/waves_spawned = 0
	var/wave_direction = NORTH

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
			wave_type = GLOB.meteors_normal
		if("threatening")
			wave_type = GLOB.meteors_threatening
		if("catastrophic")
			if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
				wave_type = GLOB.meteorsSPOOKY
			else
				wave_type = GLOB.meteors_catastrophic
		if("stress_test")
			wave_type = GLOB.meteors_stress_test
		if("meaty")
			wave_type = GLOB.meteorsB
		if("space dust")
			wave_type = GLOB.meteorsC
		if("halloween")
			wave_type = GLOB.meteorsSPOOKY
		else
			WARNING("Wave name of [wave_name] not recognised.")
			kill()
	wave_direction = pick(GLOB.diagonals)

/datum/round_event/meteor_wave/announce(fake)
	priority_announce("Meteors have been detected on collision course with the station from the [dir2text(wave_direction)].", "Gravitational Anomaly Alert", ANNOUNCER_METEORS)

/datum/round_event/meteor_wave/tick()
	if(ISMULTIPLE(activeFor, 3) && wave_amount > waves_spawned)
		spawn_meteors(5, wave_type, wave_direction) //meteor list types defined in gamemode/meteor/meteors.dm
		waves_spawned++

/datum/round_event_control/meteor_wave/threatening
	name = "Meteor Wave: Threatening"
	typepath = /datum/round_event/meteor_wave/threatening
	weight = 5
	min_players = 20
	max_occurrences = 3
	earliest_start = 35 MINUTES

/datum/round_event/meteor_wave/threatening
	wave_name = "threatening"
	wave_amount = 6

/datum/round_event_control/meteor_wave/catastrophic
	name = "Meteor Wave: Catastrophic"
	typepath = /datum/round_event/meteor_wave/catastrophic
	weight = 7
	min_players = 25
	max_occurrences = 3
	earliest_start = 45 MINUTES

/datum/round_event/meteor_wave/catastrophic
	wave_name = "catastrophic"
	wave_amount = 9

/datum/round_event_control/meteor_wave/stress_test
	name = "Meteor Wave: Server Stress Test"
	typepath = /datum/round_event/meteor_wave/stress_test
	weight = 0
	min_players = 25
	max_occurrences = 1
	earliest_start = 90 MINUTES

/datum/round_event/meteor_wave/stress_test
	wave_name = "stress_test"
	wave_amount = 11

