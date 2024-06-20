/// Find someone we don't like and annoy them
/datum/ai_planning_subtree/dog_harassment

/datum/ai_planning_subtree/dog_harassment/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!SPT_PROB(10, seconds_per_tick))
		return
	controller.queue_behavior(/datum/ai_behavior/find_hated_dog_target, BB_DOG_HARASS_TARGET, BB_PET_TARGETING_STRATEGY)
	var/atom/harass_target = controller.blackboard[BB_DOG_HARASS_TARGET]
	if (isnull(harass_target))
		return

	controller.queue_behavior(/datum/ai_behavior/basic_melee_attack/dog, BB_DOG_HARASS_TARGET, BB_PET_TARGETING_STRATEGY)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/find_hated_dog_target

/datum/ai_behavior/find_hated_dog_target/setup(datum/ai_controller/controller, target_key, targeting_strategy_key)
	. = ..()
	var/mob/living/dog = controller.pawn
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	for(var/mob/living/iter_living in oview(2, dog))
		if(iter_living.stat != CONSCIOUS || !HAS_TRAIT(iter_living, TRAIT_HATED_BY_DOGS))
			continue
		if(!isnull(dog.buckled))
			dog.audible_message(span_notice("[dog] growls at [iter_living], yet [dog.p_they()] [dog.p_are()] much too comfy to move."), hearing_distance = COMBAT_MESSAGE_RANGE)
			continue
		if(!targeting_strategy.can_attack(dog, iter_living))
			continue

		dog.audible_message(span_warning("[dog] growls at [iter_living], seemingly annoyed by [iter_living.p_their()] presence."), hearing_distance = COMBAT_MESSAGE_RANGE)
		controller.set_blackboard_key(target_key, iter_living)
		controller.set_blackboard_key(BB_DOG_HARASS_HARM, FALSE)
		return TRUE

	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/find_hated_dog_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
