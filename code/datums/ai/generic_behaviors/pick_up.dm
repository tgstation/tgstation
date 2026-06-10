/// Picks up a blackboard-keyed item. Pair with move_to_target in the BT tree for navigation.
/datum/bt_node/ai_behavior/pick_up
	time_between_perform = 2 SECONDS
	/// Blackboard key holding the item to pick up.
	var/target_key
	/// Whether to drop a currently-held item to free a hand.
	var/drop_held = TRUE

/datum/bt_node/ai_behavior/pick_up/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	return !QDELETED(target)

/datum/bt_node/ai_behavior/pick_up/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/obj/item/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(living_pawn.is_holding(target)) // already in hands
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(!target.IsReachableBy(living_pawn)) // not adjacent yet
		return AI_BEHAVIOR_INSTANT
	if(living_pawn.get_active_held_item()) // something is in our hands already
		if(!drop_held || !living_pawn.dropItemToGround(living_pawn.get_active_held_item()))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.ai_interact(target, combat_mode = FALSE)
	return AI_BEHAVIOR_DELAY | (target.loc == living_pawn ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)
