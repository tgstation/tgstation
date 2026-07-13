/datum/bt_node/ai_behavior/resist/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags

	return start_async()

/datum/bt_node/ai_behavior/resist/perform_async(datum/ai_controller/controller)

	if(!async_still_valid())
		return
	var/mob/living/living_pawn = controller.pawn
	living_pawn.execute_resist()
	finish_async(AI_BEHAVIOR_SUCCEEDED)
