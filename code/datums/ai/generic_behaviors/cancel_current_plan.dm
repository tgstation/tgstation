/// Cancels the controller's current plan, causing the BT to re-evaluate from the root next tick.
/datum/bt_node/ai_behavior/cancel_current_plan

/datum/bt_node/ai_behavior/cancel_current_plan/perform(seconds_per_tick, datum/ai_controller/controller)
	controller.CancelActions()
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
