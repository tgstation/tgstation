/**
 * # Make carp rift
 * Use the carp rift ability to teleport somewhere relative to a target.
 */
/datum/bt_node/ai_behavior/make_carp_rift
	/// Blackboard key holding the rift ability
	var/ability_key = BB_CARP_RIFT
	/// Blackboard key holding the atom we're teleporting relative to
	var/target_key

/datum/bt_node/ai_behavior/make_carp_rift/setup(datum/ai_controller/controller)
	. = ..()
	if(!controller.blackboard[ability_key] || !controller.blackboard[target_key])
		return FALSE

/datum/bt_node/ai_behavior/make_carp_rift/perform(seconds_per_tick, datum/ai_controller/controller)
	var/datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability = controller.blackboard[ability_key]
	var/atom/target = controller.blackboard[target_key]

	// Fail INSTANT (not DELAY) so a selector falls through to melee/obstacles when we can't teleport,
	// rather than latching on us while our cooldown ticks down.
	if(!validate_target(controller, target, ability))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/turf/target_destination = find_target_turf(controller, target, ability)
	if(!target_destination)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if(ability.InterceptClickOn(controller.pawn, null, target_destination))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/// Return true if your target is valid for the action
/datum/bt_node/ai_behavior/make_carp_rift/proc/validate_target(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	if(!ability)
		return FALSE
	if(!target)
		return FALSE
	return TRUE

/// Return the turf to teleport to, implement this or the behaviour won't do anything
/datum/bt_node/ai_behavior/make_carp_rift/proc/find_target_turf(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	CRASH("Called unimplemented target finding proc on carp rift behaviour")

/**
 * # Make carp rift away
 * Make a rift bringing you further away from your target
 */
/datum/bt_node/ai_behavior/make_carp_rift/away

/datum/bt_node/ai_behavior/make_carp_rift/away/find_target_turf(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	return get_ranged_target_turf_direct(controller.pawn, target, range = ability.max_range, offset = 180)

/**
 * # Make carp rift forwards
 * Make a rift bringing you closer to your target
 */
/datum/bt_node/ai_behavior/make_carp_rift/towards
	/// Drop rift at least this many tiles away from target
	var/teleport_buffer_distance = 0
	/// Teleport simply if you are far away
	var/teleport_if_far = TRUE
	/// Teleport if the turf in front of you is blocked
	var/teleport_if_blocked = TRUE

/datum/bt_node/ai_behavior/make_carp_rift/towards/validate_target(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	. = ..()
	if(!.)
		return FALSE

	if(teleport_if_far)
		var/distance = get_dist(get_turf(controller.pawn), get_turf(target))
		if(distance >= ability.max_range + teleport_buffer_distance) // Perform if we are far away
			return TRUE

	if(teleport_if_blocked)
		var/turf/next_move = get_step_towards(controller.pawn, target)
		if(next_move.is_blocked_turf(exclude_mobs = TRUE)) // Perform if target is behind cover
			return TRUE

	return FALSE

/datum/bt_node/ai_behavior/make_carp_rift/towards/find_target_turf(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	var/turf/target_turf = get_turf(target)
	var/distance = get_dist(get_turf(controller.pawn), target_turf)

	var/turf/chosen_turf

	if(distance <= ability.max_range)
		chosen_turf = target_turf
	else
		var/run_direction = get_dir(controller.pawn, get_step_towards(controller.pawn, target_turf))
		chosen_turf = get_ranged_target_turf(controller.pawn, run_direction, ability.max_range)

	if(!chosen_turf)
		return

	// Subtract some distance so we don't drop carp directly on top of someone
	var/rift_to_target_distance = get_dist(target_turf, chosen_turf)
	if(rift_to_target_distance < teleport_buffer_distance)
		var/away_direction = get_dir(controller.pawn, get_step_away(controller.pawn, target_turf))
		var/turf/backed_away_turf = get_ranged_target_turf(controller.pawn, away_direction, teleport_buffer_distance - rift_to_target_distance)
		if(distance > get_dist(backed_away_turf, target_turf))
			chosen_turf = backed_away_turf // Avoid edge case pointless teleports from being up against a wall

	return chosen_turf

/**
 * # Make carp rift forwards (aggressive)
 * Make a rift towards your target if you are blocked from moving or if it is far away
 */
/datum/bt_node/ai_behavior/make_carp_rift/towards/aggressive
	teleport_buffer_distance = 1 // Don't aggressively drop carps directly on top of a target mob

/**
 * # Make carp rift forwards (unvalidated)
 * Skip validation checks because we already did them elsewhere
 */
/datum/bt_node/ai_behavior/make_carp_rift/towards/unvalidated

/datum/bt_node/ai_behavior/make_carp_rift/towards/unvalidated/validate_target(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	return TRUE

/datum/bt_node/ai_behavior/make_carp_rift/towards/unvalidated/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	if(succeeded)
		controller.CancelActions()

/**
 * # Find carp rift shortcut
 * If there's a carp rift heading towards our target, record its turf so we can ride it there.
 */
/datum/bt_node/ai_behavior/find_carp_rift_shortcut
	/// Blackboard key holding our current target
	var/target_key = BB_CURRENT_TARGET
	/// Blackboard key in which we store the rift turf to travel to
	var/destination_key = BB_CARP_RIFT_DESTINATION
	/// How far away do we look for rifts?
	var/search_distance = 3
	/// Minimum distance we should be from the target before we bother
	var/minimum_distance = 2

/datum/bt_node/ai_behavior/find_carp_rift_shortcut/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target) || (controller.blackboard[BB_CARPS_FEAR_FISHERMAN] && HAS_TRAIT(target, TRAIT_SCARY_FISHERMAN)))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/distance_to_target = get_dist(controller.pawn, target)
	if(distance_to_target <= minimum_distance)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	for(var/obj/effect/temp_visual/lesser_carp_rift/entrance/rift in orange(controller.pawn, search_distance))
		var/exit_count = length(rift.exit_locs)
		if(!exit_count)
			continue
		var/turf/rift_exit = rift.exit_locs[exit_count]
		if((get_dist(rift_exit, target) + get_dist(rift, target)) >= distance_to_target)
			continue
		controller.set_blackboard_key(destination_key, get_turf(rift))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/**
 * # Find nearby carp rift
 * Record the turf of any nearby rift entrance so we can ride it; the carp who made it probably knew where they were going.
 */
/datum/bt_node/ai_behavior/find_carp_rift_shortcut/nearby
	search_distance = 2
	minimum_distance = 0

/datum/bt_node/ai_behavior/find_carp_rift_shortcut/nearby/perform(seconds_per_tick, datum/ai_controller/controller)
	for(var/obj/effect/temp_visual/lesser_carp_rift/entrance/rift in orange(controller.pawn, search_distance))
		controller.set_blackboard_key(destination_key, get_turf(rift))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
