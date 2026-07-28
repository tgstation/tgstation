/// Gates on the pawn being inside an obj (not a turf, mob, or mob_holder); writes pawn.loc to the escape target key.
/datum/bt_node/decorator/pawn_contained_in_obj
	var/target_key = BB_BASIC_MOB_ESCAPE_TARGET
	observer_abort = BT_ABORT_LOWER_PRIORITY

/datum/bt_node/decorator/pawn_contained_in_obj/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(COMSIG_MOVABLE_MOVED), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/pawn_contained_in_obj/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(COMSIG_MOVABLE_MOVED))

/datum/bt_node/decorator/pawn_contained_in_obj/check_condition(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	if(isturf(pawn.loc) || ismob(pawn.loc) || istype(pawn.loc, /obj/item/mob_holder) || HAS_TRAIT(controller.pawn, TRAIT_MOVE_VENTCRAWLING))
		return FALSE
	controller.blackboard[target_key] = pawn.loc
	return TRUE
