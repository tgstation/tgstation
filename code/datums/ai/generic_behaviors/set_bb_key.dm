/// Sets the given blackboard key to a value.
/datum/bt_node/ai_behavior/set_bb_key

/datum/bt_node/ai_behavior/set_bb_key/perform(seconds_per_tick, datum/ai_controller/controller, target_key, value)
	controller.set_blackboard_key(target_key, value)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
