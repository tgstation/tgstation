///Are we grabbing the specified target key?
/datum/bt_node/decorator/is_grabbing_target
	/// The blackboard key whose value is the grabbed atom.
	var/key

/datum/bt_node/decorator/is_grabbing_target/check_condition(datum/ai_controller/controller)
	var/atom/movable/target = controller.blackboard[key]
	var/mob/living/our_mob = controller.pawn
	if(QDELETED(target) || our_mob.pulling != target)
		controller.clear_blackboard_key(key)
		return FALSE
	return TRUE

/datum/bt_node/decorator/is_grabbing_target/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(COMSIG_LIVING_START_PULL, COMSIG_ATOM_NO_LONGER_PULLING, COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/is_grabbing_target/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(COMSIG_LIVING_START_PULL, COMSIG_ATOM_NO_LONGER_PULLING, COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)))

