///Check fi target is still on a turf
/datum/bt_node/decorator/validate_target_on_turf
	var/key

	var/atom/observed_target = null

/datum/bt_node/decorator/validate_target_on_turf/register_observe_signals(atom/pawn)
	var/atom/target = owning_controller?.blackboard[key]
	if(target)
		observed_target = target
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_signal_changed), override = TRUE)
	RegisterSignals(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)), PROC_REF(on_key_changed))
	return TRUE

/datum/bt_node/decorator/validate_target_on_turf/unregister_observe_signals(atom/pawn)
	if(observed_target)
		UnregisterSignal(observed_target, COMSIG_MOVABLE_MOVED)
		observed_target = null
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)))

/datum/bt_node/decorator/validate_target_on_turf/proc/on_key_changed(atom/pawn, ...)
	SIGNAL_HANDLER
	var/atom/target = owning_controller?.blackboard[key]
	if(target == observed_target)
		return
	if(observed_target)
		UnregisterSignal(observed_target, COMSIG_MOVABLE_MOVED)
		observed_target = null
	if(target)
		observed_target = target
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_signal_changed), override = TRUE)
	if(owning_controller)
		on_observed_change(owning_controller, null)

/datum/bt_node/decorator/validate_target_on_turf/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[key]
	if(QDELETED(target) || !isturf(target.loc))
		controller.clear_blackboard_key(key)
		return FALSE
	return TRUE

/// Check without side effects for observer path.
/datum/bt_node/decorator/validate_target_on_turf/evaluate_for_observer(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[key]
	return !QDELETED(target) && isturf(target.loc)
