/**
 * Simple behaviour for picking up an item we are already in range of.
 * The blackboard storage key isn't very safe because it doesn't make sense to register signals in here.
 * Before interacting with it, make sure it's still in the mob and something else hasn't moved it.
 */
/datum/ai_behavior/pick_up_item
	/// Blackboard key for tracking this held item
	var/storage_key = BB_SIMPLE_CARRY_ITEM

/datum/ai_behavior/pick_up_item/perform(delta_time, datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/item/target = controller.blackboard[target_key]
	if(!isturf(target?.loc) || !isitem(target)) // Someone picked it up, something happened to it, or it wasn't an item anyway
		finish_action(controller, FALSE, target_key)
		return

	if(in_range(controller.pawn, target))
		pickup_item(controller, target)
		finish_action(controller, TRUE, target_key)
	else
		finish_action(controller, FALSE, target_key)

/datum/ai_behavior/pick_up_item/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.blackboard[target_key] = null

/datum/ai_behavior/pick_up_item/proc/pickup_item(datum/ai_controller/controller, obj/item/target)
	var/atom/pawn = controller.pawn
	drop_existing_item(controller)
	pawn.visible_message(span_notice("[pawn] picks up [target]."))
	target.forceMove(pawn)
	controller.blackboard[storage_key] = WEAKREF(target)
	return TRUE

/datum/ai_behavior/pick_up_item/proc/drop_existing_item(datum/ai_controller/controller)
	var/datum/weakref/carried_ref = controller.blackboard[storage_key]
	var/obj/item/carried_item = carried_ref?.resolve()
	if(!carried_item)
		return
	controller.blackboard[storage_key] = null
	var/atom/pawn = controller.pawn
	if(carried_item.loc !== pawn)
		return
	pawn.visible_message(span_notice("[pawn] drops [carried_item]."))
	carried_item.forceMove(get_turf(pawn))
	return TRUE
