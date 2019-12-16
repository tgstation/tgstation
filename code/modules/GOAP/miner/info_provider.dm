/datum/goap_info_provider/miner/GetWorldState(datum/goap_agent/agent)
	. = list()
	var/mob/living/carbon/human/H = AGENT
	var/obj/item/pickaxe/P = locate(/obj/item/pickaxe) in H.get_contents()
	if(AGENT)
		if(ismob(AGENT))
			var/mob/living/carbon/M = AGENT
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
	if(AGENT)
		if(ismob(AGENT))
			.["agent_alive"] = TRUE
	var/turf/closed/mineral/T = locate(/turf/closed/mineral) in RANGE_TURFS(10, agent.agent)
	if(T)
		.["turfMined"] = TRUE
