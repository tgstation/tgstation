/// Find something with a specific trait to run from
/datum/ai_planning_subtree/find_target_prioritize_traits

/datum/ai_planning_subtree/find_target_prioritize_traits/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets/prioritize_trait, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, BB_TARGET_PRIORITY_TRAIT)
