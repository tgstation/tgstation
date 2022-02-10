///This datum is an abstract class that can be overriden for different types of movement
/datum/ai_movement
	///Assoc list ist of controllers that are currently moving as key, and what they are moving to as value
	var/list/moving_controllers = list()
	///How many times a given controller can fail on their route before they just give up
	var/max_pathing_attempts

//Override this to setup the moveloop you want to use
/datum/ai_movement/proc/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	SHOULD_CALL_PARENT(TRUE)
	if(allowed_to_move(controller))
		controller.pathing_attempts = 0
		controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE] = min_distance
		moving_controllers[controller] = current_movement_target

/datum/ai_movement/proc/stop_moving_towards(datum/ai_controller/controller)
	controller.pathing_attempts = 0
	moving_controllers -= controller
	SSmove_manager.stop_looping(controller.pawn, SSai_movement)

/datum/ai_movement/proc/increment_pathing_failures(datum/ai_controller/controller)
	controller.pathing_attempts++
	if(controller.pathing_attempts >= max_pathing_attempts)
		controller.CancelActions()

//Instead of copypasting/subtype and rewrite all the movement checks in pre_move() you can use this
/datum/ai_movement/proc/allowed_to_move(datum/move_loop/source)
	SIGNAL_HANDLER
	var/atom/movable/pawn = source.moving
	var/datum/ai_controller/controller = source.extra_info
	source.delay = controller.movement_delay

	var/can_move = TRUE
	if(controller.ai_traits & STOP_MOVING_WHEN_PULLED && pawn.pulledby) //Need to store more state. Annoying.
		can_move = FALSE

	if(controller.ai_traits & STOP_MOVING)
		can_move = FALSE

	if(ismob(pawn))
		var/mob/mob_pawn = pawn
		if(controller.ai_traits & STOP_MOVING_DURING_DO_AFTER && LAZYLEN(mob_pawn.do_afters))
			can_move = FALSE

	if(!isturf(pawn.loc)) //No moving if not on a turf
		can_move = FALSE

	// Check if this controller can actually run, so we don't chase people with corpses
	if(!controller.able_to_run())
		controller.CancelActions()
		qdel(source) //stop moving
		return MOVELOOP_SKIP_STEP

	if(can_move)
		return can_move
	increment_pathing_failures(controller)
	return MOVELOOP_SKIP_STEP

//Anything to do pre movement except checks which is handled by a different proc
/datum/ai_movement/proc/pre_move(datum/move_loop/source)
	return allowed_to_move(source)

//Anything to do post movement
/datum/ai_movement/proc/post_move(datum/move_loop/source, succeeded)
	SIGNAL_HANDLER
	if(succeeded)
		return
	var/datum/ai_controller/controller = source.extra_info
	increment_pathing_failures(controller)
