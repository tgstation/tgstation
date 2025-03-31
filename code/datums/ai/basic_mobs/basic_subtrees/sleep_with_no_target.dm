/// Disables AI after a certain amount of time spent with no target, you will have to enable the AI again somewhere else
/datum/ai_planning_subtree/sleep_with_no_target
	/// Behaviour to execute when sleeping
	var/sleep_behaviour = /datum/ai_behavior/sleep_after_targetless_time
	/// Target key to interrogate
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/sleep_with_no_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	controller.queue_behavior(sleep_behaviour, BB_BASIC_MOB_CURRENT_TARGET)

/// Disables AI after a certain amount of time spent with no target, you will have to enable the AI again somewhere else
/datum/ai_behavior/sleep_after_targetless_time
	/// Turn off AI if we spend this many seconds without a target
	var/time_to_wait = 10 SECONDS

/datum/ai_behavior/sleep_after_targetless_time/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	return (controller.blackboard_key_exists(target_key)) ? ( AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED) : ( AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED)

/datum/ai_behavior/sleep_after_targetless_time/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if (!succeeded)
		controller.clear_blackboard_key(BB_TARGETLESS_TIME)
		return

	if (isnull(controller.blackboard[BB_TARGETLESS_TIME]))
		controller.set_blackboard_key(BB_TARGETLESS_TIME, world.time + time_to_wait)

	if (controller.blackboard[BB_TARGETLESS_TIME] < world.time)
		enter_sleep(controller)
		controller.clear_blackboard_key(BB_TARGETLESS_TIME)

/// Disables AI, override to do additional things or something else
/datum/ai_behavior/sleep_after_targetless_time/proc/enter_sleep(datum/ai_controller/controller)
	controller.set_ai_status(AI_STATUS_OFF)
