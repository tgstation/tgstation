/// Trigger a web-spinning action at the current web target turf.
/// Expects move_to_target to have positioned the spider first.
/// Clears BB_SPIDER_WEB_TARGET on finish.
/datum/bt_node/ai_behavior/spin_web
	time_between_perform = 15 SECONDS
	/// Blackboard key holding the web-spinning action.
	var/action_key
	/// Blackboard key holding the target turf to web.
	var/target_key
	/// Set while the Trigger() call is happening
	var/is_triggering = FALSE
	/// TRUE once the async Trigger() has written its result.
	var/async_trigger_done = FALSE
	/// Whether Trigger() returned a truthy value.
	var/async_trigger_succeeded = FALSE

/datum/bt_node/ai_behavior/spin_web/setup(datum/ai_controller/controller)
	if(!controller.blackboard_key_exists(action_key) || !controller.blackboard_key_exists(target_key))
		return FALSE
	return ..()

/datum/bt_node/ai_behavior/spin_web/perform(seconds_per_tick, datum/ai_controller/controller)
	if(is_triggering)
		return AI_BEHAVIOR_DELAY

	if(async_trigger_done)
		return AI_BEHAVIOR_DELAY | (async_trigger_succeeded ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

	var/datum/action/cooldown/web_action = controller.blackboard[action_key]
	if(!web_action)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	is_triggering = TRUE
	INVOKE_ASYNC(src, PROC_REF(async_trigger), controller, web_action)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/spin_web/proc/async_trigger(datum/ai_controller/controller, datum/action/cooldown/web_action)
	var/result = web_action.Trigger()
	if(!is_triggering)
		return
	async_trigger_succeeded = !!result
	async_trigger_done = TRUE
	is_triggering = FALSE

/datum/bt_node/ai_behavior/spin_web/finish_action(datum/ai_controller/controller, succeeded)
	is_triggering = FALSE
	async_trigger_done = FALSE
	async_trigger_succeeded = FALSE
	controller.clear_blackboard_key(target_key)
	return ..()
