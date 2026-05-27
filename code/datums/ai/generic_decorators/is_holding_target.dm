/**
 * Gates child on the pawn currently holding the item at the given blackboard key in its hands.
 * Clears the key and returns BT_FAILURE if the item has been deleted.
 * Returns BT_FAILURE without clearing the key if the item exists but is not held — the item
 * may be in a bag or on the floor and other branches may still need to locate it.
 */
/datum/bt_node/decorator/is_holding_target
	/// The blackboard key whose value is the item to check.
	var/key

/datum/bt_node/decorator/is_holding_target/check_condition(datum/ai_controller/controller)
	var/obj/item/target = controller.blackboard[key]
	var/mob/mob_pawn = controller.pawn
	if(QDELETED(target))
		controller.clear_blackboard_key(key)
		return FALSE
	return mob_pawn.is_holding(target)
