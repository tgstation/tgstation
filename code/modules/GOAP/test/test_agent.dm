

/datum/goap_agent/firemaker
	info = /datum/goap_info_provider/firemaker


/datum/goap_agent/firemaker/New()
	..()

	our_actions += new /datum/goap_action/make_fire()
	our_actions += new /datum/goap_action/collect_wood_from_ground()
	our_actions += new /datum/goap_action/get_axe()
	our_actions += new /datum/goap_action/chop_wood()


/datum/goap_info_provider/firemaker


/datum/goap_info_provider/firemaker/GetWorldState(datum/goap_agent/agent)
	. = list()
	if(agent.agent)
		.["hasFire"] = ((locate(/obj/fire) in view(agent.agent, 10)) != null)
	.["hasWood"] = FALSE
	.["hasAxe"] = FALSE


/datum/goap_info_provider/firemaker/GetGoal(datum/goap_agent/agent)
	. = list()
	.["hasFire"] = TRUE


/mob/firemaker/Initialize()
	..()
	icon = 'icons/obj/goap/world.dmi'
	icon_state = "person"
	var/datum/goap_agent/firemaker/F = new()
	F.agent = src