/datum/goof_action/mob/wander
	cost = 1
	name = "Wander"
	world_state_changes = list("wandered" = 1)
	prereq_world_state = list("wandered" = 0)

/datum/goof_action/mob/wander/perform_action(atom/owner)
	var/anydir = pick(GLOB.cardinal)
	if(owner.Process_Spacemove(anydir))
		owner.Move(get_step(owner, anydir), anydir)
	owner.ai_holder.world_state["wandered"] = 0
	return TRUE

/datum/goof_action/mob/move_to_target
	cost = 1
	name = "Move to Target"
	world_state_changes = list("adjacent_to_target" = 1)
	prereq_world_state = list("adjacent_to_target" = 0, "has_target" = 1)
	var/list/path = list()
	var/tries = 0

/datum/goof_action/mob/move_to_target/calculate_cost(atom/owner, list/data = null)
	return get_dist(get_turf(owner), get_turf(owner.ai_holder.world_state["target"])

/datum/goof_action/mob/move_to_target/perform_action(atom/owner) // heavily copypasted from robots
	path = AStar(owner, owner.ai_holder.world_state["target"], /turf/proc/Distance_cardinal)
	if(!path || path.len == 0) //A-star failed or a path/destination was not set.
		path = list()
		return 0
	dest = get_turf(dest) //We must always compare turfs, so get the turf of the dest var if dest was originally something else.
	var/turf/last_node = get_turf(path[path.len]) //This is the turf at the end of the path, it should be equal to dest.
	if(get_turf(owner) == dest) //We have arrived, no need to move again.
		return 1
	else if(dest != last_node) //The path should lead us to our given destination. If this is not true, we must stop.
		path = list()
		return 0
	while(!owner.Adjacent(owner.ai_holder.world_state["target"]))
		if(tries >= 3)
			return FALSE
		if(path.len > 1)
			step_towards(owner, path[1])
			if(get_turf(owner) == path[1]) //Successful move
				path -= path[1]
				tries = 0
			else
				tries++
				continue
		else if(owner.Adjacent(dest))
			path = list()
			break
	return TRUE