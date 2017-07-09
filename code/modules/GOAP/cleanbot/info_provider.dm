/datum/goap_info_provider/cleanbot/GetWorldState(datum/goap_agent/agent)
	. = list()
	.["cleanedMess"] = FALSE
	.["foamSpewed"] = FALSE
	.["cleanFaces"] = FALSE

/datum/goap_info_provider/cleanbot/GetGoal(datum/goap_agent/agent)
	. = list()
	var/mob/living/simple_animal/bot/B = agent.agent
	.["cleanedMess"] = TRUE
	if(B.emagged == 2)
		if(prob(15))
			.["foamSpewed"] = TRUE
		var/list/viewl = spiral_range(10, agent.agent)
		var/mob/living/carbon/C = locate(/mob/living/carbon) in viewl
		if(C)
			.["cleanFaces"] = TRUE