/datum/goap_info_provider/russian/GetWorldState(datum/goap_agent/agent)
	. = list()
	.["allyNeedsHealed"] = FALSE
	.["allyNeedsAmmo"] = FALSE
	.["reloadNeeded"] = FALSE
	.["enemyDead"] = FALSE
	var/list/viewl = spiral_range(10, agent.agent)

	for(var/mob/living/simple_animal/hostile/russian/R in viewl)
		goap_debug("[agent.agent] FOUND [R]")
		if(R.stat)
			continue
		if(R == agent.agent)
			continue
		if(R.health < (R.maxHealth/2))
			goap_debug("[R] NEEDS HEALS")
			if(agent.has_action(/datum/goap_action/russian/medic))
				goap_debug("[agent.agent] IS ABLE TO HEAL")
				.["allyNeedsHealed"] = TRUE
		if(!R.reloads_left)
			goap_debug("[R] NEEDS AMMO")
			if(agent.has_action(/datum/goap_action/russian/resupply))
				goap_debug("[agent.agent] IS ABLE TO RESUPPLY")
				.["allyNeedsAmmo"] = TRUE

	var/mob/living/simple_animal/hostile/russian/cyka = agent.agent
	if(!cyka.ammo_left)
		if(cyka.reloads_left)
			.["reloadNeeded"] = TRUE

/datum/goap_info_provider/russian/GetGoal(datum/goap_agent/agent)
	. = list()
	var/list/viewl = spiral_range(10, agent.agent)
	var/mob/living/carbon/C = locate(/mob/living/carbon) in viewl
	if(C && !C.stat)
		.["enemyDead"] = TRUE
	.["allyNeedsHealed"] = FALSE
	.["allyNeedsAmmo"] = FALSE
	.["reloadNeeded"] = FALSE
	.["ammoNeeded"] = FALSE