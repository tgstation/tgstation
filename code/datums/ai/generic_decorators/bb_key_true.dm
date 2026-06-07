/// Passes if the given blackboard key equals a true-ey value
/datum/bt_node/decorator/bb_key_true
	var/key

/datum/bt_node/decorator/bb_key_true/check_condition(datum/ai_controller/controller)
	return controller.blackboard[key]
