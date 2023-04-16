/// Come to a complete stop for a set amount of time.
/datum/ai_movement/complete_stop
	max_pathing_attempts = 1 // no need for anything fancy

/datum/ai_movement/complete_stop/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/stopping_time = controller.blackboard[BB_STATIONARY_SECONDS]
	// assume that the current_movement_target is our location
	var/datum/move_loop/loop = SSmove_manager.freeze(moving, current_movement_target, delay, timeout = stopping_time, subsystem = SSai_movement, extra_info = controller)
	
