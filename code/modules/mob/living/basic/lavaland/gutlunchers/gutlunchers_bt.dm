// =============================================================================
// Gutlunchers BT-native behaviors
// =============================================================================

/**
 * Searches for nearby ashwalkers and befriends them, printing a message to the ashwalker.
 * Returns FAILURE if no new ashwalker is found. Uses time_between_perform for rate limiting.
 */
/datum/bt_node/ai_behavior/befriend_ashwalkers
	time_between_perform = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/bt_node/ai_behavior/befriend_ashwalkers/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	for(var/mob/living/potential_friend in oview(9, living_pawn))
		if(!isashwalker(potential_friend) || living_pawn.has_ally(REF(potential_friend)))
			continue
		living_pawn.befriend(potential_friend)
		to_chat(potential_friend, span_nicegreen("[living_pawn] looks at you with endearing eyes!"))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// =============================================================================

/// Searches for a nearby mineral wall the pawn can mine and sets the target key.
/datum/bt_node/ai_behavior/find_mineral_wall

/datum/bt_node/ai_behavior/find_mineral_wall/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living_pawn = controller.pawn
	for(var/turf/closed/mineral/potential_wall in oview(9, living_pawn))
		if(!check_if_mineable(controller, potential_wall))
			continue
		controller.set_blackboard_key(target_key, potential_wall)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/find_mineral_wall/proc/check_if_mineable(datum/ai_controller/controller, turf/target_wall)
	var/mob/living/source = controller.pawn
	var/direction_to_turf = get_dir(target_wall, source)
	if(!ISDIAGONALDIR(direction_to_turf))
		return TRUE
	for(var/direction_check in GLOB.cardinals)
		if(!(direction_check & direction_to_turf))
			continue
		var/turf/test_turf = get_step(target_wall, direction_check)
		if(isnull(test_turf))
			continue
		if(!test_turf.is_blocked_turf(ignore_atoms = list(source)))
			return TRUE
	return FALSE

// =============================================================================

/// Mines the mineral wall at target_key when adjacent. Clears the target key on finish.
/datum/bt_node/ai_behavior/mine_wall
	time_between_perform = 15 SECONDS

/datum/bt_node/ai_behavior/mine_wall/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/living_pawn = controller.pawn
	var/turf/closed/mineral/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!living_pawn.Adjacent(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/is_gibtonite = istype(target, /turf/closed/mineral/gibtonite)
	if(!controller.ai_interact(target = target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(is_gibtonite)
		living_pawn.manual_emote("sighs...")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/mine_wall/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

// =============================================================================

/// Searches for and moves to a parent mob (of types in BB_FIND_MOM_TYPES), sets BB_FOUND_MOM.
/datum/bt_node/ai_behavior/find_parent

/datum/bt_node/ai_behavior/find_parent/perform(seconds_per_tick, datum/ai_controller/controller, mom_types_key, found_mom_key)
	var/mob/living_pawn = controller.pawn
	var/list/mom_types = controller.blackboard[mom_types_key]
	if(!length(mom_types))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	for(var/mob/mother in oview(7, living_pawn))
		if(!is_type_in_list(mother, mom_types))
			continue
		controller.set_blackboard_key(found_mom_key, mother)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// =============================================================================

/// Mine walls pet command subtree: find mineral wall → move to it → mine it → clear command.
/datum/bt_node/subtree/pet_command/mine_walls
	behavior_tree_json = "code/datums/ai/basic_mobs/pet_commands/pet_command_mine_walls.bt.json"
