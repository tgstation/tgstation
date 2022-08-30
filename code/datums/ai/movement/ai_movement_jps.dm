/**
 * This movement datum represents smart-pathing
 */
/datum/ai_movement/jps
	max_pathing_attempts = 20
	var/datum/move_loop/move_loop

/datum/ai_movement/jps/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/delay = controller.movement_delay

	move_loop = SSmove_manager.jps_move(moving,
		current_movement_target,
		delay,
		repath_delay = 2 SECONDS,
		max_path_length = controller.max_target_distance,
		minimum_distance = controller.get_minimum_distance(),
		id = controller.get_access(),
		subsystem = SSai_movement,
		extra_info = controller)

	RegisterSignal(move_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, .proc/pre_move)
	RegisterSignal(move_loop, COMSIG_MOVELOOP_POSTPROCESS, .proc/post_move)
	RegisterSignal(move_loop, COMSIG_MOVELOOP_PRE_JPS_REPATH, .proc/repath_incoming)


/datum/ai_movement/jps/proc/repath_incoming(datum/move_loop/has_target/jps/source)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = source.extra_info

	source.id = controller.get_access()
	source.minimum_distance = controller.get_minimum_distance()
