/// Try to escape from your current target, without performing any other actions.
/datum/ai_planning_subtree/flee_target

/datum/ai_planning_subtree/flee_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if (!controller.blackboard[BB_BASIC_MOB_FLEEING])
		return
	if (!controller.blackboard[BB_BASIC_MOB_STOP_FLEE_AT_HP_RATIO])
		return
	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/atom/target = weak_target?.resolve()
	if(!target || QDELETED(target))
		return
	controller.queue_behavior(/datum/ai_behavior/run_away_from_target/while_unhealthy, BB_BASIC_MOB_CURRENT_TARGET, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION, BB_BASIC_MOB_STOP_FLEE_AT_HP_RATIO)
	return SUBTREE_RETURN_FINISH_PLANNING //we gotta get out of here.
