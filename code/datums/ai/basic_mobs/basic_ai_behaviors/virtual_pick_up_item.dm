/// Moves the item at target_key onto the pawn and records it in storage_key. Does not use hands — storage_key is the virtual carry slot. Clears target_key on finish.
/datum/bt_node/ai_behavior/pick_up_item_virtual

/datum/bt_node/ai_behavior/pick_up_item_virtual/setup(datum/ai_controller/controller, target_key, storage_key)
	var/obj/item/target = controller.blackboard[target_key]
	return isitem(target) && isturf(target.loc) && !target.anchored

/datum/bt_node/ai_behavior/pick_up_item_virtual/perform(seconds_per_tick, datum/ai_controller/controller, target_key, storage_key)
	var/obj/item/target = controller.blackboard[target_key]
	if(QDELETED(target) || !isturf(target.loc))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!controller.pawn.Adjacent(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	_pickup(controller, target, storage_key)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/pick_up_item_virtual/finish_action(datum/ai_controller/controller, succeeded, target_key, storage_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/bt_node/ai_behavior/pick_up_item_virtual/proc/_pickup(datum/ai_controller/controller, obj/item/target, storage_key)
	var/atom/pawn = controller.pawn
	var/obj/item/held = controller.blackboard[storage_key]
	if(held?.loc == pawn)
		pawn.visible_message(span_notice("[pawn] drops [held]."))
		held.forceMove(get_turf(pawn))
		controller.clear_blackboard_key(storage_key)
	pawn.visible_message(span_notice("[pawn] picks up [target]."))
	target.forceMove(pawn)
	controller.set_blackboard_key(storage_key, target)

/// Passes the item at storage_key to whoever is at delivery_key (must already be adjacent).
/datum/bt_node/ai_behavior/pass_item_virtual

/datum/bt_node/ai_behavior/pass_item_virtual/setup(datum/ai_controller/controller, delivery_key, storage_key)
	return !QDELETED(controller.blackboard[delivery_key])

/datum/bt_node/ai_behavior/pass_item_virtual/perform(seconds_per_tick, datum/ai_controller/controller, delivery_key, storage_key)
	var/atom/target = controller.blackboard[delivery_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/pawn = controller.pawn
	var/obj/item/item = controller.blackboard[storage_key]
	if(QDELETED(item) || item.loc != pawn)
		pawn.visible_message(span_notice("[pawn] looks around as if [pawn.p_they()] [pawn.p_have()] lost something."))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	pawn.visible_message(span_notice("[pawn] delivers [item] to [target]."))
	item.forceMove(get_turf(target))
	controller.clear_blackboard_key(storage_key)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

// =============================================================================
// Legacy planning types
// =============================================================================

/**
 * Simple behaviour for picking up an item we are already in range of.
 * The blackboard storage key isn't very safe because it doesn't make sense to register signals in here.
 * Use the AI held item component to manage this.
 */
/datum/ai_behavior/pick_up_item

/datum/ai_behavior/pick_up_item/setup(datum/ai_controller/controller, target_key, storage_key)
	. = ..()
	var/obj/item/target = controller.blackboard[target_key]
	return isitem(target) && isturf(target.loc) && !target.anchored

/datum/ai_behavior/pick_up_item/perform(seconds_per_tick, datum/ai_controller/controller, target_key, storage_key)
	var/obj/item/target = controller.blackboard[target_key]
	if(QDELETED(target) || !isturf(target.loc)) // Someone picked it up or it got deleted
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!controller.pawn.Adjacent(target)) // It teleported
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	pickup_item(controller, target, storage_key)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/pick_up_item/finish_action(datum/ai_controller/controller, success, target_key, storage_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/pick_up_item/proc/pickup_item(datum/ai_controller/controller, obj/item/target, storage_key)
	var/atom/pawn = controller.pawn
	drop_existing_item(controller, storage_key)
	pawn.visible_message(span_notice("[pawn] picks up [target]."))
	target.forceMove(pawn)
	controller.set_blackboard_key(storage_key, target)
	return TRUE

/datum/ai_behavior/pick_up_item/proc/drop_existing_item(datum/ai_controller/controller, storage_key)
	var/obj/item/carried_item = controller.blackboard[storage_key]
	if(!carried_item)
		return
	controller.clear_blackboard_key(storage_key)
	var/atom/pawn = controller.pawn
	if(carried_item.loc != pawn)
		return
	pawn.visible_message(span_notice("[pawn] drops [carried_item]."))
	carried_item.forceMove(get_turf(pawn))
	return TRUE
