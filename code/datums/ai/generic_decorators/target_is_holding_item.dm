/// Gates child on the mob held in a blackboard key currently holding any item in their hands.
/// Use "invert": true to gate on the target holding nothing.
/datum/bt_node/decorator/target_is_holding_item
	/// Blackboard key holding the mob to check.
	var/key = BB_CURRENT_TARGET
	/// Tracked so we can rebind signals when the key changes.
	var/mob/observed_target = null

/datum/bt_node/decorator/target_is_holding_item/register_observe_signals(atom/pawn)
	var/mob/target = owning_controller?.blackboard[key]
	if(ismob(target))
		observed_target = target
		RegisterSignals(target, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM), PROC_REF(on_signal_changed), override = TRUE)
	RegisterSignals(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)), PROC_REF(on_target_key_changed))
	return TRUE

/datum/bt_node/decorator/target_is_holding_item/unregister_observe_signals(atom/pawn)
	if(observed_target)
		UnregisterSignal(observed_target, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM))
		observed_target = null
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)))

/// Fires when the blackboard key changes. Rebinds equip signals to the new target and re-evaluates.
/datum/bt_node/decorator/target_is_holding_item/proc/on_target_key_changed(atom/source, ...)
	SIGNAL_HANDLER
	var/mob/target = owning_controller?.blackboard[key]
	if(target == observed_target)
		return
	if(observed_target)
		UnregisterSignal(observed_target, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM))
		observed_target = null
	if(ismob(target))
		observed_target = target
		RegisterSignals(target, list(COMSIG_MOB_EQUIPPED_ITEM, COMSIG_MOB_UNEQUIPPED_ITEM), PROC_REF(on_signal_changed), override = TRUE)
	if(owning_controller)
		on_observed_change(owning_controller, null)

/datum/bt_node/decorator/target_is_holding_item/check_condition(datum/ai_controller/controller)
	var/mob/target = controller.blackboard[key]
	if(QDELETED(target))
		return FALSE
	return target.get_num_held_items() > 0
