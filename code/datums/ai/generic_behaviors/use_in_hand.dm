/// Uses the pawn's currently active held item in-hand.
/datum/bt_node/ai_behavior/use_in_hand

/datum/bt_node/ai_behavior/use_in_hand/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	var/obj/item/held = pawn.get_active_held_item()
	if(!held)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	pawn.activate_hand()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
