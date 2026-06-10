/// Interacts with the atom at target_key once, with optional combat_mode (default FALSE).
/datum/bt_node/ai_behavior/ai_interact
	/// Blackboard key holding the atom to interact with.
	var/target_key
	/// Whether to interact in combat mode.
	var/combat_mode = FALSE

/datum/bt_node/ai_behavior/ai_interact/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	return !QDELETED(target)

/datum/bt_node/ai_behavior/ai_interact/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.ai_interact(target, combat_mode)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
