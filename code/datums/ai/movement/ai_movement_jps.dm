/**
 * This movement datum represents smart-pathing
 */
/datum/ai_movement/jps
	max_pathing_attempts = 20
	var/maximum_length = AI_MAX_PATH_LENGTH
	///how we deal with diagonal movement, whether we try to avoid them or follow through with them
	var/diagonal_flags = DIAGONAL_REMOVE_CLUNKY

/datum/ai_movement/jps/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/delay = controller.movement_delay

	var/datum/move_loop/has_target/jps/loop = GLOB.move_manager.jps_move(moving,
		current_movement_target,
		delay,
		repath_delay = 0.5 SECONDS,
		max_path_length = maximum_length,
		minimum_distance = controller.get_minimum_distance(),
		access = controller.get_access(),
		subsystem = SSai_movement,
		diagonal_handling = diagonal_flags,
		extra_info = controller,
	)

	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_JPS_REPATH, PROC_REF(repath_incoming))

	return loop

/datum/ai_movement/jps/proc/repath_incoming(datum/move_loop/has_target/jps/source)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = source.extra_info

	source.access = controller.get_access()
	source.minimum_distance = controller.get_minimum_distance()

/datum/ai_movement/jps/bot
	max_pathing_attempts = 8
	maximum_length = 25
	diagonal_flags = DIAGONAL_REMOVE_ALL

/datum/ai_movement/jps/bot/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	var/datum/move_loop/loop = ..()
	var/atom/our_pawn = controller.pawn
	if(isnull(our_pawn))
		return
	our_pawn.RegisterSignal(loop, COMSIG_MOVELOOP_JPS_FINISHED_PATHING, TYPE_PROC_REF(/mob/living/basic/bot, generate_bot_path))

/datum/ai_movement/jps/bot/travel_to_beacon
	maximum_length = AI_BOT_PATH_LENGTH
	max_pathing_attempts = 20

/datum/ai_movement/jps/modsuit
	maximum_length = MOD_AI_RANGE
