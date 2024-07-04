//a simple element that listens for passed signals and then returns based on if get_turf's type is within valid_turfs, if you need more then use the /complex subtype
/datum/component/turf_checker
	dupe_mode = COMPONENT_DUPE_ALLOWED
	///list of turf types that are valid for us
	var/list/valid_turfs
	///the signal we listen for
	var/registered_signal
	///do we listen for COMSIG_MOVABLE_MOVED
	var/check_on_move
	///our last validity state, used to save on checks
	var/last_validity_state = FALSE
	///a ref to the loc that we listen to the movement of to send our signals
	var/atom/watched_holder
	///our parent's recursive locs minus it and watched_holder
	var/list/trimmed_recursive_locs

/**
 * valid_turfs - the list of turf types that are valid for when we check
 * registered_signal - the signal from parent we listen for to call on_signal_recieved()
 * check_on_move - should we check turf every time our parent calls Moved()
 * update_state_proc - proc for parent to call when we send COMSIG_TURF_CHECKER_UPDATE_STATE
 * register_loc - should we listen to Moved() on locs of our parent as well
 */
/datum/component/turf_checker/Initialize(list/valid_turfs, registered_signal, check_on_move = FALSE, update_state_proc, register_loc = TRUE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.valid_turfs = valid_turfs
	src.registered_signal = registered_signal
	src.check_on_move = check_on_move
	if(update_state_proc && check_on_move)
		parent.RegisterSignal(src, COMSIG_TURF_CHECKER_UPDATE_STATE, update_state_proc)

/datum/component/turf_checker/RegisterWithParent()
	if(registered_signal)
		RegisterSignal(parent, registered_signal, PROC_REF(on_signal_recieved))

	if(check_on_move)
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_attached_moved))
		trimmed_recursive_locs = list()
		get_new_locs(parent)
	check_turf(parent)

/datum/component/turf_checker/UnregisterFromParent()
	if(registered_signal)
		UnregisterSignal(parent, registered_signal)

	if(check_on_move)
		parent.UnregisterSignal(src, COMSIG_TURF_CHECKER_UPDATE_STATE)
		UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

	if(watched_holder != parent)
		UnregisterSignal(watched_holder, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_ATOM_ABSTRACT_EXITED))

	for(var/atom/recursive_loc in trimmed_recursive_locs)
		UnregisterSignal(recursive_loc, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

	parent = null
	watched_holder = null
	trimmed_recursive_locs = null

/datum/component/turf_checker/proc/on_signal_recieved(atom/movable/checked_atom, atom/movable/check_override, do_check_turf = TRUE, register_to, unregister_from)
	SIGNAL_HANDLER
	if(register_to) //keeping these here in case your use case can handle this on the attached atom in a cheaper way than the /complex subtype
		RegisterSignal(register_to, COMSIG_MOVABLE_MOVED, PROC_REF(check_turf_parent_only))

	if(unregister_from)
		UnregisterSignal(unregister_from, COMSIG_MOVABLE_MOVED)

	if(do_check_turf)
		return check_turf(checked_atom, check_override)

//so we dont override checked_atom with old_loc
/datum/component/turf_checker/proc/check_turf_parent_only(atom/movable/checked_atom)
	SIGNAL_HANDLER
	check_turf(checked_atom)

/datum/component/turf_checker/proc/check_turf(atom/movable/checked_atom, atom/movable/check_override)
	SIGNAL_HANDLER
	if(check_override)
		checked_atom = check_override

	var/turf/checked_turf_type = get_turf(checked_atom)
	if(!checked_turf_type)
		return COMPONENT_CHECKER_INVALID_TURF

	checked_turf_type = checked_turf_type.type
	if(!(checked_turf_type in valid_turfs))
		if(check_on_move && last_validity_state)
			last_validity_state = FALSE
			SEND_SIGNAL(src, COMSIG_TURF_CHECKER_UPDATE_STATE, FALSE, checked_atom)
		return COMPONENT_CHECKER_INVALID_TURF

	if(check_on_move && !last_validity_state)
		last_validity_state = TRUE
		SEND_SIGNAL(src, COMSIG_TURF_CHECKER_UPDATE_STATE, TRUE, checked_atom)
	return COMPONENT_CHECKER_VALID_TURF

/datum/component/turf_checker/proc/get_new_locs()
	if(QDELETED(parent))
		return

	var/atom/movable/movable_parent = parent
	var/list/attached_locs = movable_parent.get_locs_recursive()
	var/atom/highest_holder = attached_locs[length(attached_locs)]
	if(highest_holder == parent && watched_holder == parent)
		return

	var/list/old_recursive_locs = trimmed_recursive_locs
	trimmed_recursive_locs = list()
	if(watched_holder != highest_holder)
		if(watched_holder != parent)
			UnregisterSignal(watched_holder, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_ABSTRACT_EXITED, COMSIG_QDELETING))

		if(highest_holder != parent)
			watched_holder = highest_holder
			RegisterSignal(highest_holder, COMSIG_MOVABLE_MOVED, PROC_REF(check_turf_parent_only))
			RegisterSignal(highest_holder, COMSIG_ATOM_ABSTRACT_EXITED, PROC_REF(on_holder_exited))
			RegisterSignal(highest_holder, COMSIG_QDELETING, PROC_REF(on_loc_qdeleted))
			if(length(attached_locs) > 2)
				trimmed_recursive_locs = attached_locs - list(attached_locs[1], highest_holder)
				for(var/atom/recursive_loc in trimmed_recursive_locs)
					if(!QDELETED(recursive_loc))
						if(recursive_loc in old_recursive_locs)
							old_recursive_locs -= recursive_loc
						else
							RegisterSignal(recursive_loc, COMSIG_MOVABLE_MOVED, PROC_REF(check_holder))
							RegisterSignal(recursive_loc, COMSIG_QDELETING, PROC_REF(on_loc_qdeleted))
		else
			watched_holder = parent

	for(var/atom/old_recursive_loc in old_recursive_locs)
		UnregisterSignal(old_recursive_loc, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

/datum/component/turf_checker/proc/check_holder(atom/movable/moved)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	if(movable_parent.get_highest_non_turf_loc() != watched_holder)
		get_new_locs()

/datum/component/turf_checker/proc/on_attached_moved(atom/movable/moved, atom/old_loc)
	SIGNAL_HANDLER
	if(watched_holder == parent)
		var/atom/movable/movable_parent = parent
		if(movable_parent.get_highest_non_turf_loc() == parent)
			check_turf(moved)
			return

	get_new_locs()
	check_turf(moved)

/datum/component/turf_checker/proc/on_holder_exited(atom/exited, atom/movable/gone)
	SIGNAL_HANDLER
	var/atom/movable/movable_parent = parent
	if(gone == parent || movable_parent.get_highest_non_turf_loc() != watched_holder)
		get_new_locs()
		check_turf(parent)

/datum/component/turf_checker/proc/on_loc_qdeleted(atom/destroyed, forced)
	SIGNAL_HANDLER
	UnregisterSignal(destroyed, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	if(destroyed == watched_holder)
		UnregisterSignal(destroyed, COMSIG_ATOM_ABSTRACT_EXITED)
		watched_holder = null
	else
		trimmed_recursive_locs -= destroyed
	get_new_locs()
