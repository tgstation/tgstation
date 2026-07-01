/// Drops everything the pawn is currently holding in its hands onto its current turf.
/datum/bt_node/ai_behavior/drop_all_held_items

/datum/bt_node/ai_behavior/drop_all_held_items/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.get_num_held_items())
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	living_pawn.drop_all_held_items()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
