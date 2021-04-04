///Uses Byond's basic obstacle avoidance mvovement
/datum/ai_movement/basic_avoidance
	requires_processing = FALSE

/datum/ai_movement/basic_avoidance/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	walk_to(controller.pawn, current_movement_target, min_distance, controller.movement_delay)


/datum/ai_movement/basic_avoidance/stop_moving_towards(datum/ai_controller/controller)
	. = ..()
	walk_to(controller.pawn, src)
