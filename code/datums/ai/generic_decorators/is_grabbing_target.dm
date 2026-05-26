/**
 * Gates child on the pawn currently pulling the atom at the given blackboard key.
 * Clears the key and returns BT_FAILURE if the grab has been broken (target deleted or no longer pulled).
 * Supports observer_abort via evaluate_for_observer so the child is aborted reactively when the grab ends.
 */
/datum/bt_node/decorator/is_grabbing_target
	/// The blackboard key whose value is the grabbed atom.
	var/key

/datum/bt_node/decorator/is_grabbing_target/check_condition(datum/ai_controller/controller)
	var/atom/movable/target = controller.blackboard[key]
	if(QDELETED(target) || controller.pawn.pulling != target)
		controller.clear_blackboard_key(key)
		return FALSE
	return TRUE

/datum/bt_node/decorator/is_grabbing_target/evaluate_for_observer(datum/ai_controller/controller)
	var/atom/movable/target = controller.blackboard[key]
	return !QDELETED(target) && controller.pawn.pulling == target
