/**
 * BT-native drag behavior. Moves to the target and starts pulling it.
 * If already pulling the target, returns SUCCESS immediately (idempotent).
 * Does NOT clear the target key on finish  callers must clear it when done.
 * Use move_to_target after this to drag the pulled mob/item to a destination.
 */
/datum/bt_node/ai_behavior/drag_target
	/// Blackboard key holding the atom to drag.
	var/target_key

/datum/bt_node/ai_behavior/drag_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/our_mob = controller.pawn
	var/atom/movable/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.anchored || target.pulledby)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(our_mob.pulling == target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(!our_mob.Adjacent(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	INVOKE_ASYNC(our_mob, TYPE_PROC_REF(/atom/movable, start_pulling), target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
