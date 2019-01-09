/datum/round_event_control/hypnosis
	name = "Hypnosis"
	typepath = /datum/round_event/hypnosis
	weight = 15
	min_players = 10

/datum/round_event/hypnosis
	announceWhen = 120
	var/count = 4

/datum/round_event/hypnosis/announce(fake)
	priority_announce("Auditing has discovered some psychotropic agents were added to the supply chain of [station_name()]'s food by corporate saboteurs, which have been found to increase suggestability in mice and clowns. Please be on the lookout for any odd behaviour.")

/datum/round_event/hypnosis/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mob_list))
		if(count <= 0)
			break

		if(!H.client)
			continue
		if(H.stat == DEAD)
			continue
		if(!H.getorgan(/obj/item/organ/brain))
			continue
		if(H.has_trait(TRAIT_NOHUNGER)) // Never ate the food.
			continue
		H.apply_status_effect(/datum/status_effect/trance, rand(10 SECONDS, 30 SECONDS), TRUE)
		announce_to_ghosts(H)
		count--
