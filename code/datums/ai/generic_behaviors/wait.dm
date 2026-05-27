/// Blocks the tree for a set duration then succeeds. If indefinite is TRUE, blocks forever.
/datum/bt_node/ai_behavior/wait
	action_cooldown = 0
	/// Per-controller world.time value at which the wait expires.
	var/alist/wait_end_times = alist()

/datum/bt_node/ai_behavior/wait/setup(datum/ai_controller/controller, duration, indefinite = FALSE)
	if(!indefinite)
		wait_end_times[controller] = world.time + duration SECONDS
	return TRUE

/datum/bt_node/ai_behavior/wait/perform(seconds_per_tick, datum/ai_controller/controller, duration, indefinite = FALSE)
	if(indefinite)
		return AI_BEHAVIOR_DELAY
	if(world.time >= wait_end_times[controller])
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/wait/finish_action(datum/ai_controller/controller, succeeded, duration, indefinite = FALSE)
	. = ..()
	wait_end_times -= controller
