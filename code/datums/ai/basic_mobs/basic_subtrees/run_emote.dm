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
		finish_action(controller, FALSE)
		return

	var/list/emote_list = controller.blackboard[emote_key]
	var/emote
	if (islist(emote_list))
		emote = length(emote_list) ? pick(emote_list) : null
	else
		emote = emote_list

	if(isnull(emote))
		finish_action(controller, FALSE)
		return

	living_pawn.emote(emote)
	finish_action(controller, TRUE)
