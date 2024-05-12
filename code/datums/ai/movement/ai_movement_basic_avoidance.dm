///Uses Byond's basic obstacle avoidance movement
/datum/ai_movement/basic_avoidance
	max_pathing_attempts = 10
	/// Movement flags to pass to the loop
	var/move_flags = NONE

/datum/ai_movement/basic_avoidance/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/min_dist = controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE]
	var/delay = controller.movement_delay
	var/datum/move_loop/loop = GLOB.move_manager.move_to(moving, current_movement_target, min_dist, delay, flags = move_flags, subsystem = SSai_movement, extra_info = controller)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))

/datum/ai_movement/basic_avoidance/allowed_to_move(datum/move_loop/has_target/dist_bound/source)
	. = ..()
	var/turf/target_turf = get_step_towards(source.moving, source.target)
	if(!target_turf?.can_cross_safely(source.moving))
		return FALSE

/// Move immediately and don't update our facing
/datum/ai_movement/basic_avoidance/backstep
	move_flags = MOVEMENT_LOOP_START_FAST | MOVEMENT_LOOP_NO_DIR_UPDATE
