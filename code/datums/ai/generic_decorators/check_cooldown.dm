/// Check if the specified blackboard key is off cooldown.
/datum/bt_node/decorator/key_off_cooldown
	var/cooldown_key

/datum/bt_node/decorator/key_off_cooldown/check_condition(datum/ai_controller/controller)
	var/cooldown_time = controller.blackboard[cooldown_key]
	return isnull(cooldown_time) || cooldown_time <= world.time

/**
 * Checks if a blackboard cooldown key is off cooldown before ticking the child,
 * then sets it when the child finishes — replacing the key_off_cooldown + set_bb_cooldown pair.
 *
 * cooldown_duration is in deciseconds (e.g. 30 SECONDS).
 * lock_on_succeed = TRUE (default): lock after child SUCCESS — standard rate-limit after action.
 * lock_on_succeed = FALSE: lock after child FAILURE — backoff on repeated failure.
 */
/datum/bt_node/decorator/cooldown
	var/cooldown_key
	var/cooldown_duration
	var/lock_on_succeed = TRUE

/datum/bt_node/decorator/cooldown/check_condition(datum/ai_controller/controller)
	var/cooldown_time = controller.blackboard[cooldown_key] SECONDS
	return isnull(cooldown_time) || cooldown_time <= world.time

/datum/bt_node/decorator/cooldown/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick(controller))
		return tick_results[controller] || BT_FAILURE

	var/result
	if(child_active[controller])
		result = child.tick(controller, seconds_per_tick)
	else if(check_condition(controller) == invert)
		result = BT_FAILURE
	else
		result = child.tick(controller, seconds_per_tick)

	if(result == BT_RUNNING)
		child_active[controller] = TRUE
	else
		child_active -= controller
		if(lock_on_succeed == (result == BT_SUCCESS))
			controller.set_blackboard_key(cooldown_key, world.time + cooldown_duration)

	if(tick_rate)
		tick_cooldowns[controller] = world.time
		tick_results[controller] = result
	return result
