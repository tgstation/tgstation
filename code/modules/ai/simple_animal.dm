/datum/goof_action/mob/wander
	cost = 1
	name = "Wander"
	world_state_changes = list("wandered" = 1)
	prereq_world_state = list("wandered" = 0, "has_target" = 0)

/datum/goof_action/mob/wander/perform_action(atom/owner)
	var/anydir = pick(GLOB.cardinal)
	if(isliving(owner))
		var/mob/living/L = owner
		if(L.Process_Spacemove(anydir))
			L.Move(get_step(L, anydir), anydir)
	return TRUE

/datum/goof_action/mob/wander/do_action(list/world_state_to_work_with)
	..()
	world_state_to_work_with["wandered"] = 0

/datum/goof_action/mob/move_to_target
	cost = 1
	name = "Move to Target"
	world_state_changes = list("adjacent_to_target" = 1)
	prereq_world_state = list("adjacent_to_target" = 0, "has_target" = 1)
	var/list/path = list()
	var/tries = 0

/datum/goof_action/mob/move_to_target/calculate_cost(atom/owner)
	if(!owner.ai_holder.world_state["target"])
		return initial(cost)
	return get_dist(get_turf(owner), get_turf(owner.ai_holder.world_state["target"]))

/datum/goof_action/mob/move_to_target/perform_action(atom/owner)
	if(!owner.ai_holder.world_state["target"])
		return FALSE
	path = AStar(owner, owner.ai_holder.world_state["target"], /turf/proc/Distance_cardinal)
	if(!path || path.len == 0) //A-star failed or a path/destination was not set.
		LAZYCLEARLIST(path)
		return 0
	var/dest = get_turf(owner.ai_holder.world_state["target"]) //We must always compare turfs, so get the turf of the dest var if dest was originally something else.
	var/turf/last_node = get_turf(path[path.len]) //This is the turf at the end of the path, it should be equal to dest.
	if(get_turf(owner) == dest) //We have arrived, no need to move again.
		return 1
	else if(dest != last_node) //The path should lead us to our given destination. If this is not true, we must stop.
		LAZYCLEARLIST(path)
		return 0
	while(!owner.Adjacent(owner.ai_holder.world_state["target"]))
		if(tries >= 3)
			tries = 0
			return FALSE
		if(path.len > 1)
			step_towards(owner, path[1])
			if(get_turf(owner) == path[1]) //Successful move
				LAZYREMOVE(path, path[1])
				tries = 0
			else
				tries++
				continue
		else if(owner.Adjacent(dest))
			LAZYCLEARLIST(path)
			break
	return TRUE