/// Trigger a web-spinning action at the current web target turf.
/// Expects move_to_target to have positioned the spider first.
/// Clears BB_SPIDER_WEB_TARGET on finish.
/datum/bt_node/ai_behavior/spin_web
	time_between_perform = 15 SECONDS

/datum/bt_node/ai_behavior/spin_web/setup(datum/ai_controller/controller, action_key, target_key)
	if(!controller.blackboard_key_exists(action_key) || !controller.blackboard_key_exists(target_key))
		return FALSE
	return ..()

/datum/bt_node/ai_behavior/spin_web/perform(seconds_per_tick, datum/ai_controller/controller, action_key, target_key)
	var/datum/action/cooldown/web_action = controller.blackboard[action_key]
	if(web_action?.Trigger())
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/spin_web/finish_action(datum/ai_controller/controller, succeeded, action_key, target_key)
	controller.clear_blackboard_key(target_key)
	return ..()
