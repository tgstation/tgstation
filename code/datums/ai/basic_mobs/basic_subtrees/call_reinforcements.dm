#define REINFORCEMENTS_COOLDOWN (30 SECONDS)

/// Calls all nearby mobs that share a faction to give backup in combat
/datum/ai_planning_subtree/call_reinforcements
	/// Blackboard key containing something to say when calling reinforcements (takes precedence over emotes)
	var/say_key = BB_REINFORCEMENTS_SAY
	/// Blackboard key containing an emote to perform when calling reinforcements
	var/emote_key = BB_REINFORCEMENTS_EMOTE
	/// Reinforcement-calling behavior to use
	var/call_type = /datum/ai_behavior/call_reinforcements

/datum/ai_planning_subtree/call_reinforcements/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if (!decide_to_call(controller) || controller.blackboard[BB_BASIC_MOB_REINFORCEMENTS_COOLDOWN] > world.time)
		return

	var/call_say = controller.blackboard[BB_REINFORCEMENTS_SAY]
	var/call_emote = controller.blackboard[BB_REINFORCEMENTS_EMOTE]

	if(!isnull(call_say))
		controller.queue_behavior(/datum/ai_behavior/perform_speech, call_say)
	else if(!isnull(call_emote))
		controller.queue_behavior(/datum/ai_behavior/perform_emote, call_emote)
	else
		controller.queue_behavior(/datum/ai_behavior/perform_emote, "cries for help!")

	controller.queue_behavior(call_type)

/// Decides when to call reinforcements, can be overridden for alternate behavior
/datum/ai_planning_subtree/call_reinforcements/proc/decide_to_call(datum/ai_controller/controller)
	return controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET) && istype(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], /mob)

/// Call out to all mobs in the specified range for help
/datum/ai_behavior/call_reinforcements
	/// Range to call reinforcements from
	var/reinforcements_range = 15

/datum/ai_behavior/call_reinforcements/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/pawn_mob = controller.pawn
	for(var/mob/other_mob in oview(reinforcements_range, pawn_mob))
		if(pawn_mob.faction_check_atom(other_mob) && !isnull(other_mob.ai_controller))
			// Add our current target to their retaliate list so that they'll attack our aggressor
			other_mob.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
			other_mob.ai_controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENT_TARGET, pawn_mob)

	controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENTS_COOLDOWN, world.time + REINFORCEMENTS_COOLDOWN)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

#undef REINFORCEMENTS_COOLDOWN
