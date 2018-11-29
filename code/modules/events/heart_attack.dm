/datum/round_event_control/heart_attack
	name = "Random Heart Attack"
	typepath = /datum/round_event/heart_attack
	weight = 20
	max_occurrences = 2
	min_players = 40 // To avoid shafting lowpop

/datum/round_event/heart_attack/start()
	var/list/heart_attack_contestants = list()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list))
		if(!H.client || H.stat == DEAD || H.InCritical() || !H.can_heartattack() || H.has_status_effect(STATUS_EFFECT_EXERCISED) || (/datum/disease/heart_failure in H.diseases) || H.undergoing_cardiac_arrest())
			continue
		var/weight = 10
		if(H.satiety <= -60) //Multiple junk food items recently
			weight *= 3
		if(H.has_trait(TRAIT_LUCKY))
			weight *= 0.5
		if(H.has_trait(TRAIT_UNLUCKY))
			weight *= 2

		heart_attack_contestants[H] = weight

	if(LAZYLEN(heart_attack_contestants))
		var/mob/living/carbon/human/winner = pickweight(heart_attack_contestants)
		var/datum/disease/D = new /datum/disease/heart_failure()
		winner.ForceContractDisease(D, FALSE, TRUE)
		announce_to_ghosts(winner)
