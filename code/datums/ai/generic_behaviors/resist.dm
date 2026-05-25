/// Sets the resisting blackboard key and executes a resist action on the pawn.
/datum/bt_node/ai_behavior/resist/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	living_pawn.ai_controller.set_blackboard_key(BB_RESISTING, TRUE)
	living_pawn.execute_resist()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


// DEPRECATED — port to /datum/bt_node/ai_behavior/resist
/datum/ai_behavior/resist
