/datum/round_event_control/creep
	name = "Creep Awakening"
	typepath = /datum/round_event/creep
	max_occurrences = 1
	min_players = 20

/datum/round_event/creep
	fakeable = FALSE

/datum/round_event/creep/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mob_list))
		if(!H.client)
			continue
		if(H.stat == DEAD)
			continue
		var/alreadycreepy = H.mind.has_antag_datum(/datum/antagonist/creep)
		if(alreadycreepy)
			continue
		if(!H.getorgan(/obj/item/organ/brain))
			continue
		H.gain_trauma(/datum/brain_trauma/special/creep)
		announce_to_ghosts(H)
		break
