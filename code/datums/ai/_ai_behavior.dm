///Abstract class for an action an AI can take, can range from movement to grabbing a nearby weapon.
/datum/ai_behavior
	///What distance you need to be from the target to perform the action
	var/required_distance = 1
	///Can we perform the action while moving?
	var/move_while_performing = FALSE

///Called by the AI controller when this action is performed
/datum/ai_behavior/proc/perform(delta_time, datum/ai_controller/controller)
	if(perform_action(delta_time, controller))
		finish_action(controller)
	return

///Called by perform() to actually run the action. Return TRUE to finish the action off, false to keep going.
/datum/ai_behavior/proc/perform_action(delta_time, datum/ai_controller/controller)
	return

///Called when the action is finished.
/datum/ai_behavior/proc/finish_action(datum/ai_controller/controller)
	controller.current_behaviors.Remove(src)
	return
