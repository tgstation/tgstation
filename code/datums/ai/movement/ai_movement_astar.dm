/**
 * This movement datum represents astar pathing (Proper obstacle avoidance)
 */
/datum/ai_movement/astar
	max_pathing_attempts = 20

	/// If FALSE, diagonals will be split into 2 cardinal moves.
	var/use_diagonals = TRUE
	///Max length of the path
	var/maximum_length = AI_MAX_PATH_LENGTH


/datum/ai_movement/astar/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/delay = controller.movement_delay

	var/datum/move_loop/loop = GLOB.move_manager.astar_move(
		moving,
		current_movement_target,
		delay,
		repath_delay = 0.5 SECONDS,
		max_path_length = maximum_length,
		minimum_distance = controller.get_minimum_distance(),
		access = controller.get_access(),
		simulated_only = !HAS_TRAIT(controller.pawn, TRAIT_FREE_FLOAT_MOVEMENT),
		subsystem = SSai_movement,
		extra_info = controller,
		use_diagonals = use_diagonals,
	)

	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_REPATH, PROC_REF(repath_incoming))

/datum/ai_movement/astar/proc/repath_incoming(datum/move_loop/has_target/astar/source)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = source.extra_info

	source.access = controller.get_access()
	source.minimum_distance = controller.get_minimum_distance()

/datum/ai_movement/astar/bot
	max_pathing_attempts = 8
	maximum_length = 25
	use_diagonals = FALSE

/datum/ai_movement/astar/bot/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	var/datum/move_loop/loop = ..()
	var/atom/our_pawn = controller.pawn
	if(isnull(our_pawn))
		return
	our_pawn.RegisterSignal(loop, COMSIG_MOVELOOP_FINISHED_PATHING, TYPE_PROC_REF(/mob/living/basic/bot, generate_bot_path))

/datum/ai_movement/astar/bot/travel_to_beacon
	maximum_length = AI_BOT_PATH_LENGTH
	max_pathing_attempts = 10
