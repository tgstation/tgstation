/datum/ai_behavior/start_fleeing

/datum/ai_behavior/start_fleeing/setup(datum/ai_controller/controller, fleeing_key)
	if (controller.blackboard[fleeing_key])
		return FALSE
	return ..()

/datum/ai_behavior/start_fleeing/perform(delta_time, datum/ai_controller/controller, fleeing_key)
	. = ..()
	controller.blackboard[fleeing_key] = TRUE
	finish_action(controller, succeeded = TRUE)

/datum/ai_behavior/stop_fleeing

/datum/ai_behavior/stop_fleeing/setup(datum/ai_controller/controller, fleeing_key)
	if (!controller.blackboard[fleeing_key])
		return FALSE
	return ..()

/datum/ai_behavior/stop_fleeing/perform(delta_time, datum/ai_controller/controller, fleeing_key)
	. = ..()
	controller.blackboard[fleeing_key] = FALSE
	finish_action(controller, succeeded = TRUE)
