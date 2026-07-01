/// Passes if the pawn is farther than the distance stored in distance_key from the atom stored in anchor_key.
/datum/bt_node/decorator/pawn_farther_than_from_key
	/// Blackboard key holding the anchor atom.
	var/anchor_key
	/// Blackboard key whose integer value is the minimum distance threshold (exclusive).
	var/distance_key

/datum/bt_node/decorator/pawn_farther_than_from_key/check_condition(datum/ai_controller/controller)
	var/atom/anchor = controller.blackboard[anchor_key]
	if(QDELETED(anchor))
		return FALSE
	var/min_dist = controller.blackboard[distance_key]
	return get_dist(controller.pawn, anchor) > min_dist
