/// Disables AI after a certain amount of time spent with no target, you will have to enable the AI again somewhere else
/datum/ai_planning_subtree/sleep_with_no_target
	/// Behaviour to execute when sleeping
	var/sleep_behaviour = /datum/ai_behavior/sleep_after_targetless_time
	/// Target key to interrogate
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/sleep_with_no_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	controller.queue_behavior(sleep_behaviour, BB_BASIC_MOB_CURRENT_TARGET)

/// Disables AI after a certain amount of time spent with no target, you will have to enable the AI again somewhere else
/datum/ai_behavior/sleep_after_targetless_time
	/// Turn off AI if we spend this many seconds without a target, don't use the macro because delta_time is already in seconds
	var/time_to_wait = 10

/datum/ai_behavior/sleep_after_targetless_time/perform(delta_time, datum/ai_controller/controller, target_key)
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	finish_action(controller, succeeded = !target, delta_time = delta_time)

/datum/ai_behavior/sleep_after_targetless_time/finish_action(datum/ai_controller/controller, succeeded, delta_time)
	. = ..()
	if (!succeeded)
		controller.blackboard[BB_TARGETLESS_TIME] = 0
		return
	controller.blackboard[BB_TARGETLESS_TIME] += delta_time
	if (controller.blackboard[BB_TARGETLESS_TIME] > time_to_wait)
		enter_sleep(controller)

/// Disables AI, override to do additional things or something else
/datum/ai_behavior/sleep_after_targetless_time/proc/enter_sleep(datum/ai_controller/controller)
	controller.set_ai_status(AI_STATUS_OFF)
