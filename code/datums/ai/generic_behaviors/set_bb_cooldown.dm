/// Sets the given blackboard key to a future timestamp, blocking key_off_cooldown until that time.
/datum/bt_node/ai_behavior/set_bb_cooldown
	/// Blackboard key to write the cooldown timestamp into.
	var/cooldown_key
	/// Cooldown duration, in seconds.
	var/cooldown_duration

/datum/bt_node/ai_behavior/set_bb_cooldown/perform(seconds_per_tick, datum/ai_controller/controller)
	controller.set_blackboard_key(cooldown_key, world.time + cooldown_duration)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
