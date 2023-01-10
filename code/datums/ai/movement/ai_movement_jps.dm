/**
 * This movement datum represents smart-pathing
 */
/datum/ai_movement/jps
	max_pathing_attempts = 4

/datum/ai_movement/jps/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/delay = controller.movement_delay

	var/datum/move_loop/loop = SSmove_manager.jps_move(moving,
		current_movement_target,
		delay,
		repath_delay = 2 SECONDS,
		max_path_length = AI_MAX_PATH_LENGTH,
		minimum_distance = controller.get_minimum_distance(),
		id = controller.get_access(),
		subsystem = SSai_movement,
		extra_info = controller)

	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_JPS_REPATH, PROC_REF(repath_incoming))

/datum/ai_movement/jps/proc/repath_incoming(datum/move_loop/has_target/jps/source)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = source.extra_info

	source.id = controller.get_access()
	source.minimum_distance = controller.get_minimum_distance()
