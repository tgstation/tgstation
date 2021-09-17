///generic behavior to run away from your target, instead of attacking them.
/datum/ai_planning_subtree/run_away
	var/list/visible_message = list(
		"dashes away!",
		"is frightened!",
		"looks spooked!",
		"sprints away in fear!"
	)

/datum/ai_planning_subtree/run_away/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target || QDELETED(target))
		return
	controller.queue_behavior(/datum/ai_behavior/run_away, BB_BASIC_MOB_CURRENT_TARGET, pick(visible_message))
	return SUBTREE_RETURN_FINISH_PLANNING //more important to run than to do anything else
