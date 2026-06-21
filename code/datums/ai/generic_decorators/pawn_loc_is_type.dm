/// Passes when the pawn's loc is of the given type (e.g. the pawn is inside a specific structure).
/datum/bt_node/decorator/pawn_loc_is_type
	observer_abort = BT_ABORT_LOWER_PRIORITY
	/// Typepath the pawn's loc must match.
	var/loc_type

/datum/bt_node/decorator/pawn_loc_is_type/register_observe_signals(atom/pawn)
	RegisterSignal(pawn, COMSIG_MOVABLE_MOVED, PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/pawn_loc_is_type/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, COMSIG_MOVABLE_MOVED)

/datum/bt_node/decorator/pawn_loc_is_type/check_condition(datum/ai_controller/controller)
	return istype(controller.pawn.loc, loc_type)
