/datum/round_event_control/wizard/fake_explosion //Oh no the station is gone!
	name = "Fake Nuclear Explosion"
	typepath = /datum/round_event/wizard/fake_explosion/
	max_occurrences = 0 //Badmin exclusive now because once it's expected its not funny

/datum/round_event/wizard/fake_explosion/start()
	for(var/mob/M in player_list)
		M << 'sound/machines/Alarm.ogg'
	sleep(100)
	ticker.station_explosion_cinematic(1,"fake") //:o)