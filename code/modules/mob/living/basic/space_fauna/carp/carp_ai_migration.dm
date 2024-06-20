/// How close you need to get to the destination in order to consider yourself there
#define CARP_DESTINATION_SEARCH_RANGE 3
/// If there's a portal this close to us we'll enter it just on the basis that the carp who made it probably knew where they were going
#define CARP_PORTAL_SEARCH_RANGE 2

/**
 * # Carp Migration
 * Will try to plan a path between a list of locations for carp to travel through
 */
/datum/ai_planning_subtree/carp_migration

/datum/ai_planning_subtree/carp_migration/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	// If there's a rift nearby take a ride, then cancel everything else because it's not valid any more
	for(var/obj/effect/temp_visual/lesser_carp_rift/entrance/rift in orange(controller.pawn, CARP_PORTAL_SEARCH_RANGE))
		controller.queue_behavior(/datum/ai_behavior/travel_towards_atom, get_turf(rift))
		return SUBTREE_RETURN_FINISH_PLANNING

	// We have a destination, try to approach it
	var/turf/moving_to = controller.blackboard[BB_CARP_MIGRATION_TARGET]
	if(!isnull(moving_to))
		var/turf/next_step = get_step_towards(controller.pawn, moving_to)
		// Attempt to teleport around if we're blocked
		if(next_step.is_blocked_turf(exclude_mobs = TRUE))
			controller.queue_behavior(/datum/ai_behavior/make_carp_rift/towards/unvalidated, BB_CARP_RIFT, BB_CARP_MIGRATION_TARGET)
			controller.queue_behavior(/datum/ai_behavior/attack_obstructions/carp, BB_CARP_MIGRATION_TARGET)
		controller.queue_behavior(/datum/ai_behavior/step_towards_turf, BB_CARP_MIGRATION_TARGET)
		// We've gotten close enough to it, clear it so we can select a new point (or do nothing)
		if(get_dist(controller.pawn, moving_to) <= CARP_DESTINATION_SEARCH_RANGE)
			controller.clear_blackboard_key(BB_CARP_MIGRATION_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	// We have a path to follow but no destination, select one
	if(length(controller.blackboard[BB_CARP_MIGRATION_PATH]))
		controller.queue_behavior(/datum/ai_behavior/find_next_carp_migration_step, BB_CARP_MIGRATION_PATH, BB_CARP_MIGRATION_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

/**
 * # Find next carp migration step
 * Records the next turf we want to travel to into the blackboard for other actions
 */
/datum/ai_behavior/find_next_carp_migration_step

/datum/ai_behavior/find_next_carp_migration_step/perform(seconds_per_tick, datum/ai_controller/controller, path_key, target_key)
	var/list/blackboard_points = controller.blackboard[path_key]
	for(var/turf/migration_point as anything in blackboard_points)
		// By the end of this loop we will either have a valid migration point set, or an empty list in our blackboard
		blackboard_points -= migration_point
		if(get_dist(controller.pawn, migration_point) > CARP_DESTINATION_SEARCH_RANGE)
			controller.set_blackboard_key(target_key, migration_point)
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

#undef CARP_DESTINATION_SEARCH_RANGE
#undef CARP_PORTAL_SEARCH_RANGE
