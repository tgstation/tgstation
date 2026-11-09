/datum/bt_node/ai_behavior/run_emote
	/// Blackboard key holding the emote (or list of emotes) to perform.
	var/emote_key = BB_EMOTE_KEY

/datum/bt_node/ai_behavior/run_emote/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!isliving(living_pawn))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/list/emote_list = controller.blackboard[emote_key]
	var/emote
	if(islist(emote_list))
		emote = length(emote_list) ? pick(emote_list) : null
	else
		emote = emote_list

	if(isnull(emote))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), emote)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
