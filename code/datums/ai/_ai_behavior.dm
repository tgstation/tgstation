///Abstract class for an action an AI can take, can range from movement to grabbing a nearby weapon.
/datum/ai_behavior
	///Whether or not to add this action to the processing list
	var/requires_processing = FALSE
	///What distance you need to be from the target to perform the action
	var/required_distance = 1
	///Can we perform the action while moving?
	var/move_while_performing = TRUE

/datum/ai_behavior/New(controller)
	. = ..()
	our_controller = controller

///Called every 1 seconds
/datum/ai_behavior/proc/perform(delta_time, controller)
	return

///Is checked by the controller to see if this action is done.area
/datum/ai_behavior/proc/is_finished()
	return FALSE
