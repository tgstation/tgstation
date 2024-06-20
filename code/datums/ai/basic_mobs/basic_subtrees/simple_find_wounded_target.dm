/// Selects the most wounded potential target that we can see
/datum/ai_planning_subtree/simple_find_wounded_target

/datum/ai_planning_subtree/simple_find_wounded_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets/most_wounded, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
