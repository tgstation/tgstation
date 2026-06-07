/// Moves away from a target if too close, or toward it if too far, to stay within the blackboard-keyed distance band.
/datum/bt_node/ai_behavior/maintain_distance

/datum/bt_node/ai_behavior/maintain_distance/setup(datum/ai_controller/controller, target_key, min_dist_key = BB_RANGED_SKIRMISH_MIN_DISTANCE, max_dist_key = BB_RANGED_SKIRMISH_MAX_DISTANCE)
	var/atom/target = controller.blackboard[target_key]
	if(!isliving(target) || !can_see(controller.pawn, target, 10))
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/maintain_distance/perform(seconds_per_tick, datum/ai_controller/controller, target_key, min_dist_key = BB_RANGED_SKIRMISH_MIN_DISTANCE, max_dist_key = BB_RANGED_SKIRMISH_MAX_DISTANCE)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_FAILED


	var/minimum_distance = controller.blackboard[min_dist_key] || 4
	var/maximum_distance = controller.blackboard[max_dist_key] || 6
	var/range = get_dist(controller.pawn, target)

	if(range >= minimum_distance && range <= maximum_distance)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	if(range < minimum_distance)
		if(!retreat(controller, target, minimum_distance))
			return AI_BEHAVIOR_FAILED
	else
		controller.change_ai_movement_type(initial(controller.ai_movement))
		controller.ai_movement.start_moving_towards(controller, target, maximum_distance)

	return AI_BEHAVIOR_INSTANT

/datum/bt_node/ai_behavior/maintain_distance/finish_action(datum/ai_controller/controller, succeeded, target_key, min_dist_key, max_dist_key)
	controller.ai_movement.stop_moving_towards(controller)
	controller.change_ai_movement_type(initial(controller.ai_movement))
	return ..()

/// Steps one tile away from target using backstep avoidance, falling back to shuffled directions if blocked.
/datum/bt_node/ai_behavior/maintain_distance/proc/retreat(datum/ai_controller/controller, atom/target, minimum_distance)
	controller.change_ai_movement_type(/datum/ai_movement/basic_avoidance/backstep)
	var/mob/pawn = controller.pawn
	pawn.face_atom(target)
	var/turf/next_step = get_step_away(pawn, target)
	if(!isnull(next_step) && !next_step.is_blocked_turf(exclude_mobs = TRUE))
		controller.ai_movement.start_moving_towards(controller, next_step, 0, controller.movement_delay * 2)
		return TRUE
	var/list/all_dirs = GLOB.alldirs.Copy()
	all_dirs -= get_dir(pawn, next_step)
	all_dirs -= get_dir(pawn, target)
	shuffle_inplace(all_dirs)
	for(var/dir in all_dirs)
		next_step = get_step(pawn, dir)
		if(!isnull(next_step) && !next_step.is_blocked_turf(exclude_mobs = TRUE))
			controller.ai_movement.start_moving_towards(controller, next_step, 0, controller.movement_delay * 2)
			return TRUE
	return FALSE

/// Retreats to the furthest available open turf within reach rather than a single step.
/datum/bt_node/ai_behavior/maintain_distance/cover_minimum_distance

/datum/bt_node/ai_behavior/maintain_distance/cover_minimum_distance/retreat(datum/ai_controller/controller, atom/target, minimum_distance)
	var/atom/movable/pawn = controller.pawn
	var/required_distance = minimum_distance - get_dist(pawn, target)
	var/best_distance = 0
	var/turf/chosen_turf
	for(var/turf/open/potential_turf in oview(required_distance, pawn))
		if(potential_turf.is_blocked_turf())
			continue
		var/new_distance = get_dist(potential_turf, target)
		if(new_distance > best_distance)
			chosen_turf = potential_turf
			best_distance = new_distance
	if(isnull(chosen_turf))
		return FALSE
	controller.ai_movement.start_moving_towards(controller, chosen_turf, 0)
	return TRUE
