
//This type is the eyes/ears of a GOAPAgent
//There aren't many suitable defaults, so you must override these procs
//To get what you want

/datum/goap_info_provider
	var/list/failures_past //assoc list of "failed goal state" = "world state at the time it failed"
	//both of these are stored as "goal HASH" = failure_state object, since we're matching contents of lists, not the lists themselves
	//Used to ensure we don't try again if the world hasn't changed, mainly for performance

/datum/goap_info_provider/New()
	failures_past = list()


//Returns an associative of "statekey" = someval
//Someval should be a boolean or comparable object
//BEcause all comparisons between states are == (so no >= or > or < yet, sadly)
/datum/goap_info_provider/proc/GetWorldState(datum/goap_agent/agent)
	. = list()
	if(agent.agent)
		if(ismob(agent.agent))
			var/mob/living/carbon/M = agent.agent
			.["agent_alive"] = (M.health > 0)
	.["hasFire"] = FALSE
	.["hasWood"] = FALSE


//Same as GetWorldState() but returns an -idealised- future-world
//Eg: "my_enemy_is_dead" = TRUE
/datum/goap_info_provider/proc/GetGoal(datum/goap_agent/agent)
	. = list()
	if(agent.agent)
		if(ismob(agent.agent))
			.["agent_alive"] = TRUE //we want to still be alive in the future, disable this if you want agents to perform potentially suicidal-acts (eg: act like lunatics)


//Should we try again?
//Checks if the current goal had previously failed, and if so, if the worldstate lines up
//with the state that caused the failure
/datum/goap_info_provider/proc/ShouldTryGoalAgain(list/goal, list/worldstate)
	var/datum/goap_state/goalstate = new()
	goalstate.state = goal
	var/ghash = goalstate.Hash()

	var/datum/goap_state/failurestate = failures_past[ghash]
	if(!failurestate || !failurestate.Matches(goalstate))
		return TRUE //no state = no failure, lets try it again!
	return FALSE


//We failed, store the failed goal + failed state for future reference
//"goal_hash" = failure_state_obj
/datum/goap_info_provider/proc/PlanFailed(list/failed_goal, list/failed_worldstate)
	var/datum/goap_state/goalstate = new()
	goalstate.state = failed_goal

	var/datum/goap_state/failstate = new()
	failstate.state = failed_worldstate

	failures_past[goalstate.Hash()] = failstate


//Used for feedback
/datum/goap_info_provider/proc/PlanFound(list/goal, list/action_queue)

//Used for feedback
/datum/goap_info_provider/proc/ActionsFinished()

//Used for feedback
/datum/goap_info_provider/proc/PlanAborted(datum/goap_action/abort_causer)



//Simple struct for comparing if a goal's failure
//world state matches the current one
//if so, we know not to try it again (right now)

//In all other cases a state is just an assoc list
//This is just a helper
/datum/goap_state
	var/list/state

/datum/goap_state/proc/Matches(datum/goap_state/other)
	var/list/ostate = other.state
	for(var/statekey in ostate)
		if(state[statekey] != ostate[statekey])
			return TRUE //world is different! lets try again!
	return FALSE

/datum/goap_state/proc/Hash()
	var/list/hash = list()
	for(var/statekey in state)
		hash += (statekey + "=[state[statekey]]")
	return hash.Join(";")