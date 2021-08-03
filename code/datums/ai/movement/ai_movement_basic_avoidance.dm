///Uses Byond's basic obstacle avoidance mvovement
/datum/ai_movement/basic_avoidance
	requires_processing = FALSE

/datum/ai_movement/basic_avoidance/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()

	controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE] = min_distance

	var/atom/movable/movable_pawn = controller.pawn
	RegisterSignal(controller.pawn, COMSIG_LIVING_GET_PULLED, .proc/pause_moving)
	RegisterSignal(controller.pawn, COMSIG_ATOM_NO_LONGER_PULLED, .proc/resume_moving)



	if(controller.ai_traits & STOP_MOVING_WHEN_PULLED && movable_pawn.pulledby)
		return
	walk_to(controller.pawn, current_movement_target, min_distance, controller.movement_delay)

/datum/ai_movement/basic_avoidance/stop_moving_towards(datum/ai_controller/controller)
	. = ..()
	walk_to(controller.pawn, 0)
	UnregisterSignal(controller.pawn, COMSIG_LIVING_GET_PULLED)
	RegisterSignal(controller.pawn, COMSIG_ATOM_NO_LONGER_PULLED)


/datum/ai_movement/basic_avoidance/proc/pause_moving(datum/source, mob/living/puller)
	SIGNAL_HANDLER

	var/atom/movable/movable_pawn = source
	walk_to(movable_pawn, 0)



/datum/ai_movement/basic_avoidance/proc/resume_moving(datum/source, atom/movable/last_puller)
	SIGNAL_HANDLER

	var/atom/movable/movable_pawn = source
	var/datum/ai_controller/controller = movable_pawn.ai_controller

	walk_to(movable_pawn, controller.current_movement_target, controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE], controller.movement_delay)
