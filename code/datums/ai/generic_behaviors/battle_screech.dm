/// Emotes a random screech from a list of screeches defined on the subtype.
/datum/bt_node/ai_behavior/battle_screech
	/// List of possible screeches the behavior has
	var/list/screeches

/datum/bt_node/ai_behavior/battle_screech/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), pick(screeches))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

