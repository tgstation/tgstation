/datum/ai_behavior/head_to_hideout
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

	/// How far ahead do we plot movement per action? Further means longer until we return to the decision tree, fewer means jerkier movement
	/// This can still result in long moves because this is "a tile x tiles away" not "only move x tiles", you might path around some walls
	var/step_distance = 3

/datum/ai_behavior/head_to_hideout/setup(datum/ai_controller/controller)
	var/datum/weakref/weak_turf = controller.blackboard[BB_GARY_HIDEOUT]
	var/turf/target_turf = weak_turf?.resolve()
	if (!target_turf || target_turf.is_blocked_turf(exclude_mobs = TRUE))
		if (!target_turf)
			return FALSE
		controller.blackboard[BB_GARY_HIDEOUT] = WEAKREF(target_turf)

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
/datum/ai_behavior/head_to_hideout/proc/find_destination_turf()
	return null

/**
 * Figure out where we're going to move to, which isn't all the way to the destination in one go
 */
/datum/ai_behavior/head_to_hideout/proc/plot_movement(datum/ai_controller/controller, turf/target_turf)
	var/distance_to_destination = get_dist(controller.pawn, target_turf)
	if (distance_to_destination <= step_distance)
		return target_turf

	var/direction_to_destination = get_dir(controller.pawn, target_turf)
	return get_ranged_target_turf(controller.pawn, direction_to_destination, step_distance)

// We actually only wanted the movement so if we've arrived we're done
/datum/ai_behavior/head_to_hideout/perform(seconds_per_tick, datum/ai_controller/controller, area_key, turf_key)
	. = ..()
	controller.blackboard[BB_GARY_COME_HOME] = FALSE
	finish_action(controller, succeeded = TRUE)

/datum/ai_behavior/head_to_hideout/finish_action(datum/ai_controller/controller, succeeded, ...)
	controller.blackboard[BB_GARY_COME_HOME] = FALSE
	. = ..()

/datum/ai_behavior/head_to_hideout/drop/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	var/mob/living/basic/chicken/gary/pawn = controller.pawn
	pawn.held_item.forceMove(get_turf(pawn))
	pawn.held_shinies += pawn.held_item.type
	pawn.held_item.AddComponent(/datum/component/garys_item)
	pawn.held_item = null
	controller.blackboard[BB_GARY_HAS_SHINY] = FALSE
	. = ..()

/datum/ai_behavior/setup_hideout
	///all stored items retrieved from the save of gary
	var/list/stored_items = list()

/datum/ai_behavior/setup_hideout/setup(datum/ai_controller/controller)
	var/mob/living/basic/chicken/gary/pawn = controller.pawn

	stored_items = pawn.return_stored_items()

	var/turf/current_home = get_turf(pawn)
	for(var/shiny_object in stored_items)
		var/obj/item/spawned = new shiny_object(current_home)
		spawned.AddComponent(/datum/component/garys_item)
