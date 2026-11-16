/// Moves toward a blackboard-keyed target each tick. Succeeds when within required_dist by default.
/// Pass finish_on_arrival = FALSE to keep running indefinitely (used in combat parallels).
/// Pass movement_type to temporarily override the controller's ai_movement; resets to the initial type on finish.
/datum/bt_node/ai_behavior/move_to_target
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
	/// If true, repath when a movable target moves. This only works with navmap movement.
	var/update_movement_for_moving_target = FALSE
	/// Tracks the last atom we started moving toward so we can retarget when the key changes.
	VAR_PRIVATE/atom/tracked_target
	/// Movable target whose movement signal we are following.
	VAR_PRIVATE/atom/movable/tracked_movable_target

/datum/bt_node/ai_behavior/move_to_target/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	if(movement_type)
		controller.change_ai_movement_type(movement_type)
	RegisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED, PROC_REF(on_movement_failed))
	controller.ai_movement.start_moving_towards(controller, target, required_dist)
	tracked_target = target
	track_moving_target(target)
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
	if(target != tracked_target)
		controller.ai_movement.start_moving_towards(controller, target, required_dist)
		tracked_target = target
		track_moving_target(target)
	else if(!controller.ai_movement.moving_controllers[controller])
		controller.ai_movement.start_moving_towards(controller, target, required_dist)
	if(finish_on_arrival && get_dist(controller.pawn, target) <= required_dist)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT

/datum/bt_node/ai_behavior/move_to_target/finish_action(datum/ai_controller/controller, succeeded)
	UnregisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED)
	track_moving_target()
	movement_failed = FALSE
	tracked_target = null
	controller.ai_movement.stop_moving_towards(controller)
	if(movement_type)
		controller.change_ai_movement_type(initial(controller.ai_movement))
	return ..()

/// Starts tracking target movement when enabled. Navmap-only: other movement datums cannot repath an active route.
/datum/bt_node/ai_behavior/move_to_target/proc/track_moving_target(atom/target = null)
	if(tracked_movable_target)
		UnregisterSignal(tracked_movable_target, COMSIG_MOVABLE_MOVED)
		tracked_movable_target = null
	if(!update_movement_for_moving_target || !ismovable(target))
		return
	tracked_movable_target = target
	RegisterSignal(tracked_movable_target, COMSIG_MOVABLE_MOVED, PROC_REF(on_tracked_target_moved))

/datum/bt_node/ai_behavior/move_to_target/proc/on_tracked_target_moved(atom/movable/source)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = owning_controller
	if(!istype(controller?.ai_movement, /datum/ai_movement/navmap_astar) || controller.ai_movement.moving_controllers[controller] != source)
		return
	controller.ai_movement.update_movement_target(controller, source)
