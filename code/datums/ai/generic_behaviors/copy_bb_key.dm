/// Copies the value of source_key to dest_key.
/datum/bt_node/ai_behavior/copy_bb_key
	var/dest_key
	var/source_key

/datum/bt_node/ai_behavior/copy_bb_key/perform(seconds_per_tick, datum/ai_controller/controller)
	controller.set_blackboard_key(dest_key, controller.blackboard[source_key])
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
