/datum/ai_planning_subtree/simple_find_target
	var/datum/ai_behavior/search_behavior = /datum/ai_behavior/find_potential_targets

/datum/ai_planning_subtree/simple_find_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(target && !QDELETED(target))
		return
	controller.queue_behavior(search_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

/datum/ai_planning_subtree/simple_find_target/close
	search_behavior = /datum/ai_behavior/find_potential_targets/too_close
