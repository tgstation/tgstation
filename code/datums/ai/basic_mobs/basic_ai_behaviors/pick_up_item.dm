/**
 * Simple behaviour for picking up an item we are already in range of.
 * The blackboard storage key isn't very safe because it doesn't make sense to register signals in here.
 * Use the AI held item component to manage this.
 */
/datum/ai_behavior/pick_up_item

/datum/ai_behavior/pick_up_item/setup(datum/ai_controller/controller, target_key, storage_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/obj/item/target = weak_target?.resolve()
	return isitem(target) && isturf(target.loc) && !target.anchored

/datum/ai_behavior/pick_up_item/perform(delta_time, datum/ai_controller/controller, target_key, storage_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/obj/item/target = weak_target?.resolve()
	if(!isturf(target?.loc)) // Someone picked it up or it got deleted
		finish_action(controller, FALSE, target_key)
		return
	if(!in_range(controller.pawn, target)) // It teleported
		finish_action(controller, FALSE, target_key)
		return
	pickup_item(controller, target, storage_key)
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/pick_up_item/finish_action(datum/ai_controller/controller, success, target_key, storage_key)
	. = ..()
	controller.blackboard[target_key] = null

/datum/ai_behavior/pick_up_item/proc/pickup_item(datum/ai_controller/controller, obj/item/target, storage_key)
	var/atom/pawn = controller.pawn
	drop_existing_item(controller, storage_key)
	pawn.visible_message(span_notice("[pawn] picks up [target]."))
	target.forceMove(pawn)
	controller.blackboard[storage_key] = WEAKREF(target)
	return TRUE

/datum/ai_behavior/pick_up_item/proc/drop_existing_item(datum/ai_controller/controller, storage_key)
	var/datum/weakref/carried_ref = controller.blackboard[storage_key]
	var/obj/item/carried_item = carried_ref?.resolve()
	if(!carried_item)
		return
	controller.blackboard[storage_key] = null
	var/atom/pawn = controller.pawn
	if(carried_item.loc != pawn)
		return
	pawn.visible_message(span_notice("[pawn] drops [carried_item]."))
	carried_item.forceMove(get_turf(pawn))
	return TRUE
