/datum/ai_movement/basic_avoidance/adaptive

/datum/ai_movement/basic_avoidance/adaptive/post_move(datum/move_loop/source, succeeded)
	. = ..()
	if (succeeded != MOVELOOP_FAILURE)
		return
	var/datum/ai_controller/controller = source.extra_info
	stop_moving_towards(controller)
	controller.change_ai_movement_type(/datum/ai_movement/jps/adaptive) // we failed? it's JPS time

/datum/ai_movement/jps/adaptive

/datum/ai_movement/jps/adaptive/post_move(datum/move_loop/source, succeeded)
	. = ..()
	var/datum/move_loop/has_target/jps/loop = source
	if (length(loop.movement_path))
		return
	var/datum/ai_controller/controller = source.extra_info
	if (loop.target in view(6, controller.pawn))
		stop_moving_towards(controller)
		controller.change_ai_movement_type(/datum/ai_movement/basic_avoidance/adaptive) // we succeeded? it's basic time
