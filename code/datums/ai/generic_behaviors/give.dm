/// gives the pawn's active held item to a blackboard-keyed target.
/datum/bt_node/ai_behavior/give
	/// Blackboard key holding the mob to give the held item to.
	var/target_key
	/// Target snapshotted in perform(), for perform_async() to read.
	VAR_PRIVATE/mob/living/give_target
	/// Held item snapshotted in perform(), for perform_async() to read.
	VAR_PRIVATE/obj/item/give_held_item

/datum/bt_node/ai_behavior/give/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags

	var/mob/living/pawn = controller.pawn
	var/obj/item/held_item = pawn.get_active_held_item()
	var/atom/target = controller.blackboard[target_key]

	if(!held_item) //if held_item is null, we pretend that action was successful
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	if(QDELETED(target) || !target.IsReachableBy(pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/living_target = target
	if(!isliving(living_target)) // target should reasonably only ever be set to a living mob
		stack_trace("Tried to give an item to a non-living target!")
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(!can_give_item(living_target, held_item))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	living_target.visible_message(
		span_info("[pawn] starts trying to give [held_item] to [living_target]!"),
		span_warning("[pawn] tries to give you [held_item]!")
	)
	give_target = living_target
	give_held_item = held_item
	return start_async()

/datum/bt_node/ai_behavior/give/perform_async(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	var/mob/living/living_target = give_target
	var/obj/item/held_item = give_held_item
	var/result_flags = AI_BEHAVIOR_FAILED
	if(do_after(pawn, 1 SECONDS, living_target))
		result_flags = try_to_give_item(living_target, held_item)
	finish_async(result_flags)

/// Returns a list(has_left_pocket, has_right_pocket, has_valid_hand) if the item can be given, null otherwise.
/datum/bt_node/ai_behavior/give/proc/can_give_item(mob/living/target, obj/item/held_item)
	if(QDELETED(held_item) || QDELETED(target))
		return null

	var/has_left_pocket = target.can_equip(held_item, ITEM_SLOT_LPOCKET)
	var/has_right_pocket = target.can_equip(held_item, ITEM_SLOT_RPOCKET)
	var/has_valid_hand

	for(var/hand_index in target.get_empty_held_indexes())
		if(target.can_put_in_hand(held_item, hand_index))
			has_valid_hand = TRUE
			break

	if(!has_left_pocket && !has_right_pocket && !has_valid_hand)
		return null

	return list(has_left_pocket, has_right_pocket, has_valid_hand)

/datum/bt_node/ai_behavior/give/proc/try_to_give_item(mob/living/target, obj/item/held_item)
	var/list/give_slots = can_give_item(target, held_item)
	if(!give_slots)
		return AI_BEHAVIOR_FAILED

	var/has_left_pocket = give_slots[1]
	var/has_valid_hand = give_slots[3]

	if(!has_valid_hand || prob(50))
		target.equip_to_slot_if_possible(held_item, (!has_left_pocket ? ITEM_SLOT_RPOCKET : (prob(50) ? ITEM_SLOT_LPOCKET : ITEM_SLOT_RPOCKET)))
	else
		INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, put_in_hands), held_item)
	return AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/give/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	give_target = null
	give_held_item = null
	controller.clear_blackboard_key(target_key)
