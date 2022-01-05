///The most braindead type of movement, bee-line to the target with no concern of whats infront of us.
/datum/ai_movement/dumb
	max_pathing_attempts = 16

///Put your movement behavior in here!
/datum/ai_movement/dumb/process(delta_time)
	for(var/datum/ai_controller/controller as anything in moving_controllers)
		if(!COOLDOWN_FINISHED(controller, movement_cooldown))
			continue
		COOLDOWN_START(controller, movement_cooldown, controller.movement_delay)

		var/atom/movable/movable_pawn = controller.pawn

		// Check if this controller can actually run, so we don't chase people with corpses
		if(!controller.able_to_run())
			walk(controller.pawn, 0) //stop moving
			controller.CancelActions()
			continue

		var/can_move = TRUE

		if(controller.ai_traits & STOP_MOVING_WHEN_PULLED && movable_pawn.pulledby)
			can_move = FALSE

		if(!isturf(movable_pawn.loc)) //No moving if not on a turf
			can_move = FALSE

		var/current_loc = get_turf(movable_pawn)

		var/turf/target_turf = get_step_towards(movable_pawn, controller.current_movement_target)

		if(!is_type_in_typecache(target_turf, GLOB.dangerous_turfs) && can_move)
			movable_pawn.Move(target_turf, get_dir(current_loc, target_turf))

		if(current_loc == get_turf(movable_pawn)) //Did we even move after trying to move?
			controller.pathing_attempts++
			if(controller.pathing_attempts >= max_pathing_attempts)
				controller.CancelActions()
