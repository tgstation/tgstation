/datum/goap_info_provider/lavaland/GetWorldState(datum/goap_agent/agent)
	. = list()
	.["enemyDead"] = FALSE
	.["specialAttack"] = FALSE

/datum/goap_info_provider/lavaland/GetGoal(datum/goap_agent/agent)
	. = list()
	var/list/viewl = spiral_range(10, agent.agent)
	var/mob/living/simple_animal/hostile/A = agent.agent
	var/mob/living/C = locate(/mob/living) in viewl
	if(C && C.stat != DEAD)
		.["enemyDead"] = TRUE
		if(A.ranged)
			if(prob(15) || (agent.is_megafauna && prob(15)))
				.["specialAttack"] = TRUE