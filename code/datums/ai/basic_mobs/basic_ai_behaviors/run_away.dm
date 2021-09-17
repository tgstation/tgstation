///basically just goes to a set point with a message, the action will be autocancelled by movement AI if it cannot reach the destination.
/datum/ai_behavior/run_away
	action_cooldown = 0.4 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/run_away/setup(datum/ai_controller/controller, target_key, alarmed_message)
	. = ..()
	controller.pawn.visible_message(span_warning("[controller.pawn] [alarmed_message]"))

/datum/ai_behavior/run_away/perform(delta_time, datum/ai_controller/controller, target_key, alarmed_message)
	var/atom/target = controller.blackboard[target_key]
	if(!target) //?!
		finish_action(controller, TRUE)
	if(get_dist(controller.pawn, target) >= 15)
		finish_action(controller, TRUE)
	else
		controller.current_movement_target = get_step_away(controller.pawn, target)

/datum/ai_behavior/run_away/finish_action(datum/ai_controller/controller, succeeded, target_key, alarmed_message)
	. = ..()
	controller.blackboard[target_key] = null
