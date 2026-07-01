/datum/bt_node/ai_behavior/retrieve_injured_rider
	///where do we save our target
	var/target_key

/datum/bt_node/ai_behavior/retrieve_injured_rider/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_mob = controller.pawn
	if (!length(living_mob.buckled_mobs) || !isliving(living_mob.buckled_mobs[1]))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/rider = living_mob.buckled_mobs[1]
	if (rider.stat == CONSCIOUS || rider.stat == DEAD || rider.health >= rider.maxHealth)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(target_key, rider)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
