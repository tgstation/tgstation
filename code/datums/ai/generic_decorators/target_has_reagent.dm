/// Gates child on the atom held in a blackboard key having a specific reagent in its reagent list. Use "invert": true to gate on the reagent being absent.
/datum/bt_node/decorator/target_has_reagent
	/// Blackboard key holding the atom to check.
	var/key = null
	/// Typepath of the reagent to look for.
	var/reagent_type = null
	/// Tracked so we can rebind signals when the key or its reagents change.
	var/datum/reagents/observed_holder = null

/datum/bt_node/decorator/target_has_reagent/register_observe_signals(atom/pawn)
	var/atom/target = owning_controller?.blackboard[key]
	if(target?.reagents)
		observed_holder = target.reagents
		RegisterSignal(observed_holder, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_signal_changed))
	RegisterSignals(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)), PROC_REF(on_target_key_changed))
	return TRUE

/datum/bt_node/decorator/target_has_reagent/unregister_observe_signals(atom/pawn)
	if(observed_holder)
		UnregisterSignal(observed_holder, COMSIG_REAGENTS_HOLDER_UPDATED)
		observed_holder = null
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)))

/// Fires when the blackboard key changes. Rebinds the reagent holder observer to the new target and re-evaluates.
/datum/bt_node/decorator/target_has_reagent/proc/on_target_key_changed(atom/source, ...)
	SIGNAL_HANDLER
	if(observed_holder)
		UnregisterSignal(observed_holder, COMSIG_REAGENTS_HOLDER_UPDATED)
		observed_holder = null
	var/atom/target = owning_controller?.blackboard[key]
	if(target?.reagents)
		observed_holder = target.reagents
		RegisterSignal(observed_holder, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_signal_changed))
	if(owning_controller)
		on_observed_change(owning_controller, null)

/datum/bt_node/decorator/target_has_reagent/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[key]
	if(QDELETED(target) || !target.reagents)
		return FALSE
	return !!target.reagents.has_reagent(reagent_type)
