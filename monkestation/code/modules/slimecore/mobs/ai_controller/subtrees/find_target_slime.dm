/datum/ai_planning_subtree/simple_find_target_no_trait
	var/trait = TRAIT_AI_PAUSED
	var/unique_behavior = FALSE

/datum/ai_planning_subtree/simple_find_target_no_trait/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(!unique_behavior)
		controller.queue_behavior(/datum/ai_behavior/find_potential_targets_without_trait, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, trait)


/datum/ai_planning_subtree/simple_find_target_no_trait/slime
	trait = TRAIT_LATCH_FEEDERED

/datum/ai_planning_subtree/simple_find_target_no_trait/slime/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_BASIC_MOB_STOP_FLEEING])
		return
	. = ..()

/datum/ai_planning_subtree/simple_find_target_no_trait/slime_cat
	trait = TRAIT_LATCH_FEEDERED
	unique_behavior = TRUE

/datum/ai_planning_subtree/simple_find_target_no_trait/slime/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_BASIC_MOB_STOP_FLEEING])
		return
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets_without_trait/smaller, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, trait)
