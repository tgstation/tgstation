/// Searches nearby for a stealable item (not anchored, not already being pulled) and sets target_key.
/datum/bt_node/ai_behavior/find_stealable
	var/target_key = BB_ITEM_TO_STEAL
	var/search_range = SEARCH_TACTIC_DEFAULT_RANGE

/datum/bt_node/ai_behavior/find_stealable/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	for(var/obj/item/possible_item in shuffle_inplace(oview(search_range, living_pawn)))
		if(possible_item.pulledby || possible_item.anchored)
			continue
		if(can_see(living_pawn, possible_item))
			controller.set_blackboard_key(target_key, possible_item)
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
