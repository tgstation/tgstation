/**
 * Grabs (starts pulling) the atom at the given blackboard key.
 * Succeeds immediately if already pulling the target.
 * Fails if the target is anchored
 */
/datum/bt_node/ai_behavior/grab_target
	/// Blackboard key holding the atom to grab.
	var/target_key

/datum/bt_node/ai_behavior/grab_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/movable/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.anchored)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] grab_target: can't grab [target] (deleted=[QDELETED(target)], anchored=[target?.anchored])")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/our_mob = controller.pawn
	if(our_mob.pulling == target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(!our_mob.start_pulling(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[our_mob] grabbing [target]", get_turf(target), "Grab")
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
