
/datum/goap_action
	var/name = "generic goap action" //for bookkeeping/debug

	var/list/preconditions //Our requirements from the World State
	var/list/effects //Our effects on the World State

	var/cost = 1 //Cost of using this action

	var/inn_range = FALSE //Actions usually require you to be close to some target/goal object
	var/atom/target //Actions usually act on some kind of target/goal object


//Reset any state variables between uses
//Just because you chopped down a tree 500 ticks ago doesn't
//Mean you're still in_range now!
/datum/goap_action/proc/Reset()
	inn_range = FALSE
	target = null


//Designed to be overriden to have more advanced preconditions
//If you use a target, set it in this
//If unused, return TRUE anyway
/datum/goap_action/proc/AdvancedPreconditions(atom/agent, list/worldstate)
	return TRUE


//If we need to be in range of a target object
//If this is true, we tell the agent to move
//Otherwise we just proceed with the action
//Overridable incase of advanced "Ok range is required if X is true but not if Y is true" situations
/datum/goap_action/proc/RequiresInRange(atom/agent)
	return FALSE

/datum/goap_action/proc/IsInRange(atom/agent)
	if(RequiresInRange(agent))
		return inn_range
	else
		return TRUE


//The action's actual code-driven results
//eg:
// 1 playing a sound of wood chopping
// 2 an animation of a tree falling over
// 3 spawning some wood
// Returns:
// TRUE for success, removing it from the action queue
// FALSE for failure, removing the GOAL from the agent, as he current plan has failed
/datum/goap_action/proc/Perform(atom/agent)
	return FALSE

//Are we done? (and thus, ready to be removed from the action queue)
/datum/goap_action/proc/CheckDone(atom/agent)
	return FALSE