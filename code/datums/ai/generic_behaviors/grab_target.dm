/**
 * Grabs (starts pulling) the atom at the given blackboard key.
 * Succeeds immediately if already pulling the target.
 * Fails if the target is anchored
 */
/datum/bt_node/ai_behavior/grab_target
	/// Blackboard key holding the atom to grab.
	var/target_key

/datum/bt_node/ai_behavior/grab_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags

	var/atom/movable/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.anchored)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] grab_target: can't grab [target] (deleted=[QDELETED(target)], anchored=[target?.anchored])")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/our_mob = controller.pawn
	if(our_mob.pulling == target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return start_async()

/datum/bt_node/ai_behavior/grab_target/perform_async(datum/ai_controller/controller)
	var/mob/living/our_mob = controller.pawn
	var/atom/movable/target = controller.blackboard[target_key]
	var/result = our_mob.start_pulling(target)
	if(!async_still_valid())
		return
	if(result)
		EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[our_mob] grabbing [target]", get_turf(target), "Grab")
	finish_async(result ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)
