/// Is the key set to a non-null value
/datum/bt_node/decorator/bb_key_set
	var/key = null

/datum/bt_node/decorator/bb_key_set/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/bb_key_set/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)))

/datum/bt_node/decorator/bb_key_set/check_condition(datum/ai_controller/controller)
	return controller.blackboard_key_exists(key)
