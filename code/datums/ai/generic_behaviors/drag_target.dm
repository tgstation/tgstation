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

/**
 * Steals a target item by pulling it from the ground, or by interruptibly snatching it
 * from a nearby mob's hands or ID slot before starting to pull it.
 */
/datum/bt_node/ai_behavior/steal_target
	/// Blackboard key holding the item to steal.
	var/target_key
	/// Time spent visibly trying to snatch an item from another mob.
	var/snatch_time = 1 SECONDS

/datum/bt_node/ai_behavior/steal_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags

	var/mob/living/thief = controller.pawn
	var/obj/item/target = controller.blackboard[target_key]
	if(QDELETED(target) || target.anchored || target.pulledby)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(thief.pulling == target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(isturf(target.loc))
		if(!thief.Adjacent(target))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
		INVOKE_ASYNC(thief, TYPE_PROC_REF(/atom/movable, start_pulling), target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	if(!is_accessible_carried_target(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	return start_async()

/datum/bt_node/ai_behavior/steal_target/perform_async(datum/ai_controller/controller)
	var/mob/living/thief = controller.pawn
	var/obj/item/target = controller.blackboard[target_key]
	var/mob/living/victim = target?.loc
	if(!istype(victim) || !thief.Adjacent(victim) || !is_accessible_carried_target(target))
		finish_async(AI_BEHAVIOR_FAILED)
		return

	victim.visible_message(
		span_warning("[thief] starts trying to take [target] from [victim]!"),
		span_danger("[thief] tries to take [target]!"),
	)
	if(!do_after(thief, snatch_time, target = victim))
		if(async_still_valid())
			finish_async(AI_BEHAVIOR_FAILED)
		return
	if(!async_still_valid())
		return
	if(target?.loc != victim || !thief.Adjacent(victim) || !is_accessible_carried_target(target))
		finish_async(AI_BEHAVIOR_FAILED)
		return
	if(!victim.temporarilyRemoveItemFromInventory(target))
		finish_async(AI_BEHAVIOR_FAILED)
		return

	target.forceMove(thief.drop_location())
	if(!thief.start_pulling(target, supress_message = TRUE))
		finish_async(AI_BEHAVIOR_FAILED)
		return
	victim.visible_message(
		span_warning("[thief] snatches [target] from [victim]!"),
		span_userdanger("[thief] snatched [target]!"),
	)
	finish_async(AI_BEHAVIOR_SUCCEEDED)

/datum/bt_node/ai_behavior/steal_target/proc/is_accessible_carried_target(obj/item/target)
	var/mob/living/victim = target?.loc
	if(!istype(victim))
		return FALSE
	if(target in victim.held_items)
		return TRUE
	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		return human_victim.wear_id == target
	return FALSE
