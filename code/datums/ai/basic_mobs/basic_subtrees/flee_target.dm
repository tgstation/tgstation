/// Try to escape from your current target, without performing any other actions.
/datum/ai_planning_subtree/flee_target
	/// Behaviour to execute in order to flee
	var/flee_behaviour = /datum/ai_behavior/run_away_from_target

/datum/ai_planning_subtree/flee_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if (!controller.blackboard[BB_BASIC_MOB_FLEEING])
		return
	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/atom/target = weak_target?.resolve()
	if(!target || QDELETED(target))
		return
	controller.queue_behavior(flee_behaviour, BB_BASIC_MOB_CURRENT_TARGET, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	return SUBTREE_RETURN_FINISH_PLANNING //we gotta get out of here.
