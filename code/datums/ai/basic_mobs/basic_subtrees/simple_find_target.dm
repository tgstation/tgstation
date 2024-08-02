/datum/ai_planning_subtree/simple_find_target

/datum/ai_planning_subtree/simple_find_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

// Prevents finding a target if a human is nearby
/datum/ai_planning_subtree/simple_find_target/not_while_observed

/datum/ai_planning_subtree/simple_find_target/not_while_observed/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	for(var/mob/living/carbon/human/watcher in hearers(7, controller.pawn))
		if(watcher.stat != DEAD)
			return
	return ..()
