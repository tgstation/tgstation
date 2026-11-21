/// Passes if the given blackboard key holds a number >= minimum. Returns FAILURE if the key is unset or below minimum.
/datum/bt_node/decorator/bb_key_at_least
	var/key
	var/minimum

/datum/bt_node/decorator/bb_key_at_least/check_condition(datum/ai_controller/controller)
	var/value = controller.blackboard[key]
	return !isnull(value) && value >= minimum
