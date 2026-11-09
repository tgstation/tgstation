/// Clears a do-once being locked
/datum/bt_node/ai_behavior/unlock_do_once
	/// Blackboard key configured on the corresponding do_once decorator.
	var/lock_key

/datum/bt_node/ai_behavior/unlock_do_once/perform(seconds_per_tick, datum/ai_controller/controller)
	UNLOCK_DO_ONCE(controller, lock_key)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
