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
	var/list/extra_args
	switch(rand(1, 10))
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
			// Send the same delusion to everyone.
			picked_hallucination = pick(subtypesof(/datum/hallucination/delusion/preset))
			// Delusion will affect everyone BUT the hallucinator.
			extra_args = list(
				/* duration = */30 SECONDS,
				/* skip_nearby = */FALSE,
				/* affects_us = */FALSE,
				/* affects_others = */TRUE,
				/* play_wabbajack = */FALSE,
			)

		if(5)
			// Send the same delusion to everyone
			picked_hallucination = pick(subtypesof(/datum/hallucination/delusion/preset))
			// Delusion will affect only the hallucinator.
			extra_args = list(
				/* duration = */45 SECONDS,
				/* skip_nearby = */FALSE,
				/* affects_us = */TRUE,
				/* affects_others = */FALSE,
				/* play_wabbajack = */TRUE,
			)

		if(6 to 10)
			// Send the same generic hallucination type to everyone
			var/static/list/possible_hallucinations = list(
				/datum/hallucination/bolts,
				/datum/hallucination/chat,
				/datum/hallucination/death,
				/datum/hallucination/fake_flood,
				/datum/hallucination/fire,
				/datum/hallucination/message,
				/datum/hallucination/oh_yeah,
				/datum/hallucination/random_battle,
			)

			picked_hallucination = pick(possible_hallucinations)

	for(var/mob/living/alive_mob in GLOB.alive_mob_list)
		// Skipped for admin/ooc stuff
		if(alive_mob.z in SSmapping.levels_by_trait(ZTRAIT_CENTCOM))
			continue
		alive_mob.cause_hallucination(picked_hallucination, "mass hallucination", extra_args)
