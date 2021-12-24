/datum/round_event_control/heart_attack
	name = "Random Heart Attack"
	typepath = /datum/round_event/heart_attack
	weight = 20
	max_occurrences = 2
	min_players = 40 // To avoid shafting lowpop

/datum/round_event/heart_attack/start()
	var/list/heart_attack_contestants = list()
	for(var/mob/living/carbon/human/victim in shuffle(GLOB.player_list))
		if(victim.stat == DEAD || HAS_TRAIT(victim, TRAIT_CRITICAL_CONDITION) || !victim.can_heartattack() || victim.has_status_effect(STATUS_EFFECT_EXERCISED) || (/datum/disease/heart_failure in victim.diseases) || victim.undergoing_cardiac_arrest())
			continue
		if(!(victim.mind.assigned_role.job_flags & JOB_CREW_MEMBER))//only crewmembers can get one, a bit unfair for some ghost roles and it wastes the event
			continue
		if((victim.satiety <= -60) && !HAS_TRAIT(victim, TRAIT_NOHUNGER)) //Multiple junk food items recently
			heart_attack_contestants[victim] = 3
		else
			heart_attack_contestants[victim] = 1

	if(LAZYLEN(heart_attack_contestants))
		var/mob/living/carbon/human/winner = pick_weight(heart_attack_contestants)
		var/datum/disease/D = new /datum/disease/heart_failure()
		winner.ForceContractDisease(D, FALSE, TRUE)
		announce_to_ghosts(winner)
