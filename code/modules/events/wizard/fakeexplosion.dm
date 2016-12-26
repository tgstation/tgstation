/datum/round_event_control/wizard/fake_explosion //Oh no the station is gone!
	name = "Fake Nuclear Explosion"
	weight = 0 //Badmin exclusive now because once it's expected its not funny
	typepath = /datum/round_event/wizard/fake_explosion
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/wizard/fake_explosion/start()
	for(var/mob/M in player_list)
		M << 'sound/machines/Alarm.ogg'
	spawn(100)
		ticker.station_explosion_cinematic(1,"fake") //:o)