/// Passes if the pawn is on the same z-level as the atom stored in the given blackboard key.
/datum/bt_node/decorator/pawn_same_z_as_key
	var/key

/datum/bt_node/decorator/pawn_same_z_as_key/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[key]
	if(QDELETED(target))
		return FALSE
	return controller.pawn.z == target.z
