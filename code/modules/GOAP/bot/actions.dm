/datum/goap_action/bot/move_to_pathfinder
	name = "Move To Pathfinder"
	cost = 1

/datum/goap_action/bot/move_to_pathfinder/New()
	..()
	preconditions = list()
	preconditions["atPatrolPoint"] = FALSE
	effects = list()
	effects["atPatrolPoint"] = TRUE

/datum/goap_action/bot/move_to_pathfinder/AdvancedPreconditions(atom/agent, list/worldstate)
	var/list/viewl = range(14, agent)
	var/obj/machinery/pathfinder_tile/T = locate(/obj/machinery/pathfinder_tile) in viewl
	target = T
	return (target != null)

/datum/goap_action/bot/move_to_pathfinder/RequiresInRange()
	return TRUE

/datum/goap_action/bot/move_to_pathfinder/Perform(atom/agent)
	var/mob/living/simple_animal/bot/B = agent
	B.forceMove(get_turf(target))
	return TRUE

/datum/goap_action/bot/move_to_pathfinder/CheckDone(atom/agent)
	return agent.loc == get_turf(target)

/datum/goap_action/bot/patrol
	name = "Patrol Station (Dumb)" // todo: write a smart patrol that works with directions
	cost = 1

/datum/goap_action/bot/patrol/New()
	..()
	preconditions = list()
	preconditions["atPatrolPoint"] = TRUE
	effects = list()
	effects["isPatrolling"] = TRUE

/datum/goap_action/bot/patrol/AdvancedPreconditions(atom/agent, list/worldstate)
	var/obj/machinery/pathfinder_tile/my_PT
	for(var/A in get_turf(agent))
		if(istype(A, /obj/machinery/pathfinder_tile))
			my_PT = A
			break
	if(!my_PT)
		return FALSE
	var/obj/machinery/pathfinder_tile/PT = pick(GLOB.all_pathfinders - my_PT)
	target = PT
	path_to_use = GLOB.pathfinder_paths[my_PT][PT]
	return (target != null && path_to_use != null)

/datum/goap_action/bot/patrol/RequiresInRange()
	return TRUE

/datum/goap_action/bot/patrol/Perform(atom/agent)
	var/mob/living/simple_animal/bot/B = agent
	B.forceMove(get_turf(target))
	return TRUE

/datum/goap_action/bot/patrol/CheckDone(atom/agent)
	return agent.loc == get_turf(target)