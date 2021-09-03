/**
 * This movement datum represents smart-pathing
 */
/datum/ai_movement/jps
	max_pathing_attempts = 4

///Put your movement behavior in here!
/datum/ai_movement/jps/process(delta_time)
	for(var/datum/ai_controller/controller as anything in moving_controllers)
		if(!COOLDOWN_FINISHED(controller, movement_cooldown))
			continue
		COOLDOWN_START(controller, movement_cooldown, controller.movement_delay)

		var/atom/movable/movable_pawn = controller.pawn
		if(!isturf(movable_pawn.loc)) //No moving if not on a turf
			continue

		if(controller.ai_traits & STOP_MOVING_WHEN_PULLED && movable_pawn.pulledby)
			continue

		var/minimum_distance = controller.max_target_distance
		// right now I'm just taking the shortest minimum distance of our current behaviors, at some point in the future
		// we should let whatever sets the current_movement_target also set the min distance and max path length
		// (or at least cache it on the controller)
		if(LAZYLEN(controller.current_behaviors))
			for(var/datum/ai_behavior/iter_behavior as anything in controller.current_behaviors)
				if(iter_behavior.required_distance < minimum_distance)
					minimum_distance = iter_behavior.required_distance

		if(get_dist(movable_pawn, controller.current_movement_target) <= minimum_distance)
			continue

		var/generate_path = FALSE // set to TRUE when we either have no path, or we failed a step
		if(length(controller.movement_path))
			var/turf/next_step = controller.movement_path[1]
			movable_pawn.Move(next_step)

			// this check if we're on exactly the next tile may be overly brittle for dense pawns who may get bumped slightly
			// to the side while moving but could maybe still follow their path without needing a whole new path
			if(get_turf(movable_pawn) == next_step)
				controller.movement_path.Cut(1,2)
			else
				generate_path = TRUE
		else
			generate_path = TRUE

		if(generate_path)
			if(!COOLDOWN_FINISHED(controller, repath_cooldown))
				continue
			controller.pathing_attempts++
			if(controller.pathing_attempts >= max_pathing_attempts)
				controller.CancelActions()
				continue

			COOLDOWN_START(controller, repath_cooldown, 2 SECONDS)
			controller.movement_path = get_path_to(movable_pawn, controller.current_movement_target, AI_MAX_PATH_LENGTH, minimum_distance, id=controller.get_access())

/datum/ai_movement/jps/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target)
	controller.movement_path = null
	return ..()

/datum/ai_movement/jps/stop_moving_towards(datum/ai_controller/controller)
	controller.movement_path = null
	return ..()
