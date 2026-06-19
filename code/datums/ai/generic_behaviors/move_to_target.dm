/// Moves toward a blackboard-keyed target each tick. Succeeds when within required_dist by default.
/// Pass finish_on_arrival = FALSE to keep running indefinitely (used in combat parallels).
/// Pass movement_type to temporarily override the controller's ai_movement; resets to the initial type on finish.
/datum/bt_node/ai_behavior/move_to_target
	time_between_perform = 0
	/// Set by on_movement_failed() when the movement system gives up pathing.
	VAR_FINAL/movement_failed = FALSE
	/// Blackboard key holding the atom to move toward.
	var/target_key
	/// Distance at which arrival is considered reached.
	var/required_dist = 1
	/// Whether to succeed once within required_dist; FALSE keeps running indefinitely.
	var/finish_on_arrival = TRUE
	/// Optional ai_movement type override; resets to the initial type on finish.
	var/movement_type = null

/datum/bt_node/ai_behavior/move_to_target/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	if(movement_type)
		controller.change_ai_movement_type(movement_type)
	RegisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED, PROC_REF(on_movement_failed))
	controller.ai_movement.start_moving_towards(controller, target, required_dist)
	return TRUE

/datum/bt_node/ai_behavior/move_to_target/proc/on_movement_failed(atom/source)
	SIGNAL_HANDLER
	movement_failed = TRUE

/datum/bt_node/ai_behavior/move_to_target/perform(seconds_per_tick, datum/ai_controller/controller)
	if(movement_failed)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_FAILED
	if(!controller.ai_movement.moving_controllers[controller])
		controller.ai_movement.start_moving_towards(controller, target, required_dist)
	if(finish_on_arrival && get_dist(controller.pawn, target) <= required_dist)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT

/datum/bt_node/ai_behavior/move_to_target/finish_action(datum/ai_controller/controller, succeeded)
	UnregisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED)
	movement_failed = FALSE
	controller.ai_movement.stop_moving_towards(controller)
	if(movement_type)
		controller.change_ai_movement_type(initial(controller.ai_movement))
	return ..()
