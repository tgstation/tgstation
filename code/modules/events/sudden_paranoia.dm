/datum/round_event_control/renegade
	name = "Sudden Paranoia"
	typepath = /datum/round_event/renegade
	max_occurrences = 1
	min_players = 20
	category = EVENT_CATEGORY_HEALTH
	description = "A random crewmember becomes paranoid about his coworkers."

/datum/round_event/renegade
	fakeable = FALSE

/datum/round_event/renegade/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list))
		if(!H.client || !(ROLE_RENEGADE in H.client.prefs.be_special))
			continue
		if(H.stat == DEAD)
			continue
		if(H.mind.has_antag_datum(/datum/antagonist/renegade))
			continue
		if(!H.get_organ_by_type(/obj/item/organ/internal/brain))
			continue
		H.gain_trauma(/datum/brain_trauma/special/renegade)
		announce_to_ghosts(H)
		break
