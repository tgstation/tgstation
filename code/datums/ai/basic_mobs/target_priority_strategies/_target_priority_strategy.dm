/// Target priority datum, exists to allow mobs to have custom targeting priorities. Singleton.
/datum/target_priority_strategy

/// Returns a number representing the priority of a target, higher -> more likely to attack
/datum/target_priority_strategy/proc/get_target_priority(datum/ai_controller/controller, atom/target)
	return 1

/// Returns a single atom from the list of passed targets
/datum/target_priority_strategy/proc/select_target(datum/ai_controller/controller, list/atom/targets)
	var/list/target_priorities = list()
	for (var/atom/target as anything in targets)
		target_priorities[target] = get_target_priority(controller, target)
	return pick_weight(target_priorities)
