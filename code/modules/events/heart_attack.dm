/datum/round_event_control/heart_attack
	name = "Random Heart Attack"
	typepath = /datum/round_event/heart_attack
	weight = 20
	max_occurrences = 2
	earliest_start = 12000
	min_players = 40 // To avoid shafting lowpop

/datum/round_event/heart_attack/start()
	for(var/mob/living/carbon/H in shuffle(GLOB.alive_mob_list))
		if(!H.client)
			continue
		if(H.stat == DEAD)
			continue
		if(!H.can_heartattack())
			continue
		var/foundAlready = FALSE
		if(H.has_status_effect(STATUS_EFFECT_EXERCISED))
			continue
		for(var/datum/disease/heart_failure/F in H.viruses)
			foundAlready = TRUE
			break
		if(foundAlready || H.undergoing_cardiac_arrest())
			continue

		var/datum/disease/D = new /datum/disease/heart_failure
		H.ForceContractDisease(D)
		notify_ghosts("[H] is beginning to have a heart attack!", enter_link="<a href=?src=[REF(H)];orbit=1>(Click to orbit)</a>", source=H, action=NOTIFY_ORBIT)
		break