/// Trigger a web-spinning action at the current web target turf.
/// Expects move_to_target to have positioned the spider first.
/// Clears BB_SPIDER_WEB_TARGET on finish.
/datum/bt_node/ai_behavior/spin_web
	time_between_perform = 15 SECONDS
	/// Blackboard key holding the web-spinning action.
	var/action_key
	/// Blackboard key holding the target turf to web.
	var/target_key

/datum/bt_node/ai_behavior/spin_web/setup(datum/ai_controller/controller)
	if(!controller.blackboard_key_exists(action_key) || !controller.blackboard_key_exists(target_key))
		return FALSE
	return ..()

/datum/bt_node/ai_behavior/spin_web/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags

	var/datum/action/cooldown/web_action = controller.blackboard[action_key]
	if(!web_action)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	return start_async()

/datum/bt_node/ai_behavior/spin_web/perform_async(datum/ai_controller/controller)
	var/datum/action/cooldown/web_action = controller.blackboard[action_key]
	var/result = web_action.Trigger()
	if(!async_still_valid())
		return
	finish_async(result ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

/datum/bt_node/ai_behavior/spin_web/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)
