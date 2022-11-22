/// How close you need to get to the destination in order to consider yourself there
#define CARP_DESTINATION_SEARCH_RANGE 3

/**
 * # Carp Migration
 * Will try to plan a path between a list of locations for carp to travel through
 */
/datum/ai_planning_subtree/carp_migration

/datum/ai_planning_subtree/carp_migration/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()

	// If there's a rift nearby take a ride, then cancel everything else because it's not valid any more
	controller.queue_behavior(/datum/ai_behavior/enter_nearby_rift_and_end_actions)

	var/list/migration_points = controller.blackboard[BB_CARP_MIGRATION_PATH]
	if (!length(migration_points))
		return

	controller.queue_behavior(/datum/ai_behavior/find_next_carp_migration_step, BB_CARP_MIGRATION_PATH, BB_CARP_MIGRATION_TARGET)
	controller.queue_behavior(/datum/ai_behavior/make_carp_rift/towards/passive, BB_CARP_RIFT, BB_CARP_MIGRATION_TARGET)
	controller.queue_behavior(/datum/ai_behavior/attack_obstacle_in_path, BB_CARP_MIGRATION_TARGET)
	controller.queue_behavior(/datum/ai_behavior/step_towards_turf, BB_CARP_MIGRATION_TARGET)

	return SUBTREE_RETURN_FINISH_PLANNING

/**
 * # Find next carp migration step
 * Records the next turf we want to travel to into the blackboard for other actions
 */
/datum/ai_behavior/find_next_carp_migration_step

/datum/ai_behavior/find_next_carp_migration_step/setup(datum/ai_controller/controller, path_key, target_key)
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	if (weak_target)
		var/turf/previous_target = weak_target.resolve()
		if (!QDELETED(previous_target) && get_dist(controller.pawn, previous_target) > CARP_DESTINATION_SEARCH_RANGE)
			return FALSE // We're not necessary, there's already a perfectly good target

	var/list/migration_points = controller.blackboard[path_key]
	return length(migration_points)

/datum/ai_behavior/find_next_carp_migration_step/perform(delta_time, datum/ai_controller/controller, path_key, target_key)
	var/list/blackboard_points = controller.blackboard[path_key]
	var/list/potential_migration_points = blackboard_points.Copy()
	while (length(potential_migration_points))
		var/datum/weakref/weak_destination = popleft(potential_migration_points)
		var/turf/potential_destination = weak_destination.resolve()
		if (!QDELETED(potential_destination) && get_dist(controller.pawn, potential_destination) > CARP_DESTINATION_SEARCH_RANGE)
			controller.blackboard[target_key] = weak_destination
			finish_action(controller, succeeded = TRUE)
			return
		controller.blackboard[path_key] = potential_migration_points.Copy()

	finish_action(controller, succeeded = FALSE)

#undef CARP_DESTINATION_SEARCH_RANGE
