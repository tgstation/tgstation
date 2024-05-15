/datum/ai_behavior/set_travel_destination

/datum/ai_behavior/set_travel_destination/perform(seconds_per_tick, datum/ai_controller/controller, target_key, location_key)
	var/atom/target = controller.blackboard[target_key]

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(location_key, target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
