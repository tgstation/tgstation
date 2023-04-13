/// How close you need to get to the destination in order to consider yourself there
#define CARP_DESTINATION_SEARCH_RANGE 3
/// If there's a portal this close to us we'll enter it just on the basis that the carp who made it probably knew where they were going
#define CARP_PORTAL_SEARCH_RANGE 2

/**
 * # Carp Migration
 * Will try to plan a path between a list of locations for carp to travel through
 */
/datum/ai_planning_subtree/carp_migration

/datum/ai_planning_subtree/carp_migration/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()

	// If there's a rift nearby take a ride, then cancel everything else because it's not valid any more
	var/obj/effect/temp_visual/lesser_carp_rift/entrance/rift = locate(/obj/effect/temp_visual/lesser_carp_rift/entrance) in orange(controller.pawn, CARP_PORTAL_SEARCH_RANGE)
	if (rift)
		controller.queue_behavior(/datum/ai_behavior/travel_towards_atom, get_turf(rift))
		return SUBTREE_RETURN_FINISH_PLANNING

	var/list/migration_points = controller.blackboard[BB_CARP_MIGRATION_PATH]
	if (!length(migration_points))
		return

	var/datum/weakref/weak_target = controller.blackboard[BB_CARP_MIGRATION_TARGET]
	var/turf/moving_to = weak_target?.resolve()

	// If we don't have a target or are close enough to it, pick a new one
	if (isnull(moving_to) || get_dist(controller.pawn, moving_to) <= CARP_DESTINATION_SEARCH_RANGE)
		controller.queue_behavior(/datum/ai_behavior/find_next_carp_migration_step, BB_CARP_MIGRATION_PATH, BB_CARP_MIGRATION_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	var/turf/next_step = get_step_towards(controller.pawn, moving_to)
	if (next_step.is_blocked_turf(exclude_mobs = TRUE))
		controller.queue_behavior(/datum/ai_behavior/make_carp_rift/towards/unvalidated, BB_CARP_RIFT, BB_CARP_MIGRATION_TARGET)
		controller.queue_behavior(/datum/ai_behavior/attack_obstructions/carp, BB_CARP_MIGRATION_TARGET)
	controller.queue_behavior(/datum/ai_behavior/step_towards_turf, BB_CARP_MIGRATION_TARGET)

	return SUBTREE_RETURN_FINISH_PLANNING

/**
 * # Find next carp migration step
 * Records the next turf we want to travel to into the blackboard for other actions
 */
/datum/ai_behavior/find_next_carp_migration_step

/datum/ai_behavior/find_next_carp_migration_step/perform(delta_time, datum/ai_controller/controller, path_key, target_key)
	var/list/blackboard_points = controller.blackboard[path_key]
	var/list/potential_migration_points = blackboard_points.Copy()
	while (length(potential_migration_points))
		var/datum/weakref/weak_destination = popleft(potential_migration_points)
		var/turf/potential_destination = weak_destination.resolve()
		if (!isnull(potential_destination) && get_dist(controller.pawn, potential_destination) > CARP_DESTINATION_SEARCH_RANGE)
			controller.blackboard[target_key] = weak_destination
			finish_action(controller, succeeded = TRUE)
			return
		controller.blackboard[path_key] = potential_migration_points.Copy()

	finish_action(controller, succeeded = FALSE)

#undef CARP_DESTINATION_SEARCH_RANGE
#undef CARP_PORTAL_SEARCH_RANGE
