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

/datum/goof_ai/proc/load_ai(list/actions_to_use)
	if(actions_to_use.len)
		for(var/A in actions_to_use)
			var/datum/goof_action/ACT = new A
			possible_actions += list(list(ACT = ACT.cost))
		possible_actions = sortTim(possible_actions, associative=1)

/datum/goof_ai/proc/create_plan(list/desired_world_state)
	ramblers_lets_get_rambling = null
	while(!ramblers_lets_get_rambling)
		var/datum/goof_plan/P = new
		P.wanted_world_state = desired_world_state
		P.temp_world_state = world_state
		P.unused_actions = possible_actions

		while(P.unused_actions.len)
			if(compare_world_state(P.temp_world_state, desired_world_state))
				break
			for(var/A in P.unused_actions)
				var/datum/goof_action/ACT = A
				if(is_action_possible(P.temp_world_state, ACT))
					if(does_action_satisfy_requirement(P.wanted_world_state, P.temp_world_state, ACT))
						ACT.do_action(P.temp_world_state)
						P.actions += ACT
						P.unused_actions.Remove(ACT)
						P.current_cost += ACT.cost
						break
				else // cant do it now, revisit on the next loop in case it is possible
					if(!is_action_useless(P.temp_world_state, ACT))
						P.revisit_later += list(list(ACT = ACT.cost))
						P.unused_actions.Remove(ACT)
					break
			if(!P.unused_actions.len)
				if(P.revisit_later.len)
					P.unused_actions = P.revisit_later.Copy()
					P.revisit_later.Cut()
					P.unused_actions = sortTim(P.unused_actions, associative=1) // re-sort JUST IN CASE
		if(compare_world_state(P.temp_world_state, desired_world_state))
			ramblers_lets_get_rambling = P
		else
			return FALSE // well shit that didnt work
	return ramblers_lets_get_rambling

/datum/goof_ai/proc/compare_world_state(list/check, list/correct)
	for(var/A in correct)
		if(check[A] == correct[A] && !isnull(correct[A]))
			continue
		else
			return FALSE
	return TRUE

/datum/goof_ai/proc/does_action_satisfy_requirement(list/correct, list/existing_state, datum/goof_action/A)
	for(var/WC in A.world_state_changes)
		if(!isnull(correct[WC]) && existing_state[WC] != A.world_state_changes[WC] && A.world_state_changes[WC] == correct[WC])
			return TRUE
		else
			continue
	return FALSE

/datum/goof_ai/proc/is_action_possible(list/world_state, datum/goof_action/A)
	for(var/WC in A.prereq_world_state)
		if(world_state[WC] == A.prereq_world_state[WC])
			continue
		else if(!isnull(A.prereq_world_state[WC]))
			return FALSE
	return TRUE

/datum/goof_ai/proc/is_action_useless(list/world_state, datum/goof_action/A)
	for(var/WC in A.world_state_changes)
		if(world_state[WC] == A.world_state_changes[WC])
			continue
		else if(!isnull(A.prereq_world_state[WC]))
			return FALSE
	return TRUE
