/// Sets the given blackboard key to a future timestamp, blocking key_off_cooldown until that time.
/datum/bt_node/ai_behavior/set_bb_cooldown

/datum/bt_node/ai_behavior/set_bb_cooldown/perform(seconds_per_tick, datum/ai_controller/controller, cooldown_key, cooldown_duration)
	controller.set_blackboard_key(cooldown_key, world.time + cooldown_duration * SECONDS)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
