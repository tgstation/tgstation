/**
 * Grabs (starts pulling) the atom at the given blackboard key.
 * Succeeds immediately if already pulling the target.
 * Returns INSTANT (keeps running) while not yet adjacent to the target.
 */
/datum/bt_node/ai_behavior/grab_target

/datum/bt_node/ai_behavior/grab_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/movable/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/our_mob = controller.pawn
	if(our_mob.pulling == target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(get_dist(our_mob, target) > 0)
		return AI_BEHAVIOR_INSTANT
	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[our_mob] grabbing [target]", get_turf(target), "Grab")
	our_mob.start_pulling(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
