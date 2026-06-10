// DEPRECATED — use /datum/bt_node/subtree/run_away_from_target in BT trees instead
/datum/ai_behavior/run_away_from_target
	parent_type = /datum/bt_node/ai_behavior/run_away_from_target


// DEPRECATED — kept for non-standard callers (monkey, scatter pet) that cannot use the subtree.
// New BT trees should use /datum/bt_node/subtree/run_away_from_target instead.
/datum/bt_node/ai_behavior/run_away_from_target
	var/target_key
	var/hiding_location_key
	/// Distance to the current escape waypoint at which we consider it reached and plot the next one.
	var/required_distance = 0
	/// How far do we try to run?
	var/run_distance = DEFAULT_BASIC_FLEE_DISTANCE
	/// Clear target when fleeing finishes unsuccessfully (couldn't find escape path).
	var/clear_failed_targets = TRUE

/datum/bt_node/ai_behavior/run_away_from_target/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	run_distance = controller.blackboard[BB_BASIC_MOB_FLEE_DISTANCE] || initial(run_distance)
	if(!plot_path_away_from(controller, target))
		return FALSE
	return ..()

/datum/bt_node/ai_behavior/run_away_from_target/perform(seconds_per_tick, datum/ai_controller/controller)

	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target) || !can_see(controller.pawn, target, run_distance))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED // Out of range — return FAILURE so selector can attack

	if(get_dist(controller.pawn, controller.current_movement_target) > required_distance)
		return AI_BEHAVIOR_DELAY

	if(plot_path_away_from(controller, target))
		return AI_BEHAVIOR_DELAY // Keep fleeing
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED // Trapped, can't flee further

/datum/bt_node/ai_behavior/run_away_from_target/proc/plot_path_away_from(datum/ai_controller/controller, atom/target)
	var/turf/target_destination = get_turf(controller.pawn)
	var/static/list/offset_angles = list(45, 90, 135, 180, 225, 270)
	for(var/angle in offset_angles)
		var/turf/test_turf = get_furthest_turf(controller, angle, target)
		if(isnull(test_turf))
			continue
		var/distance_from_target = get_dist(target, test_turf)
		if(distance_from_target <= get_dist(target, target_destination))
			continue
		target_destination = test_turf
		if(distance_from_target == run_distance)
			break

	if(target_destination == get_turf(controller.pawn))
		return FALSE
	controller.set_movement_target(src, target_destination)
	return TRUE

/datum/bt_node/ai_behavior/run_away_from_target/proc/get_furthest_turf(datum/ai_controller/controller, angle, atom/target)
	var/turf/return_turf
	var/list/airlocks = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock)
	for(var/i in 1 to run_distance)
		var/turf/test_destination = get_ranged_target_turf_direct(controller.pawn, target, range = i, offset = angle)
		if(test_destination.is_blocked_turf(source_atom = controller.pawn, ignore_atoms = airlocks))
			break
		return_turf = test_destination
	return return_turf

/datum/bt_node/ai_behavior/run_away_from_target/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.set_movement_target(src, null)
	if(!succeeded && clear_failed_targets)
		controller.clear_blackboard_key(target_key)

/datum/bt_node/ai_behavior/run_away_from_target/run_and_shoot
	clear_failed_targets = FALSE

/datum/bt_node/ai_behavior/run_away_from_target/run_and_shoot/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/living_pawn = controller.pawn
	living_pawn.RangedAttack(target)
	return ..()


