/// Gates child on the pawn having gravity. Use invert = TRUE to gate on weightlessness instead.
/datum/bt_node/decorator/pawn_has_gravity

/datum/bt_node/decorator/pawn_has_gravity/register_observe_signals(atom/pawn)
	RegisterSignal(pawn, COMSIG_LIVING_GRAVITY_CHANGED, PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/pawn_has_gravity/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, COMSIG_LIVING_GRAVITY_CHANGED)

/datum/bt_node/decorator/pawn_has_gravity/check_condition(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	return istype(living_pawn) && living_pawn.has_gravity()
