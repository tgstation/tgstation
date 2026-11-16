/// How close you need to get to the destination in order to consider yourself there
#define CARP_DESTINATION_SEARCH_RANGE 3

/**
 * # Find next carp migration step
 * Records the next turf we want to travel to into the blackboard for other actions
 */
/datum/bt_node/ai_behavior/find_next_carp_migration_step
	/// Blackboard key holding the list of turfs to migrate between
	var/path_key = BB_CARP_MIGRATION_PATH
	/// Blackboard key in which we record our next destination
	var/target_key = BB_CARP_MIGRATION_TARGET

/datum/bt_node/ai_behavior/find_next_carp_migration_step/perform(seconds_per_tick, datum/ai_controller/controller)
	var/list/blackboard_points = controller.blackboard[path_key]
	for(var/turf/migration_point as anything in blackboard_points)
		// By the end of this loop we will either have a valid migration point set, or an empty list in our blackboard
		blackboard_points -= migration_point
		if(get_dist(controller.pawn, migration_point) > CARP_DESTINATION_SEARCH_RANGE)
			controller.set_blackboard_key(target_key, migration_point)
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/**
 * # Clear arrived migration target
 * Clears our migration target once we've gotten close enough to it, so a new one can be selected.
 */
/datum/bt_node/ai_behavior/clear_arrived_migration_target
	/// Blackboard key holding our migration destination
	var/target_key = BB_CARP_MIGRATION_TARGET

/datum/bt_node/ai_behavior/clear_arrived_migration_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/turf/moving_to = controller.blackboard[target_key]
	if(QDELETED(moving_to) || get_dist(controller.pawn, moving_to) <= CARP_DESTINATION_SEARCH_RANGE)
		controller.clear_blackboard_key(target_key)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Returns TRUE if the next step towards the keyed turf is blocked, so we can smash or teleport through it.
/datum/bt_node/decorator/carp_path_blocked
	/// Blackboard key holding the turf we're trying to reach
	var/target_key = BB_CARP_MIGRATION_TARGET

/datum/bt_node/decorator/carp_path_blocked/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	var/turf/next_step = get_step_towards(controller.pawn, target)
	return next_step?.is_blocked_turf(exclude_mobs = TRUE)

#undef CARP_DESTINATION_SEARCH_RANGE
