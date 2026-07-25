/// Finds the open turf furthest from the keyed target and stores it, used to pick an escape destination.
/// Returns INSTANT SUCCESS if a turf is found, INSTANT FAILURE if none are available.
/datum/bt_node/ai_behavior/find_furthest_turf_from_target
	/// Blackboard key holding the atom to flee from.
	var/target_key
	/// Blackboard key to store the chosen turf in.
	var/set_key
	/// How many tiles outward from the target to scan.
	var/range = 2

/datum/bt_node/ai_behavior/find_furthest_turf_from_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/best_distance = 0
	var/turf/chosen_turf
	for(var/turf/open/potential_destination in oview(range, living_target))
		if(potential_destination.is_blocked_turf())
			continue
		var/new_distance = get_dist(potential_destination, living_target)
		if(new_distance > best_distance)
			chosen_turf = potential_destination
			best_distance = new_distance
		if(best_distance == range)
			break // already at the furthest possible distance

	if(isnull(chosen_turf))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(set_key, chosen_turf)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
