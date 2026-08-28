/// Wander between water and land, splashing about now and then.
/datum/bt_node/subtree/go_for_swim
	behavior_tree_json = "code/datums/ai/basic_mobs/basic_subtrees/go_for_swim.bt.json"

/// Splashes about while standing in water.
/datum/bt_node/ai_behavior/swim_splash

/datum/bt_node/ai_behavior/swim_splash/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!istype(living_pawn) || !iswaterturf(get_turf(living_pawn)))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(!SPT_PROB(5, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	living_pawn.manual_emote("splashes water all around!")
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
