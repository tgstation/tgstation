/// Moves toward a blackboard-keyed target each tick. Set finish_on_arrival = TRUE to succeed when within required_dist.
/datum/bt_node/ai_behavior/move_to_target
	action_cooldown = 0

/datum/bt_node/ai_behavior/move_to_target/setup(datum/ai_controller/controller, target_key, required_dist = 1, finish_on_arrival = FALSE)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	controller.ai_movement.start_moving_towards(controller, target, required_dist)
	return TRUE

/datum/bt_node/ai_behavior/move_to_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key, required_dist = 1, finish_on_arrival = FALSE)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_FAILED
	if(finish_on_arrival && get_dist(controller.pawn, target) <= required_dist)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT

/datum/bt_node/ai_behavior/move_to_target/finish_action(datum/ai_controller/controller, succeeded, target_key, required_dist = 1, finish_on_arrival = FALSE)
	controller.ai_movement.stop_moving_towards(controller)
	return ..()
