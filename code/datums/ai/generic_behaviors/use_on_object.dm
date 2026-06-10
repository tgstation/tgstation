/// Uses the pawn's held item (or unarmed) on a blackboard-keyed target.
/datum/bt_node/ai_behavior/use_on_object
	/// Blackboard key holding the atom to use the held item on.
	var/target_key

/datum/bt_node/ai_behavior/use_on_object/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.ai_interact(target = target, combat_mode = FALSE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
