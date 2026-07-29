/**
 * Gates its child until it has completed once.
 *
 * The latch is stored on the controller blackboard, so it survives plan cancellation
 * and can be reset with UNLOCK_DO_ONCE().
 *
 * only_lock_if_succeeded = FALSE (default): lock after either terminal child result.
 * only_lock_if_succeeded = TRUE: lock only after child SUCCESS.
 */
/datum/bt_node/decorator/do_once
	/// Blackboard key storing the completion latch.
	var/lock_key
	/// Whether a child FAILURE should leave this decorator available for another attempt.
	var/only_lock_if_succeeded = FALSE

/datum/bt_node/decorator/do_once/check_condition(datum/ai_controller/controller)
	return !controller.blackboard_key_exists(lock_key)

/datum/bt_node/decorator/do_once/on_child_complete(datum/ai_controller/controller, result)
	if(!only_lock_if_succeeded || result == BT_SUCCESS)
		controller.set_blackboard_key(lock_key, TRUE)

/datum/bt_node/decorator/do_once/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(lock_key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(lock_key)), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/do_once/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(lock_key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(lock_key)))
