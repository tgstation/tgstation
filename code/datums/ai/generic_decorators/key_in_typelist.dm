/// Gates child on the atom in `key` being an instance of a type in the typelist held at `typelist_key`. Use "invert": true for the opposite.
/datum/bt_node/decorator/key_in_typelist
	/// Blackboard key holding the atom to type-check.
	var/key = BB_CURRENT_TARGET
	/// Blackboard key holding the list of typepaths to check against.
	var/typelist_key

/datum/bt_node/decorator/key_in_typelist/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(
		COMSIG_AI_BLACKBOARD_KEY_SET(key),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(key),
		COMSIG_AI_BLACKBOARD_KEY_SET(typelist_key),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(typelist_key),
	), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/key_in_typelist/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(
		COMSIG_AI_BLACKBOARD_KEY_SET(key),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(key),
		COMSIG_AI_BLACKBOARD_KEY_SET(typelist_key),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(typelist_key),
	))

/datum/bt_node/decorator/key_in_typelist/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[key]
	var/list/types = controller.blackboard[typelist_key]
	if(QDELETED(target) || isnull(types))
		return FALSE
	return is_type_in_list(target, types)
