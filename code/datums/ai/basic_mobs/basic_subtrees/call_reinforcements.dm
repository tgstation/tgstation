/// Calls all nearby mobs that share a faction to give backup in combat
/datum/ai_planning_subtree/call_reinforcements
	/// The range to pull reinforcements from
	var/reinforcement_range = 15
	/// Text to say when calling reinforcements
	var/call_say
	/// Text to emote when calling reinforcements
	var/call_emote = "cries for help!"

/datum/ai_planning_subtree/call_reinforcements/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if (controller.blackboard[BB_BASIC_REINFORCEMENTS_COOLDOWN] > world.time)
		return

	if(!isnull(call_say))
		controller.queue_behavior(/datum/ai_behavior/perform_speech, call_say)
	else
		controller.queue_behavior(/datum/ai_behavior/perform_emote, call_emote)


