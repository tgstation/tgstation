/// Gates on the pawn currently being inside a vent (has TRAIT_MOVE_VENTCRAWLING).
/datum/bt_node/decorator/is_in_vent
	observer_abort = BT_ABORT_LOWER_PRIORITY

/datum/bt_node/decorator/is_in_vent/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(SIGNAL_ADDTRAIT(TRAIT_MOVE_VENTCRAWLING), SIGNAL_REMOVETRAIT(TRAIT_MOVE_VENTCRAWLING)), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/is_in_vent/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(SIGNAL_ADDTRAIT(TRAIT_MOVE_VENTCRAWLING), SIGNAL_REMOVETRAIT(TRAIT_MOVE_VENTCRAWLING)))

/datum/bt_node/decorator/is_in_vent/check_condition(datum/ai_controller/controller)
	return HAS_TRAIT(controller.pawn, TRAIT_MOVE_VENTCRAWLING)
