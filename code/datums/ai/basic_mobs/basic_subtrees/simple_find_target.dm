/datum/ai_planning_subtree/simple_find_target
	/// Blackboard key for where the target ref is stored
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// Blackboard key for where an object the target is hiding in is stored
	var/hiding_target_key = BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION
	/// Blackboard key for where to find targeting behaviour
	var/targetting_key = BB_TARGETTING_DATUM

/datum/ai_planning_subtree/simple_find_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(!QDELETED(target))
		return
	controller.queue_behavior(/datum/ai_behavior/find_potential_targets, target_key, targetting_key, hiding_target_key)
