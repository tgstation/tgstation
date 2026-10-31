/**
 * This movement datum follows paths produced by navmap A*.
 */
/datum/ai_movement/navmap_astar
	max_pathing_attempts = 20
	var/maximum_length = AI_MAX_PATH_LENGTH
	var/allow_multiz = FALSE
	///how we deal with diagonal movement, whether we try to avoid them or follow through with them
	var/diagonal_flags = DIAGONAL_REMOVE_CLUNKY

/datum/ai_movement/navmap_astar/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance, delay_override)
	. = ..()
	if(!.)
		return FALSE
	var/atom/movable/moving = controller.pawn
	var/delay = delay_override || controller.movement_delay

	var/datum/move_loop/loop = setup_moveloop(controller, current_movement_target, moving, delay, min_distance)

	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_NAVMAP_REPATH, PROC_REF(repath_incoming))

	return loop


/datum/ai_movement/navmap_astar/proc/setup_moveloop(datum/ai_controller/controller, atom/current_movement_target, atom/movable/moving, delay, min_distance)
	var/datum/move_loop/has_target/navmap_astar/loop = GLOB.move_manager.navmap_astar_move(moving,
		current_movement_target,
		delay,
		repath_delay = 0.1 SECONDS,
		simulated_only = !HAS_TRAIT(controller.pawn, TRAIT_SPACEWALK),
		max_path_length = maximum_length,
		minimum_distance = min_distance,
		access = controller.get_access(),
		subsystem = SSai_movement,
		skip_first = TRUE,
		diagonal_handling = diagonal_flags,
		allow_multiz = allow_multiz,
		max_path_cost = allow_multiz ? maximum_length * 10 : 0,
		extra_info = controller,
	)
	return loop

/datum/ai_movement/navmap_astar/update_movement_target(datum/ai_controller/controller, atom/new_target)
	. = ..()
	var/datum/move_loop/has_target/navmap_astar/loop = GLOB.move_manager.processing_on(controller.pawn, SSai_movement)
	if(loop)
		INVOKE_ASYNC(loop, TYPE_PROC_REF(/datum/move_loop/has_target/navmap_astar, recalculate_path))

/datum/ai_movement/navmap_astar/proc/repath_incoming(datum/move_loop/has_target/navmap_astar/source)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = source.extra_info

	source.access = controller.get_access()

/datum/ai_movement/navmap_astar/bot
	max_pathing_attempts = 8
	maximum_length = 25
	diagonal_flags = DIAGONAL_REMOVE_ALL
	allow_multiz = TRUE

/datum/ai_movement/navmap_astar/monkey
	allow_multiz = TRUE

/datum/ai_movement/navmap_astar/bot/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance, delay_override)
	var/datum/move_loop/loop = ..()
	var/atom/our_pawn = controller.pawn
	if(isnull(our_pawn))
		return null
	our_pawn.RegisterSignal(loop, COMSIG_MOVELOOP_NAVMAP_FINISHED_PATHING, TYPE_PROC_REF(/mob/living/basic/bot, generate_bot_path))
	return loop

/datum/ai_movement/navmap_astar/bot/summon
		maximum_length = AI_BOT_PATH_LENGTH

/datum/ai_movement/navmap_astar/bot/travel_to_beacon
	maximum_length = AI_BOT_PATH_LENGTH
	max_pathing_attempts = 10


/datum/ai_movement/navmap_astar/bot/mulebot
	max_pathing_attempts = 10
	maximum_length = AI_MULEBOT_PATH_LENGTH

/datum/ai_movement/navmap_astar/bot/mulebot/setup_moveloop(datum/ai_controller/controller, atom/current_movement_target, atom/movable/moving, delay, min_distance)
	var/datum/move_loop/has_target/navmap_astar/frustrations/loop = GLOB.move_manager.navmap_frustrations_move(moving,
		current_movement_target,
		delay,
		repath_delay = 0.5 SECONDS,
		simulated_only = !HAS_TRAIT(controller.pawn, TRAIT_SPACEWALK),
		max_path_length = maximum_length,
		minimum_distance = min_distance,
		access = controller.get_access(),
		subsystem = SSai_movement,
		skip_first = TRUE,
		diagonal_handling = diagonal_flags,
		extra_info = controller,
	)
	return loop

/datum/ai_movement/navmap_astar/bot/mulebot/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	var/datum/move_loop/loop = ..()
	var/atom/our_pawn = controller.pawn
	our_pawn.RegisterSignal(loop, COMSIG_MOVELOOP_NAVMAP_FRUSTRATION_INCREMENTED, TYPE_PROC_REF(/mob/living/basic/bot/mulebot, handle_buzzing))
