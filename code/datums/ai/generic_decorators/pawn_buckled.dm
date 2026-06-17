/// Gates the child on the pawn being buckled to something.
/datum/bt_node/decorator/pawn_buckled

/datum/bt_node/decorator/pawn_buckled/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(COMSIG_MOB_BUCKLED, COMSIG_MOB_UNBUCKLED), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/pawn_buckled/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(COMSIG_MOB_BUCKLED, COMSIG_MOB_UNBUCKLED))

/datum/bt_node/decorator/pawn_buckled/check_condition(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	return !isnull(pawn.buckled)
