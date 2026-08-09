/// Sets the given blackboard key to a value.
/datum/bt_node/ai_behavior/set_bb_key
	/// Blackboard key to set.
	var/target_key
	/// Value to store in the key.
	var/value

/datum/bt_node/ai_behavior/set_bb_key/perform(seconds_per_tick, datum/ai_controller/controller)
	controller.set_blackboard_key(target_key, value)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
