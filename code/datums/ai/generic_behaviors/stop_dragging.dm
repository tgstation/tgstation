/// Stops the pawn from pulling whatever it is currently dragging.
/datum/bt_node/ai_behavior/stop_dragging

/datum/bt_node/ai_behavior/stop_dragging/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	living_pawn.stop_pulling()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
