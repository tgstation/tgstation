/// Picks a random available ability from a pool of blackboard keys, excluding the last-used one.
/// Writes the selected action object to result_key for a targeted_mob_ability leaf to fire.
/// Returns INSTANT FAILURE if no ability in the pool is currently available.
/datum/bt_node/ai_behavior/pick_random_ability
	/// List of blackboard key name strings to pick from.
	var/list/ability_keys = null
	/// Blackboard key storing the last-picked key name string (anti-repeat). Can be null.
	var/last_used_key = null
	/// Blackboard key to write the selected action object into.
	var/result_key = BB_GENERIC_ACTION

/datum/bt_node/ai_behavior/pick_random_ability/perform(seconds_per_tick, datum/ai_controller/controller)
	var/list/possible = ability_keys.Copy()
	var/last_used = last_used_key ? controller.blackboard[last_used_key] : null
	if(last_used)
		possible -= last_used
	for(var/bb_key in possible)
		var/datum/action/ability = controller.blackboard[bb_key]
		if(QDELETED(ability) || !ability.IsAvailable())
			possible -= bb_key
	if(!length(possible))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/picked_key = pick(possible)
	if(last_used_key)
		controller.set_blackboard_key(last_used_key, picked_key)
	controller.set_blackboard_key(result_key, controller.blackboard[picked_key])
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
