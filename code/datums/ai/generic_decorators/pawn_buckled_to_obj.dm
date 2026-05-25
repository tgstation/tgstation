/// Gates on the pawn being buckled to an obj; writes pawn.buckled to the escape target key as a side effect.
/datum/bt_node/decorator/pawn_buckled_to_obj
	var/target_key = BB_BASIC_MOB_ESCAPE_TARGET
	observer_abort = BT_ABORT_LOWER_PRIORITY

/datum/bt_node/decorator/pawn_buckled_to_obj/get_pawn_observe_signals()
	return list(COMSIG_MOB_BUCKLED, COMSIG_MOB_UNBUCKLED)

/datum/bt_node/decorator/pawn_buckled_to_obj/tick(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/pawn = controller.pawn
	if(!isobj(pawn.buckled))
		return BT_FAILURE
	controller.blackboard[target_key] = pawn.buckled
	return child.tick(controller, seconds_per_tick)

/datum/bt_node/decorator/pawn_buckled_to_obj/evaluate_for_observer(datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	return isobj(pawn.buckled)
