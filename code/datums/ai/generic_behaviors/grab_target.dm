/**
 * Grabs (starts pulling) the atom at the given blackboard key.
 * Succeeds immediately if already pulling the target.
 * Fails if the target is anchored
 */
/datum/bt_node/ai_behavior/grab_target
	/// Blackboard key holding the atom to grab.
	var/target_key
	/// Set while start_pulling is happening (can sleep)
	VAR_PRIVATE/is_grabbing = FALSE
	/// TRUE once the async grab has written its result.
	VAR_PRIVATE/async_grab_done = FALSE
	/// Whether start_pulling returned TRUE.
	VAR_PRIVATE/async_grab_succeeded = FALSE

/datum/bt_node/ai_behavior/grab_target/perform(seconds_per_tick, datum/ai_controller/controller)
	if(is_grabbing)
		return AI_BEHAVIOR_DELAY

	if(async_grab_done)
		return AI_BEHAVIOR_DELAY | (async_grab_succeeded ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

	var/atom/movable/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.anchored)
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[controller.pawn] grab_target: can't grab [target] (deleted=[QDELETED(target)], anchored=[target?.anchored])")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/our_mob = controller.pawn
	if(our_mob.pulling == target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	is_grabbing = TRUE
	INVOKE_ASYNC(src, PROC_REF(async_grab), controller, our_mob, target)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/grab_target/proc/async_grab(datum/ai_controller/controller, mob/living/our_mob, atom/movable/target)
	var/result = our_mob.start_pulling(target)
	if(!is_grabbing || QDELETED(our_mob))
		return
	if(result)
		EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_BEHAVIORS, "[our_mob] grabbing [target]", get_turf(target), "Grab")
	async_grab_succeeded = result
	async_grab_done = TRUE
	is_grabbing = FALSE

/datum/bt_node/ai_behavior/grab_target/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	is_grabbing = FALSE
	async_grab_done = FALSE
	async_grab_succeeded = FALSE
