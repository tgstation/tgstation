/datum/ai_behavior/pull_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/pull_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/pull_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/movable/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.anchored || target.pulledby)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/our_mob = controller.pawn
	our_mob.start_pulling(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/pull_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(target_key)
