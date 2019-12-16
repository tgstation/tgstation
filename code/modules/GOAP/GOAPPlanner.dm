
/datum/goap_planner
	var/list/stored_nodes = list()


/datum/goap_planner/proc/Plan(atom/agent, list/actions, list/worldstate, list/goal)
	for(var/a in actions)
		var/datum/goap_action/GA = a
		GA.Reset()

	var/list/usable_actions = list()

	for(var/a in actions)
		var/datum/goap_action/GA = a
		if(GA.OnCooldown(agent, worldstate))
			continue
		if(GA.AdvancedPreconditions(agent, worldstate))
			usable_actions += GA

	//Oh god, trees! I hate this!

	var/list/plan_tree = list()

	var/datum/goap_plan_node/start = new()
	start.state = goal
	var/list/end = worldstate

	plan_tree = BuildPossiblePlans(end, start, usable_actions, goal)

	if(!plan_tree.len)
		return null

	//Cheapest path
	var/datum/goap_plan_node/cheapest
	for(var/node in plan_tree)
		var/datum/goap_plan_node/N = node
		if(!cheapest || N.cost < cheapest.cost)
			cheapest = N
	//Go up the tree, from the cheapest bottom leaf
	var/list/climblist = list()
	var/datum/goap_plan_node/climber = cheapest
	while(climber)
		if(climber.action)
			climblist += climber.action
		climber = climber.parent
	//Reverse the plan
	var/list/plan = list()
	for(var/i = climblist.len to 1 step -1)
		plan += climblist[i]
	return plan


//Works backwards from the goal to the start to find the best path
//TODO: remove recursion
/datum/goap_planner/proc/BuildPossiblePlans(list/end, datum/goap_plan_node/parent, list/usable_actions, list/goal)
	var/list/plan_tree = list()
	for(var/a in usable_actions)
		var/datum/goap_action/GA = a
		if(!InState(GA.effects, parent.state, "usable_actions")) // this won't get us to the goal
			continue
		//What does the world look like if we run this action?
		var/list/current_state = ShowMeTheFuture(parent.state, GA.effects, GA.preconditions) // remove the effects and add the preconditions
		var/datum/goap_plan_node/node = new()
		node.parent = parent
		var/budget = parent.cost+GA.cost
		node.cost = budget
		node.state = current_state
		node.action = GA

		if(InState(current_state, end, "add_to_plan_tree"))
			plan_tree += node
		else
			usable_actions -= GA
			var/list/subtree = BuildPossiblePlans(end, node, usable_actions, goal)
			plan_tree += subtree
		CHECK_TICK
	return plan_tree


/datum/goap_planner/proc/ShowMeTheFuture(list/state, list/remove, list/add)
	var/list/newstate = state.Copy()

	for(var/key in remove)
		newstate[key] = null
	for(var/key in add)
		newstate[key] = add[key]
	return newstate

/datum/goap_planner/proc/InState(list/testl, list/statel, calling_loc = "not_set")
	for(var/testkey in testl)
		var/test = testl[testkey]
		var/state = statel[testkey]
		if(state == null)
			state = 0
		if(test == null)
			test = 0
		if(test != state)
			return FALSE
	return TRUE


/datum/goap_plan_node
	var/datum/goap_plan_node/parent
	var/cost = 0
	var/list/state
	var/datum/goap_action/action

