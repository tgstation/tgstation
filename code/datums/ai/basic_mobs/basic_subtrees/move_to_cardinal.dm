/// Moves to line up with the target along a cardinal direction, so a directional ability can fire down the lane.
/// Reports SUCCESS once lined up and within range, FAILURE when the target is gone, too far, or pathing gives up.
/datum/bt_node/ai_behavior/move_to_cardinal
	time_between_perform = 0
	/// Blackboard key holding the atom to line up with.
	var/target_key = BB_CURRENT_TARGET
	/// How close to our target is too close.
	var/minimum_distance = 1
	/// How far away is too far.
	var/maximum_distance = 9
	/// The cardinal tile of our target we are currently moving toward.
	var/atom/destination
	/// Set by on_movement_failed() when the movement system gives up pathing.
	var/movement_failed = FALSE

/datum/bt_node/ai_behavior/move_to_cardinal/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	RegisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED, PROC_REF(on_movement_failed))
	move_towards_nearest_cardinal(controller, target)
	return TRUE

/datum/bt_node/ai_behavior/move_to_cardinal/proc/on_movement_failed(atom/source)
	SIGNAL_HANDLER
	movement_failed = TRUE

/// Begin moving toward the closest unblocked cardinal tile of our target.
/datum/bt_node/ai_behavior/move_to_cardinal/proc/move_towards_nearest_cardinal(datum/ai_controller/controller, atom/target)
	var/atom/move_target
	var/closest = INFINITY
	for(var/dir in GLOB.cardinals)
		var/turf/cardinal_turf = get_ranged_target_turf(target, dir, minimum_distance)
		if(cardinal_turf.is_blocked_turf())
			continue
		var/distance_to = get_dist(controller.pawn, cardinal_turf)
		if(distance_to >= closest)
			continue
		closest = distance_to
		move_target = cardinal_turf
	if(isnull(move_target))
		move_target = target
	controller.ai_movement.start_moving_towards(controller, move_target, 0)
	destination = move_target

/datum/bt_node/ai_behavior/move_to_cardinal/perform(seconds_per_tick, datum/ai_controller/controller)
	if(movement_failed)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/distance_to_target = get_dist(controller.pawn, target)
	if(distance_to_target > maximum_distance)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(!(get_dir(controller.pawn, target) in GLOB.cardinals) || distance_to_target < minimum_distance)
		move_towards_nearest_cardinal(controller, target)
		return AI_BEHAVIOR_INSTANT
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/move_to_cardinal/finish_action(datum/ai_controller/controller, succeeded)
	UnregisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED)
	movement_failed = FALSE
	controller.ai_movement.stop_moving_towards(controller)
	return ..()
