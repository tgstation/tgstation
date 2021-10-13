///This datum is an abstract class that can be overriden for different types of movement
/datum/ai_movement
	///Assoc list ist of controllers that are currently moving as key, and what they are moving to as value
	var/list/moving_controllers = list()
	///Does this type require processing?
	var/requires_processing = TRUE
	///How many times a given controller can fail on their route before they just give up
	var/max_pathing_attempts

/datum/ai_movement/proc/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	controller.pathing_attempts = 0
	controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE] = min_distance
	if(!moving_controllers.len && requires_processing)
		START_PROCESSING(SSai_movement, src)
	moving_controllers[controller] = current_movement_target

/datum/ai_movement/proc/stop_moving_towards(datum/ai_controller/controller)
	controller.pathing_attempts = 0
	moving_controllers -= controller

	if(!moving_controllers.len && requires_processing)
		STOP_PROCESSING(SSai_movement, src)

