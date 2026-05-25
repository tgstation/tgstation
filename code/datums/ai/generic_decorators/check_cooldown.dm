/// Check if the specified blackboard key is off cooldown.
/datum/bt_node/decorator/key_off_cooldown
	var/cooldown_key

/datum/bt_node/decorator/key_off_cooldown/check_condition(datum/ai_controller/controller)
	var/cooldown_time = controller.blackboard[cooldown_key]
	return isnull(cooldown_time) || cooldown_time <= world.time
