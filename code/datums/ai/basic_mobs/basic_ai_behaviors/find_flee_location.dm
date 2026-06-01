/// Computes the best flee destination turf away from a target and stores it in a blackboard key.
/// Returns INSTANT SUCCESS if a path away was found, INSTANT FAILURE otherwise (trapped or target out of range).
/datum/bt_node/ai_behavior/find_flee_location
	action_cooldown = 0

/datum/bt_node/ai_behavior/find_flee_location/perform(seconds_per_tick, datum/ai_controller/controller, target_key, hiding_location_key, destination_key)
	var/run_distance = controller.blackboard[BB_BASIC_MOB_FLEE_DISTANCE] || DEFAULT_BASIC_FLEE_DISTANCE
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target) || !can_see(controller.pawn, target, run_distance))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/turf/flee_turf = get_best_flee_turf(controller, target, run_distance)
	if(!flee_turf)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(destination_key, flee_turf)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/find_flee_location/proc/get_best_flee_turf(datum/ai_controller/controller, atom/target, run_distance)
	var/turf/best = get_turf(controller.pawn)
	var/static/list/offset_angles = list(45, 90, 135, 180, 225, 270)
	for(var/angle in offset_angles)
		var/turf/candidate = get_furthest_clear_turf(controller, angle, target, run_distance)
		if(isnull(candidate))
			continue
		var/dist = get_dist(target, candidate)
		if(dist <= get_dist(target, best))
			continue
		best = candidate
		if(dist == run_distance)
			break
	if(best == get_turf(controller.pawn))
		return null
	return best

/datum/bt_node/ai_behavior/find_flee_location/proc/get_furthest_clear_turf(datum/ai_controller/controller, angle, atom/target, run_distance)
	var/turf/result
	var/list/airlocks = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock)
	for(var/i in 1 to run_distance)
		var/turf/test = get_ranged_target_turf_direct(controller.pawn, target, range = i, offset = angle)
		if(test.is_blocked_turf(source_atom = controller.pawn, ignore_atoms = airlocks))
			break
		result = test
	return result
