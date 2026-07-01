/// Does nothing for a given duration (deciseconds, so use the SECONDS define pls), then succeeds. duration = 0 waits forever.
/datum/bt_node/ai_behavior/wait
	/// world.time when the wait ends. 0 when waiting forever
	VAR_PRIVATE/end_time = 0
	/// How long to wait, in deciseconds. 0 waits forever.
	var/duration = 0

/datum/bt_node/ai_behavior/wait/setup(datum/ai_controller/controller)
	end_time = duration > 0 ? world.time + duration : 0
	return TRUE

/datum/bt_node/ai_behavior/wait/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!end_time || world.time < end_time)
		return AI_BEHAVIOR_INSTANT
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/wait/reset_tick_state()
	end_time = 0
	..()
