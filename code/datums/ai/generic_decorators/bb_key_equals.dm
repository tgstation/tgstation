/// Passes if the given blackboard key equals the expected value.
/datum/bt_node/decorator/bb_key_equals
	var/key
	var/value

/datum/bt_node/decorator/bb_key_equals/check_condition(datum/ai_controller/controller)
	return bb_key_equals(controller, key, value)
