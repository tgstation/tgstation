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
	/// Turn off AI if we spend this many seconds without a target, don't use the macro because seconds_per_tick is already in seconds
	var/time_to_wait = 10

/datum/ai_behavior/sleep_after_targetless_time/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/datum/ai_behavior/sleep_after_targetless_time/finish_action(datum/ai_controller/controller, succeeded, seconds_per_tick)
	. = ..()
	if (!succeeded)
		controller.set_blackboard_key(BB_TARGETLESS_TIME, 0)
		return
	controller.add_blackboard_key(BB_TARGETLESS_TIME, seconds_per_tick)
	if (controller.blackboard[BB_TARGETLESS_TIME] > time_to_wait)
		enter_sleep(controller)

/// Disables AI, override to do additional things or something else
/datum/ai_behavior/sleep_after_targetless_time/proc/enter_sleep(datum/ai_controller/controller)
	controller.set_ai_status(AI_STATUS_OFF)
