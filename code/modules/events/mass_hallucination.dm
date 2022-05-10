/datum/round_event_control/mass_hallucination
	name = "Mass Hallucination"
	typepath = /datum/round_event/mass_hallucination
	weight = 10
	max_occurrences = 2
	min_players = 1

/datum/round_event/mass_hallucination
	fakeable = FALSE

/datum/round_event/mass_hallucination/start()
	var/list/mob/living/hallucinating = list()
	for(var/mob/living/alive_mob in GLOB.alive_mob_list)
		// Skipped for admin/ooc stuff
		if(alive_mob.z in SSmapping.levels_by_trait(ZTRAIT_CENTCOM))
			continue
		hallucinating += alive_mob

	switch(rand(1, 4))
		if(1) // Plays a fake sound to everyone
			var/static/list/fake_sounds = list(
				"airlock",
				"airlock_pry",
				"console",
				"explosion",
				"far_explosion",
				"mech",
				"glass",
				"alarm",
				"beepsky",
				"mech",
				"wall_decon",
				"door_hack",
				"tesla",
			)

			// Same sound played to everyone
			var/played_to_all = pick(fake_sounds)
			for(var/mob/living/hallucinating as anything in hallucinating)
				hallucinating.cause_hallucination(/datum/hallucination/sounds, source = "mass hallucination", /* sound_type = */played_to_all)

		if(2) // Plays a (much weirder) fake sound to everyone
			var/static/list/wacky_sounds = list(
				"phone",
				"hallelujah",
				"highlander",
				"hyperspace",
				"game_over",
				"creepy",
				"tesla",
			)

			// Same sound played to everyone
			var/played_to_all = pick(wacky_sounds)
			for(var/mob/living/hallucinating as anything in hallucinating)
				hallucinating.cause_hallucination(/datum/hallucination/weird_sounds, source = "mass hallucination", /* sound_type = */played_to_all)

		if(3) // Sends a fake message to everyone

			// Same message sent to everyone.
			var/sent_to_all = pick(subtypesof(/datum/hallucination/station_message) - /datum/hallucination/station_message/ratvar)
			for(var/mob/living/hallucinating as anything in hallucinating)
				hallucinating.cause_hallucination(sent_to_all, source = "mass hallucination")

		if(4 to 6) // Causes a generic hallucination to everyone
			var/static/list/possible_hallucinations = list(
				/datum/hallucination/bolts,
				/datum/hallucination/chat,
				/datum/hallucination/message,
				/datum/hallucination/bolts,
				/datum/hallucination/fake_flood,
				/datum/hallucination/random_battle,
				/datum/hallucination/fire,
				/datum/hallucination/self_delusion,
				/datum/hallucination/death,
				/datum/hallucination/delusion,
				/datum/hallucination/oh_yeah,
			) + subtypesof(/datum/hallucination/delusion)

			// Same hallucination played for all
			var/picked_hallucination = pick(possible_hallucinations)
			for(var/mob/living/hallucinating as anything in hallucinating)
				hallucinating.cause_hallucination(picked_hallucination, source = "mass hallucination")
