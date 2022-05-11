/datum/round_event_control/mass_hallucination
	name = "Mass Hallucination"
	typepath = /datum/round_event/mass_hallucination
	weight = 10
	max_occurrences = 2
	min_players = 1

/datum/round_event/mass_hallucination
	fakeable = FALSE

/datum/round_event/mass_hallucination/start()
	var/picked_hallucination
	switch(rand(1, 7))
		if(1)
			// Send the same sound to everyone
			picked_hallucination = pick(subtypesof(/datum/hallucination/fake_sound/normal))

		if(2)
			// Send the same sound to everyone
			picked_hallucination = pick(subtypesof(/datum/hallucination/fake_sound/weird))

		if(3)
			// Send the same message to everyone
			picked_hallucination = pick(subtypesof(/datum/hallucination/station_message) - /datum/hallucination/station_message/ratvar)

		if(4)
			// Send the same message to everyone
			picked_hallucination = pick(subtypesof(/datum/hallucination/delusion) - /datum/hallucination/delusion/custom)

		if(5 to 7)
			// Send the same generic hallucination type to everyone
			var/static/list/possible_hallucinations = list(
				/datum/hallucination/bolts,
				/datum/hallucination/bolts,
				/datum/hallucination/chat,
				/datum/hallucination/death,
				/datum/hallucination/delusion,
				/datum/hallucination/fake_flood,
				/datum/hallucination/fire,
				/datum/hallucination/message,
				/datum/hallucination/oh_yeah,
				/datum/hallucination/random_battle,
				/datum/hallucination/self_delusion,
			)

			picked_hallucination = pick(possible_hallucinations)

	for(var/mob/living/alive_mob in GLOB.alive_mob_list)
		// Skipped for admin/ooc stuff
		if(alive_mob.z in SSmapping.levels_by_trait(ZTRAIT_CENTCOM))
			continue
		alive_mob.cause_hallucination(picked_hallucination, source = "mass hallucination")
