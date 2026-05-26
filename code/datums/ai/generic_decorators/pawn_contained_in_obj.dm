/// Gates on the pawn being inside an obj (not a turf, mob, or mob_holder); writes pawn.loc to the escape target key.
/datum/bt_node/decorator/pawn_contained_in_obj
	var/target_key = BB_BASIC_MOB_ESCAPE_TARGET
	observer_abort = BT_ABORT_LOWER_PRIORITY

/datum/bt_node/decorator/pawn_contained_in_obj/get_pawn_observe_signals()
	return list(COMSIG_MOVABLE_MOVED)

/datum/bt_node/decorator/pawn_contained_in_obj/check_condition(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	if(isturf(pawn.loc) || ismob(pawn.loc) || istype(pawn.loc, /obj/item/mob_holder))
		return FALSE
	controller.blackboard[target_key] = pawn.loc
	return TRUE

/datum/bt_node/decorator/pawn_contained_in_obj/evaluate_for_observer(datum/ai_controller/controller)
	var/atom/loc = controller.pawn.loc
	return !isturf(loc) && !ismob(loc) && !istype(loc, /obj/item/mob_holder)
