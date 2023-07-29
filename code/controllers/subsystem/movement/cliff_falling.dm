/// Subsystem to handle falling of off cliffs
MOVEMENT_SUBSYSTEM_DEF(cliff_falling)
	name = "Cliff Falling"
	priority = FIRE_PRIORITY_CLIFF_FALLING
	flags = SS_NO_INIT|SS_TICKER
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	/// Who are currently falling and with which movemanager?
	var/list/cliff_grinders = list()

/datum/controller/subsystem/movement/cliff_falling/proc/start_falling(atom/movable/faller, turf/open/cliff/cliff)
	// Make them move
	var/mover = SSmove_manager.move(moving = faller, direction = cliff.fall_direction, delay = cliff.fall_speed, subsystem = src, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_OUTSIDE_CONTROL | MOVEMENT_LOOP_NO_DIR_UPDATE)

	cliff_grinders[faller] = mover

	RegisterSignal(faller, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(faller, COMSIG_QDELETING, PROC_REF(clear_references))
	RegisterSignal(faller, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_move))

/// We just moved, so check if we're still moving right
/datum/controller/subsystem/movement/cliff_falling/proc/on_moved(atom/movable/mover, turf/old_loc)
	SIGNAL_HANDLER

	var/turf/open/cliff/new_cliff = mover.loc
	if(!iscliffturf(new_cliff)) //not a cliff, lets clean up
		var/datum/move_loop/move/falling = cliff_grinders[mover]
		clear_references(mover)
		qdel(falling)
		return

	new_cliff.on_fall(mover)

	if(old_loc.type == new_cliff) //same type of cliff, no worries
		return

	var/datum/move_loop/move/fall = cliff_grinders[mover]
	fall.set_delay(new_cliff.fall_speed) //different cliff, so set the speed

/datum/controller/subsystem/movement/cliff_falling/proc/on_qdel(atom/movable/deletee)
	SIGNAL_HANDLER

	clear_references(deletee)

/datum/controller/subsystem/movement/cliff_falling/proc/clear_references(atom/movable/deletee)
	cliff_grinders -= deletee

	UnregisterSignal(deletee, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_MOVABLE_PRE_MOVE))

/// Check if we can move! We do this mostly to determine falling behaviour and make sure we're moving to valid tiles
/datum/controller/subsystem/movement/cliff_falling/proc/check_move(atom/movable/mover, turf/target)
	SIGNAL_HANDLER

	var/turf/open/cliff/cliff_turf = get_turf(mover)

	if(!iscliffturf(cliff_turf)) //we arent on a cliff, WHY ARE WE HERE???
		clear_references(mover)
		return

	if(!cliff_turf.can_move(mover, target))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
