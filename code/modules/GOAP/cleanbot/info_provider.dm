/datum/goap_info_provider/cleanbot/GetWorldState(datum/goap_agent/agent)
	. = list()
	.["cleanedMess"] = FALSE
	.["isPatrolling"] = FALSE

/datum/goap_info_provider/cleanbot/GetGoal(datum/goap_agent/agent)
	. = list()
	var/list/viewl = view(10, agent.agent)
	var/P = locate(/obj/effect/decal/cleanable) in viewl
	if(!P)
		P = locate(/obj/item/trash) in viewl
		if(!P)
			P = locate(/mob/living/simple_animal/cockroach) in viewl
			if(!P)
				P = locate(/mob/living/simple_animal/mouse) in viewl
	if(P)
		.["cleanedMess"] = TRUE
	else
		.["isPatrolling"] = TRUE