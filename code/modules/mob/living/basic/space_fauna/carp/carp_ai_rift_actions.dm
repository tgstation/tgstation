/**
 * # Make carp rift
 * Plan a carp rift action, so basically teleport somewhere if the action is available
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
	if (!target)
		return

	var/datum/action/cooldown/using_action = controller.blackboard[BB_CARP_RIFT]
	if (isnull(using_action))
		return
	if (!using_action.IsAvailable())
		return

	controller.queue_behavior(rift_behaviour, BB_CARP_RIFT, BB_BASIC_MOB_CURRENT_TARGET)
	if (finish_planning)
		return SUBTREE_RETURN_FINISH_PLANNING

/**
 * # Make carp rift (panic)
 * Plan to teleport away from our target so they can't fuck us up
 */
/datum/ai_planning_subtree/make_carp_rift/panic_teleport
	rift_behaviour = /datum/ai_behavior/make_carp_rift/away
	finish_planning = TRUE

/datum/ai_planning_subtree/make_carp_rift/panic_teleport/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if (!controller.blackboard[BB_BASIC_MOB_FLEEING])
		return
	return ..()

/**
 * # Make carp rift (aggressive)
 * Plan to teleport towards our target so we can fuck them up
 */
/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport
	rift_behaviour = /datum/ai_behavior/make_carp_rift/towards/aggressive

/**
 * # Make carp rift
 * Make a carp rift somewhere
 */
/datum/ai_behavior/make_carp_rift

/datum/ai_behavior/make_carp_rift/setup(datum/ai_controller/controller, ability_key, target_key)
	var/datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability = controller.blackboard[ability_key]
	if (!ability)
		return FALSE
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	return target

/datum/ai_behavior/make_carp_rift/perform(delta_time, datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability = controller.blackboard[ability_key]
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()

	if (!validate_target(controller, target, ability))
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
	if (!target)
		return FALSE
	return TRUE

/// Return the turf to teleport to, implement this or the behaviour won't do anything
/datum/ai_behavior/make_carp_rift/proc/find_target_turf(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	CRASH("Called unimplemented target finding proc on carp rift behaviour")

/**
 * # Make carp rift away
 * Make a rift bringing you further away from your target
 */
/datum/ai_behavior/make_carp_rift/away

/datum/ai_behavior/make_carp_rift/away/find_target_turf(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	var/run_direction = get_dir(controller.pawn, get_step_away(controller.pawn, target))
	return get_ranged_target_turf(controller.pawn, run_direction, ability.max_range)

/**
 * # Make carp rift forwards
 * Make a rift bringing you closer to your target
 */
/datum/ai_behavior/make_carp_rift/towards
	/// Drop rift at least this many tiles away from target
	var/teleport_buffer_distance = 0
	/// Teleport simply if you are far away
	var/teleport_if_far = TRUE
	/// Teleport if the turf in front of you is blocked
	var/teleport_if_blocked = TRUE

/datum/ai_behavior/make_carp_rift/towards/validate_target(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	. = ..()
	if (!.)
		return FALSE

	if (teleport_if_far)
		var/distance = get_dist(get_turf(controller.pawn), get_turf(target))
		if (distance >= ability.max_range + teleport_buffer_distance) // Perform if we are far away
			return TRUE

	if (teleport_if_blocked)
		var/turf/next_move = get_step_towards(controller.pawn, target)
		if (next_move.is_blocked_turf(exclude_mobs = TRUE)) // Perform if target is behind cover
			return TRUE

	return FALSE

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

/**
 * # Make carp rift forwards (aggressive)
 * Make a rift towards your target if you are blocked from moving or if it is far away
 */
/datum/ai_behavior/make_carp_rift/towards/aggressive
	teleport_buffer_distance = 2 // Don't aggressively drop carps directly on top of a target mob

/**
 * # Make carp rift forwards (unvalidated)
 * Skip validation checks because we already did them in the controller
 */
/datum/ai_behavior/make_carp_rift/towards/unvalidated

/datum/ai_behavior/make_carp_rift/towards/unvalidated/validate_target(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	return TRUE

/datum/ai_behavior/make_carp_rift/towards/unvalidated/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	if (succeeded)
		controller.CancelActions()

/**
 * # Shortcut to target through carp rift
 * If there's a carp rift heading your way, plan to ride it to your target
 */
/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift
	/// How far away do we look for rifts?
	var/search_distance = 2
	/// Minimum distance we should be from the target before we bother performing this action
	var/minimum_distance = 3

/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/mob/living/target = weak_target?.resolve()
	if (isnull(target))
		return

	var/distance_to_target = get_dist(controller.pawn, target)
	if (distance_to_target <= minimum_distance)
		return

	for (var/obj/effect/temp_visual/lesser_carp_rift/entrance/rift in orange(controller.pawn, search_distance))
		var/exit_count = length(rift.exit_locs)
		if (!exit_count)
			continue
		var/turf/rift_exit = rift.exit_locs[exit_count]
		if (get_dist(rift_exit, target) >= distance_to_target)
			continue
		controller.queue_behavior(/datum/ai_behavior/travel_towards_atom, get_turf(rift))
		return SUBTREE_RETURN_FINISH_PLANNING
