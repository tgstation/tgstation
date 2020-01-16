
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

	plan_tree = BuildPossiblePlans(end, start, usable_actions)

	if(!length(plan_tree))
		to_chat(world, "plan_tree was null! REEE")
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

/*
	Returns a list of plan nodes that are the END of a possible plan
	These nodes have the cost of the entire plan (allowing you to choose, eg: the cheapest plan)
	to construct a plan from the chosen node, simply follow the node parent
	chain until you hit a node with no parent:

	var/list/plan = list()
	var/datum/goap_plan_node/climber = chosen_node
	while(climber)
		if(climber.action)
			plan += climber.action
		climber = climber.parent
	... then reverse the plan list to get it in START->END order ...
*/
/datum/goap_planner/proc/BuildPossiblePlans(list/end, datum/goap_plan_node/parent0, list/usable_actions0)
	var/list/plan_end_nodes  = list()                 //List of nodes that end a plan (thus, can be used to form plans in reverse)

	//Stacks
	var/list/parent_stack    = list(parent0)          //Parent node stack (List of nodes)
	var/list/actions_stack   = list(usable_actions0)  //Actions stack (List of lists of actions)

	var/depth = 1
	var/nodefound = FALSE
	while(depth>0)
		var/list/usable_actions = PEEKLIST(actions_stack)
		nodefound = FALSE
		for(var/a in usable_actions)
			var/datum/goap_action/GA = a
			var/datum/goap_plan_node/parent = PEEKLIST(parent_stack)
			if(!InState(GA.effects, parent.state, "usable_actions")) // this won't get us to the goal
				to_chat(world, "DEBUG: [GA.name] was rejected!")
				continue

			//What does the world look like if we run this action?
			var/list/current_state = ShowMeTheFuture(parent.state, GA.effects, GA.preconditions) // remove the effects and add the preconditions
			var/datum/goap_plan_node/node = new()
			node.parent = parent
			var/budget = parent.cost+GA.cost
			node.cost = budget
			node.state = current_state
			node.action = GA

			//This node reaches the goal, add it, but keep going to find more plans
			if(InState(current_state, end, "add_to_plan_tree"))
				plan_end_nodes += node
				to_chat(world, "DEBUG: planning finished, final node is: [node.action.name]")
			else
				usable_actions -= GA //NOTE 2
				parent_stack += node
				actions_stack += usable_actions.Copy() //NOTE 1
				depth++
				to_chat(world, "DEBUG: tree depth is [depth], last node added was [node.action.name]")
				nodefound = TRUE
			CHECK_TICK
		if(!nodefound)
			pop(parent_stack)
			pop(actions_stack)
			depth--
			to_chat(world, "DEBUG: popped both stacks, depth is now [depth]")
	return plan_end_nodes


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

