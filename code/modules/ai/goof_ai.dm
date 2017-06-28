/datum/goof_action
	var/cost = 1
	var/name = "Drive the Saracens from the Holy Land"
	var/datum/goof_plan/my_plan
	var/list/world_state_changes = list()
	var/list/prereq_world_state = list()

/datum/goof_action/proc/do_action(list/world_state_to_work_with)
	for(var/A in world_state_changes)
		world_state_to_work_with[A] = world_state_changes[A]

/datum/goof_plan
	var/current_cost = 0
	var/list/actions = list()
	var/list/wanted_world_state = list()
	var/list/temp_world_state = list()
	var/list/unused_actions = list()
	var/list/revisit_later = list()
	var/datum/goof_ai/my_ai

/datum/goof_ai
	var/list/world_state = list()
	var/list/possible_actions = list()
	var/list/potential_plans = list()
	var/ramblers_lets_get_rambling = null
	var/executing_plan = FALSE

/datum/goof_ai/proc/load_ai(list/actions_to_use)
	if(actions_to_use.len)
		for(var/A in actions_to_use)
			var/datum/goof_action/ACT = new A
			possible_actions += list(list(ACT.type = ACT.cost))

/datum/goof_ai/proc/create_plan(list/desired_world_state)
	ramblers_lets_get_rambling = null
	var/max_revisits = 3
	var/revisits = 0
	while(!ramblers_lets_get_rambling)
		var/datum/goof_plan/P = new
		P.wanted_world_state = desired_world_state
		P.temp_world_state = world_state
		P.unused_actions = possible_actions.Copy()
		P.actions.Cut()
		P.revisit_later.Cut()

		while(P.unused_actions.len)
			if(compare_world_state(P.temp_world_state, desired_world_state))
				break
			for(var/i in 1 to P.unused_actions.len)
				var/temp = P.unused_actions[i][1]
				world.log << temp
				world.log << i
				var/datum/goof_action/ACT = new temp
				world.log << "CHECKING: [ACT.name]"
				if(is_action_possible(P.temp_world_state, ACT))
					world.log << "ACTION POSSIBLE: [ACT.name]"
					if(does_action_satisfy_requirement(P.wanted_world_state, P.temp_world_state, ACT))
						world.log << "SATISFIES REQUIREMENT: [ACT.name]"
						ACT.do_action(P.temp_world_state)
						P.actions += ACT
						P.unused_actions.Remove(ACT)
						P.current_cost += ACT.cost
						break
				else // cant do it now, revisit on the next loop in case it is possible
					if(!is_action_useless(P.temp_world_state, ACT))
						world.log << "UNUSABLE BUT USEFUL SAVING FOR LATER: [ACT.name]"
						P.revisit_later += list(list(ACT.type = ACT.cost))
						P.unused_actions.Remove(ACT)
					continue
			if(!P.unused_actions.len)
				if(revisits >= max_revisits)
					world.log << "MAX REVISITS, CALLING IT QUITS"
					break
				if(P.revisit_later.len)
					P.unused_actions = P.revisit_later.Copy()
					P.revisit_later.Cut()
					world.log << "LOADING REVISIT ACTIONS"
					max_revisits++
		if(compare_world_state(P.temp_world_state, desired_world_state))
			ramblers_lets_get_rambling = P
			world.log << "PLAN FOUND"
			return ramblers_lets_get_rambling
		else
			return FALSE // well shit that didnt work
	return ramblers_lets_get_rambling

/datum/goof_ai/proc/compare_world_state(list/check, list/correct)
	for(var/A in correct)
		if(check[A] == correct[A] && !isnull(correct[A]))
			continue
		else
			world.log << "compare_world_state: FALSE: [A]"
			return FALSE
	world.log << "compare_world_state: TRUE"
	return TRUE

/datum/goof_ai/proc/does_action_satisfy_requirement(list/correct, list/existing_state, datum/goof_action/A)
	for(var/WC in A.world_state_changes)
		if(!isnull(correct[WC]) && existing_state[WC] != A.world_state_changes[WC] && A.world_state_changes[WC] == correct[WC])
			world.log << "does_action_satisfy_requirement: TRUE [WC]"
			return TRUE
		else
			continue
	world.log << "does_action_satisfy_requirement: FALSE"
	return FALSE

/datum/goof_ai/proc/is_action_possible(list/world_state, datum/goof_action/A)
	for(var/WC in A.prereq_world_state)
		if(world_state[WC] == A.prereq_world_state[WC])
			continue
		else
			world.log << "is_action_possible: FALSE [WC]"
			return FALSE
	world.log << "is_action_possible: TRUE"
	return TRUE

/datum/goof_ai/proc/is_action_useless(list/world_state, datum/goof_action/A)
	var/useless_change = TRUE
	for(var/WC in A.world_state_changes)
		world.log << "is_action_useless: [WC]"
		world.log << world_state[WC]
		world.log << "VS"
		world.log << A.world_state_changes[WC]
		if(world_state[WC] == A.world_state_changes[WC])
			useless_change = FALSE
			world.log << "is_action_useless: FALSE [WC]"
	world.log << "is_action_useless: [useless_change]"
	return useless_change
