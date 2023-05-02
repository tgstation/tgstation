///used by cows
/datum/ai_planning_subtree/tip_reaction

/datum/ai_planning_subtree/tip_reaction/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/tip_reacting = controller.blackboard[BB_BASIC_MOB_TIP_REACTING]
	if(!tip_reacting)
		return
	controller.queue_behavior(/datum/ai_behavior/tipped_reaction, BB_BASIC_MOB_TIPPER, BB_BASIC_MOB_TIP_REACTING)
	return SUBTREE_RETURN_FINISH_PLANNING //no point in trying, boy. you're TIPPED.
