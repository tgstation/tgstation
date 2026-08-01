/// Performs a named emote on the pawn (BT-native). Use for standard emote types like "flip", "wave", etc.
/datum/bt_node/ai_behavior/perform_emote
	/// Name of the emote to perform.
	var/emote
	/// Chance for this emote to happen? Defaults to 100.
	var/chance_to_proc = 100

/datum/bt_node/ai_behavior/perform_emote/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if(chance_to_proc != 100)
		if(SPT_PROB(chance_to_proc, seconds_per_tick))
			INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), emote)
	else
		INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), emote)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
