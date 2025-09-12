// This component allows for certain movement checks, particularly those involving linked atoms existing on the same z-level, to be deferred when a shuttle moves.
/datum/component/shuttle_move_deferred_checks
	dupe_mode = COMPONENT_DUPE_SOURCES
	/// An list of targets to listen for the movements of
	var/list/targets = list()

	/// The check to call on the parent when a target moves. Can be the name of a proc on the parent, or a `/datum/callback`.
	var/check

	/// A list of each target currently being moved by a shuttle - if this list is not empty, checks will not be run.
	var/list/moving_targets = list()

/datum/component/shuttle_move_deferred_checks/Initialize(check)
	. = ..()
	if(!check)
		return COMPONENT_INCOMPATIBLE
	src.check = check

/datum/component/shuttle_move_deferred_checks/Destroy(force)
	targets = null
	check = null
	moving_targets = null
	return ..()

/datum/component/shuttle_move_deferred_checks/on_source_add(source, check)
	. = ..()
	var/atom/movable/movable = locate(source)
	if(!istype(movable) || (check != src.check))
		return COMPONENT_INCOMPATIBLE
	targets += movable
	RegisterSignal(movable, COMSIG_MOVABLE_MOVED, PROC_REF(on_target_moved))
	RegisterSignal(movable, COMSIG_ATOM_BEFORE_SHUTTLE_MOVE, PROC_REF(before_target_shuttle_move))
	RegisterSignal(movable, COMSIG_ATOM_AFTER_SHUTTLE_MOVE, PROC_REF(after_target_shuttle_move))
	RegisterSignal(movable, COMSIG_QDELETING, PROC_REF(on_target_deleted))

/datum/component/shuttle_move_deferred_checks/on_source_remove(source)
	var/atom/movable/movable = locate(source)
	if(!istype(movable))
		return
	targets -= movable
	moving_targets -= movable
	UnregisterSignal(movable, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_BEFORE_SHUTTLE_MOVE, COMSIG_ATOM_AFTER_SHUTTLE_MOVE, COMSIG_QDELETING))
	if(!length(moving_targets) && length(targets))
		call_check()
	return ..()

/datum/component/shuttle_move_deferred_checks/proc/call_check()
	if(istype(check, /datum/callback))
		var/datum/callback/callback_check = check
		callback_check.Invoke()
	else
		call(parent, check)()

/datum/component/shuttle_move_deferred_checks/proc/on_target_moved(atom/movable/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(length(moving_targets))
		return
	call_check()

/datum/component/shuttle_move_deferred_checks/proc/before_target_shuttle_move(atom/source)
	SIGNAL_HANDLER
	moving_targets |= source

/datum/component/shuttle_move_deferred_checks/proc/after_target_shuttle_move(atom/source)
	SIGNAL_HANDLER
	moving_targets -= source
	if(!length(moving_targets))
		call_check()

/datum/component/shuttle_move_deferred_checks/proc/on_target_deleted(datum/source)
	SIGNAL_HANDLER
	on_source_remove(REF(source))
