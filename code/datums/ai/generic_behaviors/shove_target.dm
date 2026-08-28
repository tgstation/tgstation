
//Shoves the blackboard target
/datum/bt_node/ai_behavior/shove_target
	/// Blackboard key holding the mob to shove.
	var/target_key
	/// Percent chance to actually go for the shove.
	var/shove_chance = 100

/datum/bt_node/ai_behavior/shove_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/living_target = controller.blackboard[target_key]

	if(!isliving(living_pawn) || !isliving(living_target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if(world.time < living_pawn.next_move)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if(!prob(shove_chance))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if(!living_target.IsReachableBy(living_pawn))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	// Standing up, not ourselves, not sharing a turf.
	if(!living_pawn.can_disarm(living_target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	// Right click only shoves off an empty hand, and the click chain uses whichever hand is active,
	// so an occupied active hand has to be swapped out of first or we'd swing our weapon instead.
	if(!free_up_hand(living_pawn))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/ai_controller, ai_interact), living_target, TRUE, list(RIGHT_CLICK = TRUE))
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Makes sure the active hand is empty, swapping to a free one if it isn't. FALSE when every hand is full.
/datum/bt_node/ai_behavior/shove_target/proc/free_up_hand(mob/living/living_pawn)
	if(isnull(living_pawn.get_active_held_item()))
		return TRUE
	var/list/empty_hands = living_pawn.get_empty_held_indexes()
	if(!length(empty_hands))
		return FALSE
	living_pawn.swap_hand(empty_hands[1])
	return isnull(living_pawn.get_active_held_item())
