/datum/ai_planning_subtree/simple_find_target
	/// Variable to store target in
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/simple_find_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets, target_key, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

// Prevents finding a target if a human is nearby
/datum/ai_planning_subtree/simple_find_target/not_while_observed

/datum/ai_planning_subtree/simple_find_target/not_while_observed/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	for(var/mob/living/carbon/human/watcher in hearers(7, controller.pawn))
		if(watcher.stat != DEAD)
			return
	return ..()

/datum/ai_planning_subtree/simple_find_target/to_flee
	target_key = BB_BASIC_MOB_FLEE_TARGET
