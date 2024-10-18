///behavior for general interactions with any targets
/datum/ai_behavior/interact_with_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH
	///should we be clearing the target after the fact?
	var/clear_target = TRUE

/datum/ai_behavior/interact_with_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/interact_with_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target) || !pre_interact(controller, target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.ai_interact(target)
	return AI_BEHAVIOR_SUCCEEDED | AI_BEHAVIOR_DELAY

/datum/ai_behavior/interact_with_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(clear_target || !succeeded)
		controller.clear_blackboard_key(target_key)

/datum/ai_behavior/interact_with_target/proc/pre_interact(datum/ai_controller/controller, target)
	return TRUE
