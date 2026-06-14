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


/// Searches for and moves to a parent mob (of types in BB_FIND_MOM_TYPES), sets BB_FOUND_MOM.
/datum/bt_node/ai_behavior/find_parent
	var/mom_types_key
	var/found_mom_key

/datum/bt_node/ai_behavior/find_parent/perform(seconds_per_tick, datum/ai_controller/controller)
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

//

/// Mine walls pet command subtree: find mineral wall -> move to it -> mine it -> clear command.
/datum/bt_node/subtree/pet_command/mine_walls
	behavior_tree_json = "code/datums/ai/basic_mobs/pet_commands/pet_command_mine_walls.bt.json"
