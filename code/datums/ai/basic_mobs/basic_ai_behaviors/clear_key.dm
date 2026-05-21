/// Clears a blackboard key (or keys), simply if you want to do this after an action without making a subtype
/datum/ai_behavior/clear_key

/datum/ai_behavior/clear_key/perform(seconds_per_tick, datum/ai_controller/controller, list/to_clear)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/clear_key/finish_action(datum/ai_controller/controller, succeeded, list/to_clear)
	. = ..()
	if (!to_clear)
		return
	if (!islist(to_clear))
		to_clear = list(to_clear)
	for (var/key in to_clear)
		controller.clear_blackboard_key(key)
