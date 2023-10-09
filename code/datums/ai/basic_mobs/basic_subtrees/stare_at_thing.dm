/// Locate a thing (practically any atom) to stop and stare at.
/datum/ai_planning_subtree/stare_at_thing

/datum/ai_planning_subtree/stare_at_thing/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/weakref/weak_target = controller.blackboard[BB_STATIONARY_CAUSE]
	var/atom/target = weak_target?.resolve()

	if(isnull(target)) // No target? Time to locate one using the list we set in this mob's blackboard.
		var/list/potential_scares = controller.blackboard[BB_STATIONARY_TARGETS]
		controller.queue_behavior(/datum/ai_behavior/find_and_set/in_list, BB_STATIONARY_CAUSE, potential_scares)
		return

	controller.queue_behavior(/datum/ai_behavior/stop_and_stare, BB_STATIONARY_CAUSE)

