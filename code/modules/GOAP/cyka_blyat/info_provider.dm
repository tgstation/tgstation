/datum/goap_info_provider/russian/GetWorldState(datum/goap_agent/agent)
	. = list("AllyHealed" = FALSE, "AllyRearmed" = FALSE,
	"DodgeEnemy" = FALSE, "EnemyDead" = FALSE)
	.["AllyHealed"] = FALSE
	.["AllyRearmed"] = FALSE
	.["DodgeEnemy"] = FALSE
	.["EnemyDead"] = FALSE
	var/mob/living/simple_animal/hostile/russian/ranged/cyka = AGENT
	if(!cyka.ammo_left)
		.["HasAmmo"] = FALSE
	else
		.["HasAmmo"] = TRUE

/datum/goap_info_provider/russian/GetGoal(datum/goap_agent/agent)
	. = list()
	var/list/viewl = view(10, AGENT)
	for(var/mob/living/carbon/C in viewl)
		if(C && !C.stat)
			.["EnemyDead"] = TRUE // make our goal to KILL
			if(agent.has_action(/datum/goap_action/russian/dodge))
				.["DodgeEnemy"] = TRUE // dodge the enemy too
			break
	for(var/mob/living/simple_animal/hostile/russian/ranged/R in viewl)
		if(R.stat)
			continue
		if(R == AGENT)
			continue
		if(R.health < (R.maxHealth/2))
			if(agent.has_action(/datum/goap_action/russian/medic))
				.["AllyHealed"] = TRUE // make our goal to heal our ally
		if(!R.reloads_left)
			if(agent.has_action(/datum/goap_action/russian/resupply))
				.["AllyRearmed"] = TRUE // we wish to rearm our allies

	var/mob/living/simple_animal/hostile/russian/ranged/cyka = AGENT
	if(!cyka.ammo_left && cyka.reloads_left)
		.["HasAmmo"] = TRUE // we want to reload

/datum/goap_info_provider/russian_melee/GetWorldState(datum/goap_agent/agent)
	. = list()
	.["EnemyDead"] = FALSE
	.["DodgeEnemy"] = FALSE

/datum/goap_info_provider/russian_melee/GetGoal(datum/goap_agent/agent)
	. = list()
	var/list/viewl = view(10, AGENT)
	for(var/mob/living/carbon/C in viewl)
		if(C && !C.stat)
			.["EnemyDead"] = TRUE // make our goal to KILL
			if(agent.has_action(/datum/goap_action/russian/dodge))
				.["DodgeEnemy"] = TRUE // dodge the enemy too when you can
			break
