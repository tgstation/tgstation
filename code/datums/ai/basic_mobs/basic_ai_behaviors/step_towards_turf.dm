/**
 * # Step towards turf
 * Moves a short distance towards a location repeatedly until you arrive at the destination.
 * You'd use this over travel_towards if you're travelling a long distance over a long time, because the AI controller has a maximum range.
 */
/datum/ai_behavior/step_towards_turf
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// How far ahead do we plot movement per action? Further means longer until we return to the decision tree, fewer means jerkier movement
	/// This can still result in long moves because this is "a tile x tiles away" not "only move x tiles", you might path around some walls
	var/step_distance = 3

/datum/ai_behavior/step_towards_turf/setup(datum/ai_controller/controller, turf_key)
	var/datum/weakref/weak_turf = controller.blackboard[turf_key]
	var/turf/target_turf = weak_turf?.resolve()
	if (!target_turf || target_turf.is_blocked_turf(exclude_mobs = TRUE))
		target_turf = find_destination_turf(args)
		if (!target_turf)
			return FALSE
		controller.blackboard[turf_key] = WEAKREF(target_turf)

	if (target_turf.z != controller.pawn.z)
		return FALSE

	var/turf/destination = plot_movement(controller, target_turf)
	if (!destination)
		return FALSE
	set_movement_target(controller, destination)
	return ..()

/**
 * Get a turf to aim towards if we don't already have one, the default behaviour is actually to not do this but we want to extend it
 * Gets passed all of the arguments from `setup`
 */
/datum/ai_behavior/step_towards_turf/proc/find_destination_turf()
	return null

/**
 * Figure out where we're going to move to, which isn't all the way to the destination in one go
 */
/datum/ai_behavior/step_towards_turf/proc/plot_movement(datum/ai_controller/controller, turf/target_turf)
	var/distance_to_destination = get_dist(controller.pawn, target_turf)
	if (distance_to_destination <= step_distance)
		return target_turf

	var/direction_to_destination = get_dir(controller.pawn, target_turf)
	return get_ranged_target_turf(controller.pawn, direction_to_destination, step_distance)

// We actually only wanted the movement so if we've arrived we're done
/datum/ai_behavior/step_towards_turf/perform(delta_time, datum/ai_controller/controller, area_key, turf_key)
	. = ..()
	finish_action(controller, succeeded = TRUE)

/**
 * # Step towards turf in area
 * Moves a short distance towards a location in an area
 * Unlike step_towards_turf it will reacquire a new turf from the area if it loses its target
 */
/datum/ai_behavior/step_towards_turf/in_area

/datum/ai_behavior/step_towards_turf/in_area/setup(datum/ai_controller/controller, turf_key, area_key)
	var/area/target_area = controller.blackboard[area_key]
	if (!target_area)
		return FALSE

	return ..()

// Return the first valid turf in the area to replace a lost target
/datum/ai_behavior/step_towards_turf/in_area/find_destination_turf(datum/ai_controller/controller, turf_key, area_key)
	var/area/target_area = controller.blackboard[area_key]
	var/list/target_area_turfs = get_area_turfs(target_area.type)
	for (var/turf/potential_target as anything in target_area_turfs)
		if (potential_target.is_blocked_turf(exclude_mobs = TRUE))
			continue
		return potential_target
	return null
