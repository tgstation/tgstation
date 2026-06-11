/**
 * Gates child on the item at the given blackboard key being located anywhere inside the pawn
 * (recursive contents check via locate()). Clears the key and returns FALSE if the item is deleted.
 * Does NOT clear the key if the item simply isn't inside the pawn — other branches may still use it.
 */
/datum/bt_node/decorator/item_inside_pawn
	/// Blackboard key holding the item to check.
	var/key = null
	/// The item currently being observed for location changes.
	var/obj/item/observed_item = null

/datum/bt_node/decorator/item_inside_pawn/register_observe_signals(atom/pawn)
	var/obj/item/target = owning_controller?.blackboard[key]
	if(target)
		observed_item = target
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_signal_changed))
	RegisterSignals(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)), PROC_REF(on_item_key_changed))
	return TRUE

/datum/bt_node/decorator/item_inside_pawn/unregister_observe_signals(atom/pawn)
	if(observed_item)
		UnregisterSignal(observed_item, COMSIG_MOVABLE_MOVED)
		observed_item = null
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)))

/// Fires when the blackboard key changes. Rebinds the move observer to the new item and re-evaluates.
/datum/bt_node/decorator/item_inside_pawn/proc/on_item_key_changed(atom/source, ...)
	SIGNAL_HANDLER
	if(observed_item)
		UnregisterSignal(observed_item, COMSIG_MOVABLE_MOVED)
		observed_item = null
	var/obj/item/target = owning_controller?.blackboard[key]
	if(target)
		observed_item = target
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_signal_changed))
	if(owning_controller)
		on_observed_change(owning_controller, null)

/datum/bt_node/decorator/item_inside_pawn/check_condition(datum/ai_controller/controller)
	var/obj/item/target = controller.blackboard[key]
	if(QDELETED(target))
		controller.clear_blackboard_key(key)
		return FALSE
	return !isnull(locate(target) in controller.pawn)
