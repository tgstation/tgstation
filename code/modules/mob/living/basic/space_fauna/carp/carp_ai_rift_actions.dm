/// It's not worth going into a rift to close the distance if we're already within this range of our target
#define MINIMUM_RIFT_SHORTCUT_DISTANCE 3

/**
 * Perform a carp rift action, so basically teleport somewhere if the action is available
 */
/datum/ai_planning_subtree/make_carp_rift
	/// Chiefly describes where we are placing this teleport
	var/datum/ai_behavior/rift_behaviour
	/// If true we finish planning after this
	var/finish_planning = FALSE

/datum/ai_planning_subtree/make_carp_rift/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if (!rift_behaviour)
		CRASH("Forgot to specify rift behaviour for [src]")

	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/mob/living/target = weak_target?.resolve()
	if(QDELETED(target))
		return

	var/datum/action/cooldown/using_action = controller.blackboard[BB_CARP_RIFT]
	if(QDELETED(using_action))
		return
	if (!using_action.IsAvailable())
		return

	controller.queue_behavior(rift_behaviour, BB_CARP_RIFT, BB_BASIC_MOB_CURRENT_TARGET)
	if (finish_planning)
		return SUBTREE_RETURN_FINISH_PLANNING

/// Teleport out of there, if you have a target you are scared of
/datum/ai_planning_subtree/make_carp_rift/panic_teleport
	rift_behaviour = /datum/ai_behavior/make_carp_rift/away
	finish_planning = TRUE

/datum/ai_planning_subtree/make_carp_rift/panic_teleport/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if (!controller.blackboard[BB_BASIC_MOB_FLEEING])
		return
	return ..()

/// Carp rift towards something to bite them, but only if they're at the edge of our range
/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport
	rift_behaviour = /datum/ai_behavior/make_carp_rift/towards

/**
 * Perform the actual behaviour of finding a target turf and placing a rift there
 */
/datum/ai_behavior/make_carp_rift

/datum/ai_behavior/make_carp_rift/perform(delta_time, datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability = controller.blackboard[ability_key]
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()

	if(!validate_target(controller, target, ability))
		finish_action(controller, FALSE, ability_key, target_key)
		return

	var/turf/target_destination = find_target_turf(controller, target, ability)
	if (!target_destination)
		finish_action(controller, FALSE, ability_key, target_key)
		return

	var/result = ability.InterceptClickOn(controller.pawn, null, target_destination)
	finish_action(controller, result, ability_key, target_key)

/// Return true if your target is valid for the action
/datum/ai_behavior/make_carp_rift/proc/validate_target(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	if (!ability)
		return FALSE
	if (QDELETED(target))
		return FALSE
	return TRUE

/// Return the turf to teleport to, implement this or the behaviour won't do anything
/datum/ai_behavior/make_carp_rift/proc/find_target_turf(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	CRASH("Called unimplemented target finding proc on carp rift behaviour")

/// Create a carp rift in a direction away from your target
/datum/ai_behavior/make_carp_rift/away

/datum/ai_behavior/make_carp_rift/away/find_target_turf(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	var/run_direction = get_dir(controller.pawn, get_step_away(controller.pawn, target))
	return get_ranged_target_turf(controller.pawn, run_direction, ability.max_range)

/// Create a carp rift in a direction towards your target
/datum/ai_behavior/make_carp_rift/towards
	/// Drop rift at least this many tiles away from target, because you can appear in any space adjacent to it
	var/teleport_buffer_distance = 2

/datum/ai_behavior/make_carp_rift/towards/validate_target(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	. = ..()
	if (!.)
		return FALSE

	var/distance = get_dist(get_turf(controller.pawn), get_turf(target))
	if (distance >= ability.max_range + teleport_buffer_distance) // Perform if we are far away
		return TRUE

	var/turf/next_move = get_step_towards(controller.pawn, target)
	return next_move.is_blocked_turf(exclude_mobs = TRUE) // Perform if target is behind cover

/datum/ai_behavior/make_carp_rift/towards/find_target_turf(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	var/turf/target_turf = get_turf(target)
	var/distance = get_dist(get_turf(controller.pawn), target_turf)

	var/turf/chosen_turf

	if (distance <= ability.max_range)
		chosen_turf = target_turf
	else
		var/run_direction = get_dir(controller.pawn, get_step_towards(controller.pawn, target_turf))
		chosen_turf =  get_ranged_target_turf(controller.pawn, run_direction, ability.max_range)

	if (!chosen_turf)
		return

	// Subtract some distance so we don't drop carp directly on top of someone
	var/rift_to_target_distance = get_dist(target_turf, chosen_turf)
	if (rift_to_target_distance < teleport_buffer_distance)
		var/away_direction = get_dir(controller.pawn, get_step_away(controller.pawn, target_turf))
		var/turf/backed_away_turf =  get_ranged_target_turf(controller.pawn, away_direction, teleport_buffer_distance - rift_to_target_distance)
		if (distance > get_dist(backed_away_turf, target_turf))
			chosen_turf = backed_away_turf // Avoid edge case pointless teleports from being up against a wall

	return chosen_turf

/// If there's already a portal going your way don't make another one
/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift

/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/mob/living/target = weak_target?.resolve()
	if(QDELETED(target))
		return

	controller.queue_behavior(/datum/ai_behavior/enter_nearby_rift, BB_BASIC_MOB_CURRENT_TARGET)

/datum/ai_behavior/enter_nearby_rift
	required_distance = 0
	action_cooldown = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	/// How far away do we look for rifts?
	var/search_distance = 2

/datum/ai_behavior/enter_nearby_rift/setup(datum/ai_controller/controller, target_key, hiding_location_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(QDELETED(target))
		return FALSE

	var/distance_to_target = get_dist(controller.pawn, target)
	if (distance_to_target <= MINIMUM_RIFT_SHORTCUT_DISTANCE)
		return FALSE

	for (var/obj/effect/temp_visual/lesser_carp_rift/entrance/rift in orange(controller.pawn, search_distance))
		var/exit_count = length(rift.exit_locs)
		if (!exit_count)
			continue
		var/turf/rift_exit = rift.exit_locs[exit_count]
		if (get_dist(rift_exit, target) >= distance_to_target)
			continue
		controller.current_movement_target = get_turf(rift)
		return TRUE
	return FALSE

/datum/ai_behavior/enter_nearby_rift/perform(delta_time, datum/ai_controller/controller, target_key, hiding_location_key)
	. = ..()
	finish_action(controller, TRUE)

#undef MINIMUM_RIFT_SHORTCUT_DISTANCE
