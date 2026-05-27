/// Passes when the mob held in a blackboard key has a stat value at that is at least X
/datum/bt_node/decorator/mob_stat_at_least
	/// Blackboard key holding the mob to check.
	var/key = null
	/// Minimum stat value (inclusive) for the condition to pass. Default: CONSCIOUS.
	var/min_stat = CONSCIOUS

/datum/bt_node/decorator/mob_stat_at_least/get_pawn_observe_signals()
	return list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key))

/datum/bt_node/decorator/mob_stat_at_least/check_condition(datum/ai_controller/controller)
	var/mob/target = controller.blackboard[key]
	if(!ismob(target))
		return FALSE
	return target.stat >= min_stat
