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

	controller.queue_behavior(call_type)

/// Decides when to call reinforcements, can be overridden for alternate behavior
/datum/ai_planning_subtree/call_reinforcements/proc/decide_to_call(datum/ai_controller/controller)
	return controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET) && istype(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], /mob)

/datum/ai_planning_subtree/call_reinforcements/mining
	call_type = /datum/ai_behavior/call_reinforcements/mining

/// Call out to all mobs in the specified range for help
/datum/ai_behavior/call_reinforcements
	/// How frequently can we call for reinforcements?
	var/cooldown = 30 SECONDS
	/// Range to call reinforcements from
	var/reinforcements_range = 15

/datum/ai_behavior/call_reinforcements/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/pawn_mob = controller.pawn
	for(var/mob/other_mob in oview(reinforcements_range, pawn_mob))
		if(!pawn_mob.faction_check_atom(other_mob) || isnull(other_mob.ai_controller))
			continue
		// Add our current target to their retaliate list so that they'll attack our aggressor
		other_mob.ai_controller.set_blackboard_key_assoc_lazylist(BB_BASIC_MOB_RETALIATE_LIST, controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], world.time)
		other_mob.ai_controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENT_TARGET, pawn_mob)

	controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENTS_COOLDOWN, world.time + cooldown)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Does not force retaliation, but increases targeting priority instead
/datum/ai_behavior/call_reinforcements/mining
	cooldown = 1 SECONDS
	reinforcements_range = 7

/datum/ai_behavior/call_reinforcements/mining/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/pawn_mob = controller.pawn
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	for(var/mob/other_mob in oview(reinforcements_range, pawn_mob))
		if(!pawn_mob.faction_check_atom(other_mob) || isnull(other_mob.ai_controller))
			continue
		var/list/existing_requests = other_mob.ai_controller.blackboard[BB_MINING_MOB_REINFORCEMENTS_REQUESTS]
		if (!existing_requests || !existing_requests[target])
			other_mob.ai_controller.set_blackboard_key_assoc_lazylist(BB_MINING_MOB_REINFORCEMENTS_REQUESTS, target, list())
		other_mob.ai_controller.add_blackboard_key_assoc(BB_MINING_MOB_REINFORCEMENTS_REQUESTS, target, world.time)

	controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENTS_COOLDOWN, world.time + cooldown)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
