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

		if(!isturf(movable_pawn.loc)) //No moving if not on a turf
			continue

		var/current_loc = get_turf(movable_pawn)

		var/turf/target_turf = get_step_towards(movable_pawn, controller.current_movement_target)

		if(!is_type_in_typecache(target_turf, GLOB.dangerous_turfs))
			movable_pawn.Move(target_turf, get_dir(current_loc, target_turf))

		if(current_loc == get_turf(movable_pawn)) //Did we even move after trying to move?
			controller.pathing_attempts++
			if(controller.pathing_attempts >= max_pathing_attempts)
				controller.CancelActions()
