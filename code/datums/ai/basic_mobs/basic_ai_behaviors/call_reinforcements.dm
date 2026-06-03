/// Emotes a reinforcement call and alerts nearby faction members, adding the current target to their retaliate lists.
/// Returns FAILURE when there is no valid target or the target is a friend. Cooldown must be handled by a cooldown decorator.
/datum/bt_node/ai_behavior/call_reinforcements
	/// How far to look for reinforcements
	var/reinforcements_range = 15

/datum/bt_node/ai_behavior/call_reinforcements/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/target = controller.blackboard[BB_CURRENT_TARGET]
	if(!istype(target, /mob))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/pawn_mob = controller.pawn
	var/list/friends = controller.blackboard[BB_FRIENDS_LIST]
	if(friends && (target in friends))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/say_text = controller.blackboard[BB_REINFORCEMENTS_SAY]
	if(!isnull(say_text))
		pawn_mob.say(say_text, forced = "AI Controller")
	else
		var/emote_text = controller.blackboard[BB_REINFORCEMENTS_EMOTE]
		if(!isnull(emote_text))
			pawn_mob.manual_emote(emote_text)

	for(var/mob/other_mob in oview(reinforcements_range, pawn_mob))
		if(!pawn_mob.faction_check_atom(other_mob) || isnull(other_mob.ai_controller))
			continue
		other_mob.ai_controller.set_blackboard_key_assoc_lazylist(BB_BASIC_MOB_RETALIATE_LIST, target, world.time)
		other_mob.ai_controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENT_TARGET, pawn_mob)

	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Mining/swarm variant: boosts priority rather than forcing retaliation, shorter range and faster cooldown.
/datum/bt_node/ai_behavior/call_reinforcements/mining
	reinforcements_range = 7

/datum/bt_node/ai_behavior/call_reinforcements/mining/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/target = controller.blackboard[BB_CURRENT_TARGET]
	if(!istype(target, /mob))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/pawn_mob = controller.pawn
	for(var/mob/other_mob in oview(reinforcements_range, pawn_mob))
		if(!pawn_mob.faction_check_atom(other_mob) || isnull(other_mob.ai_controller))
			continue
		var/list/existing_requests = other_mob.ai_controller.blackboard[BB_MINING_MOB_REINFORCEMENTS_REQUESTS]
		if(!existing_requests || !existing_requests[target])
			other_mob.ai_controller.set_blackboard_key_assoc_lazylist(BB_MINING_MOB_REINFORCEMENTS_REQUESTS, target, list())
		other_mob.ai_controller.add_blackboard_key_assoc(BB_MINING_MOB_REINFORCEMENTS_REQUESTS, target, world.time)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
