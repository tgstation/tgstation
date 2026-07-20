///Checks for gender difference, I know, not very 2026 of me but until we add m-preg this'll have to do.
/datum/bt_node/decorator/keys_different_gender
	/// Blackboard key holding the first mob.
	var/key_a = BB_CURRENT_TARGET
	/// Blackboard key holding the second mob.
	var/key_b

/datum/bt_node/decorator/keys_different_gender/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(
		COMSIG_AI_BLACKBOARD_KEY_SET(key_a),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(key_a),
		COMSIG_AI_BLACKBOARD_KEY_SET(key_b),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(key_b),
	), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/keys_different_gender/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(
		COMSIG_AI_BLACKBOARD_KEY_SET(key_a),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(key_a),
		COMSIG_AI_BLACKBOARD_KEY_SET(key_b),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(key_b),
	))

/datum/bt_node/decorator/keys_different_gender/check_condition(datum/ai_controller/controller)
	var/mob/mob_a = controller.blackboard[key_a]
	var/mob/mob_b = controller.blackboard[key_b]
	if(isnull(mob_a) || isnull(mob_b))
		return FALSE
	return mob_a.gender != mob_b.gender
