/datum/round_event_control/bruh_moment
	name = "Bruh Moment"
	typepath = /datum/round_event/bruh_moment
	weight = 10
	min_players = 1
	max_occurrences = 0

/datum/round_event/bruh_moment
	startWhen = 8
	fakeable = FALSE

/datum/round_event/bruh_moment/start()
	for(var/mob/B in shuffle(GLOB.alive_mob_list))
		if (ismob(B) && get_turf(B)) 	// SWAIN fix: on sleep(), ANYTHING can happen before the next character talks. Need to check if he exists or is in a location still, or else errors.
			B.say(";bruh")				// ALSO: alive_mob_list seems to contain mobs with no location, so this is doubly important.
			B.say("bruh")
			sleep(0.2)

/datum/round_event/bruh_moment/announce()
	priority_announce("NanoTrasen is issuing a Bruh Moment warning. Please stand by.", "Bruhspace Anomaly")
