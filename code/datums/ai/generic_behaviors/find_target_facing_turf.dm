/// Finds the turf directly in front of the keyed target (the tile it is facing) and stores it,
/// so we can line up an action on its front. Fails if the turf is missing or blocked.
/datum/bt_node/ai_behavior/find_target_facing_turf
	/// Blackboard key holding the target we want to line up against.
	var/target_key
	/// Blackboard key to write the found turf into.
	var/set_key

/datum/bt_node/ai_behavior/find_target_facing_turf/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/turf/facing_turf = get_step(target, target.dir)
	if(isnull(facing_turf) || facing_turf.is_blocked_turf(ignore_atoms = list(controller.pawn)))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(set_key, facing_turf)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
