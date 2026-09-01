/// Gates on the pawn being located inside another mob (e.g. absorbed or shapeshifted).
/datum/bt_node/decorator/pawn_inside_mob
	observer_abort = BT_ABORT_LOWER_PRIORITY

/datum/bt_node/decorator/pawn_inside_mob/register_observe_signals(atom/pawn)
	RegisterSignal(pawn, COMSIG_MOVABLE_MOVED, PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/pawn_inside_mob/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, COMSIG_MOVABLE_MOVED)

/datum/bt_node/decorator/pawn_inside_mob/check_condition(datum/ai_controller/controller)
	return ismob(controller.pawn.loc)
