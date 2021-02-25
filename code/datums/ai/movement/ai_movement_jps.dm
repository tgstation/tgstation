/**
 * This movement datum represents smart-pathing
 *
 *
 */
/datum/ai_movement/jps
	var/repath_delay

///Put your movement behavior in here!
/datum/ai_movement/jps/process(delta_time)
	for(var/datum/ai_controller/controller as anything in moving_controllers)
		if(!COOLDOWN_FINISHED(controller, movement_cooldown))
			continue
		COOLDOWN_START(controller, movement_cooldown, controller.movement_delay)

		var/atom/movable/movable_pawn = controller.pawn

		if(!isturf(movable_pawn.loc)) //No moving if not on a turf
			continue

		if(controller.movement_path && length(controller.movement_path) >= 1)
			var/turf/next_step = controller.movement_path[1]
			movable_pawn.Move(next_step)

			if(get_turf(movable_pawn) != next_step)
				controller.pathing_attempts++
				if(controller.pathing_attempts >= MAX_PATHING_ATTEMPTS)
					controller.CancelActions()
					continue
			else
				if(length(controller.movement_path) == 1)
					controller.movement_path = null
				else
					controller.movement_path.Cut(1,2)
		else
			if(!COOLDOWN_FINISHED(controller, repath_cooldown))
				continue
			COOLDOWN_START(controller, repath_cooldown, 2 SECONDS)
			var/minimum_distance = controller.max_target_distance // arbitrarily high
			for(var/datum/ai_behavior/iter_behavior as anything in controller.current_behaviors)
				if(iter_behavior.required_distance < minimum_distance)
					minimum_distance = iter_behavior.required_distance
			controller.movement_path = get_path_to(movable_pawn, controller.current_movement_target, 50, minimum_distance, id=controller.get_access())

/datum/ai_movement/jps/stop_moving_towards(datum/ai_controller/controller)
	controller.movement_path = null
	. = ..()
