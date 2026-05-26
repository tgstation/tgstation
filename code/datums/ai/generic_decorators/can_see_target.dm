/**
 * Gates child on a blackboard key holding a visible, non-deleted atom.
 * If the target is null, deleted, or not visible to the pawn, clears the key and returns BT_FAILURE.
 */
/datum/bt_node/decorator/can_see_target
	/// The blackboard key whose value is the atom to validate.
	var/key
	/// Visibility range passed to can_see(). Default matches typical bot search radius.
	var/range = 7

/datum/bt_node/decorator/can_see_target/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[key]
	if(QDELETED(target) || !can_see(controller.pawn, target, range))
		EVLOG_TEXT(controller, EVLOG_CATEGORY_AI_DECISIONMAKING, "[controller.pawn] can_see_target([key]): target lost")
		controller.clear_blackboard_key(key)
		return FALSE
	return TRUE

/datum/bt_node/decorator/can_see_target/evaluate_for_observer(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[key]
	return !QDELETED(target) && can_see(controller.pawn, target, range)
