/// Come to a complete stop for a set amount of time.
/datum/ai_movement/complete_stop
	max_pathing_attempts = INFINITY // path all you want, you can not escape your fate

/datum/ai_movement/complete_stop/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/stopping_time = controller.blackboard[BB_STATIONARY_SECONDS]
	var/delay_time = (stopping_time * 0.5) // no real reason to fire any more often than this really
	// assume that the current_movement_target is our location
	var/datum/move_loop/loop = GLOB.move_manager.freeze(moving, current_movement_target, delay = delay_time, timeout = stopping_time, subsystem = SSai_movement, extra_info = controller)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))

/datum/ai_movement/complete_stop/allowed_to_move(datum/move_loop/source)
	return FALSE
