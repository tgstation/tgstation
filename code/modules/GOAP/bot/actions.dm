/datum/goap_action/bot/patrol
	name = "Patrol Station (Dumb)" // todo: write a smart patrol that works with directions
	cost = 1

/datum/goap_action/bot/patrol/New()
	..()
	preconditions = list()
	effects = list()
	effects["isPatrolling"] = TRUE

/datum/goap_action/bot/patrol/AdvancedPreconditions(atom/agent, list/worldstate)
	var/obj/machinery/pathfinder_tile/my_PT
	for(var/A in get_turf(agent))
		if(istype(A, /obj/machinery/pathfinder_tile))
			my_PT = A
			break
	var/obj/machinery/pathfinder_tile/PT = pick(GLOB.all_pathfinders)
	target = PT
	if(my_PT)
		path_to_use = GLOB.pathfinder_paths[my_PT][PT]
	return (target != null)

/datum/goap_action/bot/patrol/RequiresInRange()
	return TRUE

/datum/goap_action/bot/patrol/Perform(atom/agent)
	var/mob/living/simple_animal/bot/B = agent
	B.forceMove(get_turf(target))
	return TRUE

/datum/goap_action/bot/patrol/CheckDone(atom/agent)
	return agent.loc == get_turf(target)