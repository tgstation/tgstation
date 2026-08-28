/// Gates child on the atom held in a blackboard key being an instance of a given typepath. Use "invert": true for the opposite.
/datum/bt_node/decorator/target_is_type
	/// Blackboard key holding the atom to check.
	var/key = BB_CURRENT_TARGET
	/// Typepath the target must be an instance of.
	var/target_type

/datum/bt_node/decorator/target_is_type/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[key]
	if(QDELETED(target) || isnull(target_type))
		return FALSE
	return istype(target, target_type)
