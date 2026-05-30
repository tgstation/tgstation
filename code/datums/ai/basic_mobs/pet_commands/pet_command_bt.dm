// Pet-command-specific BT behaviors and override subtrees.
// Generic leaf behaviors (wait, play_dead, pick_up_item_virtual, pass_item_virtual, ai_interact) live in basic_ai_behaviors/.

/// Validates a protect_owner target; clears command + target if invalid.
/datum/bt_node/ai_behavior/protect_owner_check

/datum/bt_node/ai_behavior/protect_owner_check/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/victim = controller.blackboard[BB_CURRENT_PET_TARGET]
	if(QDELETED(victim))
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		controller.clear_blackboard_key(BB_CURRENT_PET_TARGET)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/datum/targeting_strategy/targeter = GET_TARGETING_STRATEGY(controller.blackboard[BB_PET_TARGETING_STRATEGY])
	if(!targeter?.can_attack(controller.pawn, victim))
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		controller.clear_blackboard_key(BB_CURRENT_PET_TARGET)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/minimum_stat = controller.blackboard[BB_TARGET_MINIMUM_STAT]
	if((!isnull(minimum_stat) && victim.stat > minimum_stat) || victim == controller.pawn)
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		controller.clear_blackboard_key(BB_CURRENT_PET_TARGET)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Validates a fetch item at target_key; adds to ignore list and clears keys on failure.
/datum/bt_node/ai_behavior/fetch_seek

/datum/bt_node/ai_behavior/fetch_seek/setup(datum/ai_controller/controller, target_key)
	return !QDELETED(controller.blackboard[target_key])

/datum/bt_node/ai_behavior/fetch_seek/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/obj/item/fetch_thing = controller.blackboard[target_key]
	if(QDELETED(fetch_thing))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(fetch_thing.anchored)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/fetch_seek/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(succeeded)
		return
	var/obj/item/target = controller.blackboard[target_key]
	if(target)
		controller.set_blackboard_key_assoc_lazylist(BB_FETCH_IGNORE_LIST, target, TRUE)
	controller.clear_blackboard_key(target_key)
	controller.clear_blackboard_key(BB_FETCH_DELIVER_TO)

/// Clears the fetch ignore list at most once per AI_FETCH_IGNORE_DURATION. Always succeeds.
/datum/bt_node/ai_behavior/forget_failed_fetches
	COOLDOWN_DECLARE(clear_cooldown)

/datum/bt_node/ai_behavior/forget_failed_fetches/perform(seconds_per_tick, datum/ai_controller/controller)
	if(COOLDOWN_FINISHED(src, clear_cooldown) && LAZYLEN(controller.blackboard[BB_FETCH_IGNORE_LIST]))
		COOLDOWN_START(src, clear_cooldown, AI_FETCH_IGNORE_DURATION)
		controller.clear_blackboard_key(BB_FETCH_IGNORE_LIST)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Clears BB_ACTIVE_PET_COMMAND and removes the SUBPLAN_ID_PET_COMMAND override.
/datum/bt_node/ai_behavior/clear_pet_command

/datum/bt_node/ai_behavior/clear_pet_command/perform(seconds_per_tick, datum/ai_controller/controller)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	controller.set_behavior_tree_override(SUBPLAN_ID_PET_COMMAND, null)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

// =============================================================================
// Override subtrees — installed by execute_action via set_behavior_tree_override.
// behavior_nodes for each is generated from the corresponding .bt.json file.
// =============================================================================

/// Waits forever; blocks normal AI while stay/idle is active.
/datum/bt_node/subtree/pet_command/stay
	behavior_tree_json = "pet_command_stay.bt.json"

/// Loops move_to_target toward BB_CURRENT_PET_TARGET until the key is cleared.
/datum/bt_node/subtree/pet_command/follow
	behavior_tree_json = "pet_command_follow.bt.json"

/// Plays dead (10%/tick to get up). Clears command on revival.
/datum/bt_node/subtree/pet_command/play_dead
	behavior_tree_json = "pet_command_play_dead.bt.json"

/// Attacks BB_CURRENT_PET_TARGET in a looping melee combat parallel.
/datum/bt_node/subtree/pet_command/attack
	behavior_tree_json = "pet_command_attack.bt.json"

/// Protect owner: loops a validity check then melee attack. Clears command if target invalid.
/datum/bt_node/subtree/pet_command/protect_owner
	behavior_tree_json = "pet_command_protect_owner.bt.json"

/// Travels to BB_CURRENT_PET_TARGET, clears command on arrival.
/datum/bt_node/subtree/pet_command/move_to
	behavior_tree_json = "pet_command_move_to.bt.json"

/// Moves to BB_CURRENT_PET_TARGET and fishes there on a loop.
/datum/bt_node/subtree/pet_command/fish
	behavior_tree_json = "pet_command_fish.bt.json"

/// Moves to BB_CURRENT_PET_TARGET and breeds once. Clears command on completion.
/datum/bt_node/subtree/pet_command/breed
	behavior_tree_json = "pet_command_breed.bt.json"

/// Moves to BB_CURRENT_PET_TARGET and fires BB_TARGETED_ACTION on it once.
/datum/bt_node/subtree/pet_command/targeted_ability
	behavior_tree_json = "pet_command_targeted_ability.bt.json"

/// Fires the ability stored in BB_PET_ACTIVE_ABILITY once (untargeted).
/datum/bt_node/subtree/pet_command/untargeted_ability
	behavior_tree_json = "pet_command_untargeted_ability.bt.json"

/// Fetch: seek → pick up → deliver. Falls back to clear_pet_command if nothing to do.
/datum/bt_node/subtree/pet_command/fetch
	behavior_tree_json = "pet_command_fetch.bt.json"
