/// Gates child on the atom held in a blackboard key having a given trait. Use "invert": true to gate on the trait being absent.
/datum/bt_node/decorator/target_has_trait
	/// Blackboard key holding the atom to check.
	var/key = null
	/// The trait the target must have for the child to run.
	var/trait = null
	/// Tracked so we can rebind signals when the key changes.
	var/atom/observed_target = null

/datum/bt_node/decorator/target_has_trait/register_observe_signals(atom/pawn)
	var/atom/target = owning_controller?.blackboard[key]
	if(target)
		observed_target = target
		RegisterSignals(target, list(SIGNAL_ADDTRAIT(trait), SIGNAL_REMOVETRAIT(trait)), PROC_REF(on_signal_changed))
	RegisterSignals(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)), PROC_REF(on_target_key_changed))
	return TRUE

/datum/bt_node/decorator/target_has_trait/unregister_observe_signals(atom/pawn)
	if(observed_target)
		UnregisterSignal(observed_target, list(SIGNAL_ADDTRAIT(trait), SIGNAL_REMOVETRAIT(trait)))
		observed_target = null
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)))

/// Fires when the blackboard key changes. Rebinds trait signals to the new target and re-evaluates.
/datum/bt_node/decorator/target_has_trait/proc/on_target_key_changed(atom/source, ...)
	SIGNAL_HANDLER
	if(observed_target)
		UnregisterSignal(observed_target, list(SIGNAL_ADDTRAIT(trait), SIGNAL_REMOVETRAIT(trait)))
		observed_target = null
	var/atom/target = owning_controller?.blackboard[key]
	if(target)
		observed_target = target
		RegisterSignals(target, list(SIGNAL_ADDTRAIT(trait), SIGNAL_REMOVETRAIT(trait)), PROC_REF(on_signal_changed))
	if(owning_controller)
		on_observed_change(owning_controller, null)

/datum/bt_node/decorator/target_has_trait/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[key]
	if(QDELETED(target))
		return FALSE
	return HAS_TRAIT(target, trait)
