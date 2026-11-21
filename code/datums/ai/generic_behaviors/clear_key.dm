/// BT-native version: clears a single blackboard key. Returns INSTANT SUCCESS.
/datum/bt_node/ai_behavior/clear_key
	/// Blackboard key to clear.
	var/key

/datum/bt_node/ai_behavior/clear_key/perform(seconds_per_tick, datum/ai_controller/controller)
	controller.clear_blackboard_key(key)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
