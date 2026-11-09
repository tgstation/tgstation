/// Passes if the blackboard key holds a list with at least min_count entries.
/datum/bt_node/decorator/bb_key_list_min_count
	var/key
	var/min_count = 1

/datum/bt_node/decorator/bb_key_list_min_count/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/bb_key_list_min_count/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)))

/datum/bt_node/decorator/bb_key_list_min_count/check_condition(datum/ai_controller/controller)
	return LAZYLEN(controller.blackboard[key]) >= min_count
