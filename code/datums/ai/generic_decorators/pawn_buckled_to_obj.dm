/// Gates on the pawn being buckled to an obj; writes pawn.buckled to the escape target key as a side effect.
/datum/bt_node/decorator/pawn_buckled_to_obj
	var/target_key = BB_BASIC_MOB_ESCAPE_TARGET
	observer_abort = BT_ABORT_LOWER_PRIORITY

/datum/bt_node/decorator/pawn_buckled_to_obj/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(COMSIG_MOB_BUCKLED, COMSIG_MOB_UNBUCKLED), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/pawn_buckled_to_obj/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(COMSIG_MOB_BUCKLED, COMSIG_MOB_UNBUCKLED))

/datum/bt_node/decorator/pawn_buckled_to_obj/check_condition(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	if(!isobj(pawn.buckled))
		return FALSE
	controller.blackboard[target_key] = pawn.buckled
	return TRUE

/datum/bt_node/decorator/pawn_buckled_to_obj/evaluate_for_observer(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	return isobj(pawn.buckled)
