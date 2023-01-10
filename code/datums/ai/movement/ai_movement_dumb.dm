///The most brain-dead type of movement, bee-line to the target with no concern of whats in front of us.
/datum/ai_movement/dumb
	max_pathing_attempts = 16

///Put your movement behavior in here!
/datum/ai_movement/dumb/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/delay = controller.movement_delay
	var/datum/move_loop/loop = SSmove_manager.move_towards_legacy(moving, current_movement_target, delay, subsystem = SSai_movement, extra_info = controller)
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))

/datum/ai_movement/dumb/allowed_to_move(datum/move_loop/has_target/source)
	. = ..()
	var/turf/target_turf = get_step_towards(source.moving, source.target)

	if(is_type_in_typecache(target_turf, GLOB.dangerous_turfs))
		. = FALSE
	return .
