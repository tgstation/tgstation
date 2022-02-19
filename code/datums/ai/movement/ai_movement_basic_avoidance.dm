///Uses Byond's basic obstacle avoidance mvovement
/datum/ai_movement/basic_avoidance
	max_pathing_attempts = 10

/datum/ai_movement/basic_avoidance/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/min_dist = controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE]
	var/delay = controller.movement_delay
	var/datum/move_loop/loop = SSmove_manager.move_to(moving, current_movement_target, min_dist, delay, subsystem = SSai_movement, extra_info = controller)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, .proc/pre_move)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, .proc/post_move)

/datum/ai_movement/basic_avoidance/proc/pre_move(datum/move_loop/has_target/dist_bound/source)
	SIGNAL_HANDLER
	var/atom/movable/pawn = source.moving
	var/datum/ai_controller/controller = source.extra_info
	source.delay = controller.movement_delay
	source.distance = controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE]

	var/can_move = TRUE
	if(controller.ai_traits & STOP_MOVING_WHEN_PULLED && pawn.pulledby)
		can_move = FALSE

	// Check if this controller can actually run, so we don't chase people with corpses
	if(!controller.able_to_run())
		controller.CancelActions()
		qdel(source) //stop moving
		return MOVELOOP_SKIP_STEP

	if(!isturf(pawn.loc)) //No moving if not on a turf
		can_move = FALSE

	var/turf/target_turf = get_step_to(pawn, source.target)

	if(is_type_in_typecache(target_turf, GLOB.dangerous_turfs))
		can_move = FALSE

	if(can_move)
		return
	increment_pathing_failures(controller)
	return MOVELOOP_SKIP_STEP

/datum/ai_movement/basic_avoidance/proc/post_move(datum/move_loop/source, succeeded)
	SIGNAL_HANDLER
	if(succeeded)
		return
	var/datum/ai_controller/controller = source.extra_info
	increment_pathing_failures(controller)

