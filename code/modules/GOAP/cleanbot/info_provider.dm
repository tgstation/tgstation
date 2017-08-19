GLOBAL_LIST_INIT(cleanable_shit_yo, typecacheof(list(
	/obj/effect/decal/cleanable,
	/obj/item/trash // anime?
	)))


/datum/goap_info_provider/cleanbot/GetWorldState(datum/goap_agent/agent)
	. = list()
	.["cleanedMess"] = FALSE
	.["foamSpewed"] = FALSE
	.["cleanFaces"] = FALSE
	.["patrolStation"] = FALSE

/datum/goap_info_provider/cleanbot/GetGoal(datum/goap_agent/agent)
	. = list()
	var/list/viewl = spiral_range(10, agent.agent)
	var/P
	for(var/C in viewl)
		if(is_type_in_typecache(C, GLOB.cleanable_shit_yo))
			P = C
			break
	if(!P)
		.["patrolStation"] = TRUE
	else
		.["cleanedMess"] = TRUE
	if(B.emagged == 2)
		if(prob(15))
			.["foamSpewed"] = TRUE

		var/mob/living/carbon/C = locate(/mob/living/carbon) in viewl
		if(C)
			.["cleanFaces"] = TRUE