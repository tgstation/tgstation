/// Check if the specified blackboard key is off cooldown.
/datum/bt_node/decorator/key_off_cooldown
	var/cooldown_key

/datum/bt_node/decorator/key_off_cooldown/check_condition(datum/ai_controller/controller)
	var/cooldown_time = controller.blackboard[cooldown_key]
	return isnull(cooldown_time) || cooldown_time <= world.time

/**
 * Checks if a blackboard cooldown key is off cooldown before ticking the child,
 * then sets it when the child finishes  replacing the key_off_cooldown
 *
 * cooldown_duration is the duration of the cooldown (or lower bound if max is also set)
 * cooldown_duration_max is the upper bounds
 * lock_on_succeed = TRUE (default): lock after child SUCCESS only.
 * lock_on_succeed = FALSE: lock after any completion (SUCCESS or FAILURE).
 */
/datum/bt_node/decorator/cooldown
	var/cooldown_key
	var/cooldown_duration
	/// Optional upper bound for a randomly chosen cooldown duration.
	var/cooldown_duration_max
	var/lock_on_succeed = TRUE

/datum/bt_node/decorator/cooldown/check_condition(datum/ai_controller/controller)
	var/cooldown_time = controller.blackboard[cooldown_key]
	return isnull(cooldown_time) || cooldown_time <= world.time

/datum/bt_node/decorator/cooldown/on_child_complete(datum/ai_controller/controller, result)
	if(!lock_on_succeed || result == BT_SUCCESS)
		var/actual_cooldown_duration = cooldown_duration
		if(!isnull(cooldown_duration_max))
			actual_cooldown_duration = rand(cooldown_duration, cooldown_duration_max)
		controller.set_blackboard_key(cooldown_key, world.time + actual_cooldown_duration)
