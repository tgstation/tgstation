/// Finds a random open turf near the keyed target that the target can see, used to pick an ambush teleport destination.
/// Returns SUCCESS if a turf is found, FAILURE if none are available.
/datum/bt_node/ai_behavior/find_valid_teleport_location
	/// Blackboard key holding the atom to teleport next to.
	var/target_key = BB_CURRENT_TARGET
	/// Blackboard key to store the chosen turf in.
	var/set_key
	/// How many tiles outward from the target to scan.
	var/range = 3

/datum/bt_node/ai_behavior/find_valid_teleport_location/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/possible_turfs = list()
	for(var/turf/open/potential_turf in oview(range, target))
		if(potential_turf.is_blocked_turf())
			continue
		if(!can_see(target, potential_turf, range))
			continue
		possible_turfs += potential_turf

	if(!length(possible_turfs))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(set_key, pick(possible_turfs))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
