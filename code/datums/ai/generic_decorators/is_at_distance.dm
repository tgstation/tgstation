/// Decorator that requires the controller's pawn to be within range of a blackboard target.
/datum/bt_node/decorator/is_at_distance
	/// Blackboard key holding the atom to approach. Must be set on the subtype or via configure().
	var/target_key = null
	/// Minimum distance (inclusive) from target. 0 means no lower bound.
	var/min_distance = 0
	/// Maximum distance (inclusive) from target before passing to child.
	var/required_distance = 1
	/// If TRUE, also verifies target.IsReachableBy(pawn) before passing to child.
	var/require_reach = FALSE

/datum/bt_node/decorator/is_at_distance/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	var/atom/movable/pawn = controller.pawn
	var/dist = get_dist(pawn, target)
	var/reachable = !require_reach || target.IsReachableBy(pawn)

	return dist <= required_distance && (min_distance == 0 || dist >= min_distance) && reachable
