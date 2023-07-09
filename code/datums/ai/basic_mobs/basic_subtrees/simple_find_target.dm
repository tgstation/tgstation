/datum/ai_planning_subtree/simple_find_target

/datum/ai_planning_subtree/simple_find_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

// Prevents finding a target if a human is nearby
/datum/ai_planning_subtree/simple_find_target/not_while_observed

/datum/ai_planning_subtree/simple_find_target/not_while_observed/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/list/nearby_mobs = hearers(7, controller.pawn)
	for(var/mob/watcher in nearby_mobs)
		if(istype(watcher, /mob/living/carbon/human) && watcher.stat != DEAD)
			return
	return ..()

