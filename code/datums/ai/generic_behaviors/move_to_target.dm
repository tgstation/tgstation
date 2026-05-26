/// Moves toward a blackboard-keyed target each tick. Succeeds when within required_dist by default.
/// Pass finish_on_arrival = FALSE to keep running indefinitely (used in combat parallels).
/// Pass movement_type to temporarily override the controller's ai_movement; resets to the initial type on finish.
/datum/bt_node/ai_behavior/move_to_target
	action_cooldown = 0

/datum/bt_node/ai_behavior/move_to_target/setup(datum/ai_controller/controller, target_key, required_dist = 1, finish_on_arrival = TRUE, movement_type = null)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	if(movement_type)
		controller.change_ai_movement_type(movement_type)
	controller.ai_movement.start_moving_towards(controller, target, required_dist)
	return TRUE

/datum/bt_node/ai_behavior/move_to_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key, required_dist = 1, finish_on_arrival = TRUE, movement_type = null)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_FAILED
	if(!controller.ai_movement.moving_controllers[controller])
		controller.ai_movement.start_moving_towards(controller, target, required_dist)
	if(finish_on_arrival && get_dist(controller.pawn, target) <= required_dist)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT

/datum/bt_node/ai_behavior/move_to_target/finish_action(datum/ai_controller/controller, succeeded, target_key, required_dist = 1, finish_on_arrival = TRUE, movement_type = null)
	controller.ai_movement.stop_moving_towards(controller)
	if(movement_type)
		controller.change_ai_movement_type(initial(controller.ai_movement))
	return ..()
