
/datum/goap_planner
	var/list/stored_nodes = list()

/datum/goap_planner/proc/Plan(atom/agent, list/actions, list/worldstate, list/goal)
	for(var/a in actions)
		var/datum/goap_action/GA = a
		GA.Reset()
		CHECK_TICK

	var/list/usable_actions = list()

	for(var/a in actions)
		var/datum/goap_action/GA = a
		goap_debug("CHECKING ACTION [GA]")
		if(GA.cooldown)
			if(GA.OnCooldown(agent, worldstate))
				continue
		if(GA.AdvancedPreconditions(agent, worldstate))
			usable_actions += GA
			goap_debug("USABLE ACTION [GA]")
		CHECK_TICK

	//Oh god, trees! I hate this!

	var/list/plan_tree = list()

	var/datum/goap_plan_node/start = new()
	start.state = worldstate

	plan_tree = BuildPossiblePlans(start, usable_actions, goal)

	if(!plan_tree.len)
		goap_debug("NO PLAN CREATED")
		return null

	//Cheapest path
	var/datum/goap_plan_node/cheapest
	for(var/node in plan_tree)
		var/datum/goap_plan_node/N = node
		goap_debug("NODE IS [N.action] COST IS [N.cost]")
		if(!cheapest || N.cost < cheapest.cost)
			goap_debug("CURRENT CHEAPEST [N.cost]")
			cheapest = N
		CHECK_TICK

	//Go up the tree, from the cheapest bottom leaf
	var/list/plan = list()
	var/datum/goap_plan_node/climber = cheapest
	while(climber)
		if(climber.action)
			plan += climber.action
		climber = climber.parent
		CHECK_TICK
	return plan


//Builds the tree of actions
//Goes through them all.
//ALL OF THEM, we have to in order to find the cheapest path
//TODO: remove recursion it's icky and slow
/datum/goap_planner/proc/BuildPossiblePlans(datum/goap_plan_node/parent, list/usable_actions, list/goal)
	var/list/plan_tree = list()

	for(var/a in usable_actions)
		goap_debug("BPP: CHECKING USABLE ACTIONS: ACTION [a]")
		var/datum/goap_action/GA = a
		if(InState(GA.preconditions, parent.state, "usable_actions"))
			//What does the world look like if we run this action?
			pimp_my_debug(parent.state, "parent_state")
			var/list/current_state = ShowMeTheFuture(parent.state, GA.effects)
			pimp_my_debug(current_state, "current_state")
			var/datum/goap_plan_node/node = new()
			goap_debug("MY PARENT IS: [parent.action]")
			node.parent = parent
			var/fuckshit = parent.cost+GA.cost
			node.cost = fuckshit
			goap_debug("MY COST:PARENT COST IS: [node.cost]:[parent.cost]")
			node.state = current_state
			node.action = GA

			if(InState(goal, current_state, "add_to_plan_tree"))
				goap_debug("COMPLETED TREE, ADDING NODES, FINAL ACTION [GA]")
				plan_tree += node
				goap_debug("CURRENT COST: [node.cost]")
				pimp_my_debug(node.state, "node_state")
			else
				goap_debug("HASN'T COMPLETED GOAL WITH [GA] PICK NEXT ACTION")
				usable_actions -= GA
				var/list/subtree = BuildPossiblePlans(node, usable_actions, goal)
				plan_tree += subtree
		CHECK_TICK

	return plan_tree

/datum/goap_planner/proc/ShowMeTheFuture(list/state, list/effects)
	var/list/newstate = state.Copy()

	for(var/key in effects)
		newstate[key] = effects[key]
	pimp_my_debug(newstate, "show_me_the_future")
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
			goap_debug("INSTATE [testkey]:[test] != [testkey]:[state] CALL LOC: [calling_loc]")
			return FALSE
		else
			goap_debug("INSTATE [testkey]:[test] == [testkey]:[state] CALL LOC: [calling_loc]")
		CHECK_TICK
	return TRUE


/datum/goap_plan_node
	var/datum/goap_plan_node/parent
	var/cost = 0
	var/list/state
	var/datum/goap_action/action

/proc/pimp_my_debug(list/riding_spinners_they_dont_stop, state_name = "default")
	goap_debug("CHECKING DAT STATE YO [state_name]")
	for(var/spinners in riding_spinners_they_dont_stop)
		goap_debug("[spinners] = [riding_spinners_they_dont_stop[spinners]]")
		CHECK_TICK