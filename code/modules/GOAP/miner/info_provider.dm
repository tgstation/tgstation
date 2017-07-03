/datum/goap_info_provider/miner/GetWorldState(datum/goap_agent/agent)
	. = list()
	var/mob/living/carbon/human/H = agent.agent
	var/obj/item/weapon/pickaxe/P = locate(/obj/item/weapon/pickaxe) in H.get_contents()
	if(agent.agent)
		if(ismob(agent.agent))
			var/mob/living/carbon/M = agent.agent
			.["agent_alive"] = (M.health > 0)
	if(H.get_empty_held_indexes())
		.["freeHand"] = TRUE
	else
		.["freeHand"] = FALSE
	.["turfMined"] = FALSE
	if(!P)
		.["hasPickaxe"] = FALSE

/datum/goap_info_provider/miner/GetGoal(datum/goap_agent/agent)
	. = list()
	var/list/viewl = spiral_range(10, agent.agent)
	if(agent.agent)
		if(ismob(agent.agent))
			.["agent_alive"] = TRUE
	var/turf/closed/mineral/T = locate(/turf/closed/mineral) in viewl
	if(T)
		.["turfMined"] = TRUE