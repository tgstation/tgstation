GLOBAL_LIST_INIT(dangerous_turfs, typecacheof(list(
	/turf/open/lava,
	/turf/open/chasm)))

#define MAX_TRIES 10
#define STATE_IDLE		0
#define STATE_MOVINGTO	1
#define STATE_ACTING	2

#define MOVETYPE_ASTAR 1
#define MOVETYPE_FAKESTAR 2
#define MOVETYPE_DUMB 3

/datum/goap_agent
	var/brain_state = STATE_IDLE
	var/list/our_actions //The actions available to us (/datum/goap_action)
	var/list/action_queue //The actions of our current plan (if any) (/datum/goap_action)
	//How we plan (Imagine a specific planner that ALWAYS prefers actions involving murder, regardless of cost, bloodlust agent!)
	var/datum/goap_planner/planner = /datum/goap_planner

	//Provides Info to the agent
	var/datum/goap_info_provider/info = /datum/goap_info_provider

	var/atom/agent //The actual atom that uses this brain (who knows, maybe you want to give a donut intelligence?)
	var/list/path
	var/turf/dest
	var/turf/last_node
	var/tries = 0
	var/obj/item/card/id/given_pathfind_access
	var/movetype = MOVETYPE_DUMB
	var/turf/current_loc
	var/actions_halted = FALSE
	var/already_acting = FALSE
	var/works_when_alone = FALSE
	var/movedelay
	var/movetimer
	var/astar_active = FALSE

/datum/goap_agent/proc/has_action(var/ACT)
	for(var/datum/goap_action/A in our_actions)
		if(istype(A, ACT) && !A.OnCooldown())
			return TRUE
	return FALSE

/datum/goap_agent/New()
	our_actions = list()
	action_queue = list()

	if(ispath(info))
		info = new info()
	else
		CRASH("GOAP AI created without info provider")
		return

	if(ispath(planner))
		planner = new planner()
	else
		CRASH("GOAP AI created without planner")
		return

	START_PROCESSING(SSgoap, src)

/datum/goap_agent/Destroy()
	STOP_PROCESSING(SSgoap, src)
	return ..()

/datum/goap_agent/proc/able_to_run()
	if(!agent)
		qdel(src)
		return FALSE
	if(actions_halted)
		return FALSE
	var/turf/T = get_turf(agent)
	if(T && length(SSmobs.clients_by_zlevel[T.z]) || works_when_alone)
		return TRUE
	return FALSE

/datum/goap_agent/proc/goap_process()
	if(!agent)
		return FALSE
	switch(brain_state)
		if(STATE_IDLE)
			idle_state()
		if(STATE_MOVINGTO)
			if(movetimer < world.time)
				movetimer = world.time + movedelay
				moving_state()
		if(STATE_ACTING)
			act_state()

/datum/goap_agent/proc/act_state()
	if(!LAZYLEN(action_queue))
		brain_state = STATE_IDLE
		return
	var/datum/goap_action/curr_action = action_queue[action_queue.len]
	var/range_check = curr_action.IsInRange(agent)
	if(curr_action.CheckDone(agent))
		curr_action.bturfs = list()
		action_queue.len--
		return
	if(already_acting)
		return
	if(!range_check)
		brain_state = STATE_MOVINGTO
		return
	already_acting = TRUE
	if(!curr_action.Perform(agent))
		brain_state = STATE_IDLE
		LAZYCLEARLIST(path)
		info.PlanAborted(curr_action)
		already_acting = FALSE
		return
	else if(action_queue.len == 1 && action_queue[1] == curr_action)
		brain_state = STATE_IDLE
		LAZYCLEARLIST(path)
		already_acting = FALSE
		return
	LAZYCLEARLIST(path)
	already_acting = FALSE

/datum/goap_agent/proc/moving_state()
	if(movedelay == null)
		if(ishostile(agent))
			var/mob/living/simple_animal/hostile/H = agent
			movedelay = H.move_to_delay
		else
			movedelay = 0
	if(astar_active)
		return
	var/datum/goap_action/curr_action = action_queue[action_queue.len]

	if(curr_action.RequiresInRange(agent) && !curr_action.target)
		brain_state = STATE_IDLE
		return
	var/dense_garbage
	for(var/obj/I in get_turf(curr_action.target))
		if(I.density)
			dense_garbage = TRUE
			break
	var/proc_to_use = /turf/proc/reachableTurftest
	switch(movetype)
		if(MOVETYPE_ASTAR) // AStar, Full
			if(!path || !path.len)
				astar_active = TRUE
				if(!curr_action.path_to_use)
					if(!isturf(curr_action.target))
						path = get_path_to(agent, get_turf(curr_action.target), /turf/proc/Distance_cardinal, 0, 200, adjacent = proc_to_use, id=given_pathfind_access, mintargetdist = dense_garbage)
					else
						path = get_path_to(agent, curr_action.target, /turf/proc/Distance_cardinal, 0, 200, adjacent = proc_to_use, id=given_pathfind_access, mintargetdist = dense_garbage)
					if(!path || !path.len) // still can't path
						if(!curr_action.PathingFailed(curr_action.target, current_loc))
							brain_state = STATE_IDLE
						astar_active = FALSE
						return
				else
					path = curr_action.path_to_use
			astar_active = FALSE
			last_node = get_turf(path[path.len]) //This is the turf at the end of the path, it should be equal to dest.
			current_loc = get_turf(agent)
			MoveTo_AStar(curr_action, path)
			curr_action.PerformWhileMoving(agent)
		if(MOVETYPE_FAKESTAR) // AStar, Fake
			current_loc = get_turf(agent)
			MoveTo_FakeStar(curr_action)
			curr_action.PerformWhileMoving(agent)
		if(MOVETYPE_DUMB) // No Pathfinding, Straight Line
			current_loc = get_turf(agent)
			MoveTo(curr_action)
			curr_action.PerformWhileMoving(agent)
	if(current_loc == get_turf(agent))
		tries++
		if(tries >= MAX_TRIES)
			if(!curr_action.PathingFailed(curr_action.target, current_loc))
				brain_state = STATE_IDLE
			tries = 0
			return
	else
		tries = 0



/datum/goap_agent/proc/idle_state()
	var/list/worldstate = info.GetWorldState(src)
	var/list/goal = info.GetGoal(src)
	if(!length(worldstate) || !length(goal)) // no goal, no worldstate
		info.PlanFailed(goal, worldstate)
		return
	var/list/plan = planner.Plan(agent, our_actions, worldstate, goal)

	if(!LAZYLEN(plan))
		info.PlanFailed(goal, worldstate)
		return

	action_queue = plan
	info.PlanFound(goal, plan)
	brain_state = STATE_ACTING

/datum/goap_agent/proc/MoveTo_AStar(datum/goap_action/curr_action, list/path)
	var/turf/dest = get_turf(curr_action.target)
	if(!path)
		return FALSE
	if(!last_node.Adjacent(dest))
		path = null // force a new path
		return FALSE
	if(path.len > 1)
		step_towards(agent, path[1])
		if(get_turf(agent) == path[1]) //Successful move
			path -= path[1]
	else if(path.len == 1)
		step_to(src, dest)
		path = list()
		curr_action.inn_range = TRUE
		brain_state = STATE_ACTING
	return TRUE

/datum/goap_agent/proc/MoveTo_FakeStar(datum/goap_action/action)
	if(!action.target)
		return
	if(get_dist(agent, action.target) > 1)
		if(!is_type_in_typecache(get_step(agent, get_dir(agent, action.target)), GLOB.dangerous_turfs))
			step_to(agent, action.target)
			action.PerformWhileMoving(agent)
	if(get_dist(agent, action.target) <= 1)
		action.inn_range = TRUE
		brain_state = STATE_ACTING

/datum/goap_agent/proc/MoveTo(datum/goap_action/action)
	if(!action.target)
		return
	if(get_dist(agent, action.target) > 1)
		if(!is_type_in_typecache(get_step(agent, get_dir(agent, action.target)), GLOB.dangerous_turfs))
			step_towards(agent, action.target)
			action.PerformWhileMoving(agent)
	if(get_dist(agent, action.target) <= 1)
		action.inn_range = TRUE
		brain_state = STATE_ACTING
