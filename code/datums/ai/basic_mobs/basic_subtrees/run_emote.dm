/// Intermittently run an emote
/datum/ai_planning_subtree/run_emote
	var/emote_key = BB_EMOTE_KEY
	var/emote_chance_key = BB_EMOTE_CHANCE

/datum/ai_planning_subtree/run_emote/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/emote_chance = controller.blackboard[emote_chance_key] || 0
	if (!SPT_PROB(emote_chance, seconds_per_tick))
		return
	controller.queue_behavior(/datum/ai_behavior/run_emote, emote_key)

/// Emote from a blackboard key
/datum/ai_behavior/run_emote

/datum/ai_behavior/run_emote/perform(seconds_per_tick, datum/ai_controller/controller, emote_key)
	var/mob/living/living_pawn = controller.pawn
	if (!isliving(living_pawn))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/list/emote_list = controller.blackboard[emote_key]
	var/emote
	if (islist(emote_list))
		emote = length(emote_list) ? pick(emote_list) : null
	else
		emote = emote_list

	if(isnull(emote))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	living_pawn.emote(emote)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Performs an emote read from a blackboard key (a single emote key, or a list to pick from).
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

	living_pawn.emote(emote)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
