

/datum/goap_action/chop_wood
	name = "chop wood"
	cost = 2

/datum/goap_action/chop_wood/New()
	..()
	preconditions = list()
	preconditions["hasAxe"] = TRUE
	preconditions["hasWood"] = FALSE
	effects = list()
	effects["hasWood"] = TRUE

/datum/goap_action/chop_wood/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = oview(10, agent)
	var/obj/tree/T = locate() in viewl
	target = T
	return (target != null)

/datum/goap_action/chop_wood/RequiresInRange()
	return TRUE

/datum/goap_action/chop_wood/Perform(atom/agent)
	del(target) //the tree
	agent.contents += new /obj/wood ()
	return TRUE

/datum/goap_action/chop_wood/CheckDone(atom/agent)
	return ((target == null) && (locate(/obj/wood) in agent))



/datum/goap_action/get_axe
	name = "get axe"
	cost = 2

/datum/goap_action/get_axe/New()
	..()
	preconditions = list()
	preconditions["hasAxe"] = FALSE
	effects = list()
	effects["hasAxe"] = TRUE

/datum/goap_action/get_axe/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = oview(10, agent)
	var/obj/axe/A = locate() in viewl
	target = A
	return (target != null)

/datum/goap_action/get_axe/RequiresInRange()
	return TRUE

/datum/goap_action/get_axe/Perform(atom/agent)
	var/atom/movable/AM = target
	AM.loc = agent
	return TRUE

/datum/goap_action/get_axe/CheckDone(atom/agent)
	return (target in agent)



/datum/goap_action/collect_wood_from_ground
	name = "collect wood from ground"
	cost = 5

/datum/goap_action/collect_wood_from_ground/New()
	..()
	preconditions = list()
	preconditions["hasWood"] = FALSE
	effects = list()
	effects["hasWood"] = TRUE

/datum/goap_action/collect_wood_from_ground/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = oview(10, agent)
	var/obj/wood/W = locate() in viewl
	target = W
	return (target != null)

/datum/goap_action/collect_wood_from_ground/RequiresInRange()
	return TRUE

/datum/goap_action/collect_wood_from_ground/Perform(atom/agent)
	var/atom/movable/AM = target
	AM.loc = agent
	return TRUE

/datum/goap_action/collect_wood_from_ground/CheckDone(atom/agent)
	return (target in agent)



/datum/goap_action/make_fire
	name = "make fire"
	cost = 1
	var/made_fire = FALSE

/datum/goap_action/make_fire/New()
	..()
	preconditions = list()
	preconditions["hasWood"] = TRUE
	preconditions["hasFire"] = FALSE
	effects = list()
	effects["hasFire"] = TRUE

/datum/goap_action/make_fire/Perform(atom/agent)
	var/obj/wood/W = locate() in agent.contents
	if(W)
		new /obj/fire (get_turf(agent))
		del(W)
		made_fire = TRUE
		return TRUE
	return FALSE

/datum/goap_action/make_fire/CheckDone(atom/agent)
	return made_fire