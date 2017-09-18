/datum/round_event_control/heart_attack
	name = "Random Heart Attack"
	typepath = /datum/round_event/heart_attack
	weight = 20
	max_occurrences = 2
	earliest_start = 12000
	min_players = 40 // To avoid shafting lowpop

/datum/round_event/heart_attack/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.living_mob_list))
		if(!H.client)
			continue
		if(H.stat == DEAD)
			continue
		if(!H.can_heartattack())
			continue
		var/foundAlready = FALSE
		for(var/datum/disease/heart_failure/F in H.viruses)
			foundAlready = TRUE
			break
		if(foundAlready || H.undergoing_cardiac_arrest())
			continue

		var/datum/disease/D = new /datum/disease/heart_failure
		H.ForceContractDisease(D)
		break
