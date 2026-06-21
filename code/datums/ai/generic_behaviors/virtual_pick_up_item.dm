/// Moves the item at target_key onto the pawn and records it in storage_key. Does not use hands — storage_key is the virtual carry slot. Clears target_key on finish.
/datum/bt_node/ai_behavior/pick_up_item_virtual
	/// Blackboard key holding the item to pick up.
	var/target_key
	/// Blackboard key acting as the virtual carry slot.
	var/storage_key

/datum/bt_node/ai_behavior/pick_up_item_virtual/setup(datum/ai_controller/controller)
	var/obj/item/target = controller.blackboard[target_key]
	return isitem(target) && isturf(target.loc) && !target.anchored

/datum/bt_node/ai_behavior/pick_up_item_virtual/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/item/target = controller.blackboard[target_key]
	if(QDELETED(target) || !isturf(target.loc))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!controller.pawn.Adjacent(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	_pickup(controller, target, storage_key)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/pick_up_item_virtual/finish_action(datum/ai_controller/controller, succeeded)
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
	/// Blackboard key holding the recipient to deliver to.
	var/delivery_key
	/// Blackboard key holding the virtually-carried item.
	var/storage_key

/datum/bt_node/ai_behavior/pass_item_virtual/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[delivery_key]
	return !QDELETED(target)

/datum/bt_node/ai_behavior/pass_item_virtual/perform(seconds_per_tick, datum/ai_controller/controller)
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
