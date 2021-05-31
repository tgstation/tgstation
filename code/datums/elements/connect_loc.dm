/// This element hooks a signal onto the loc the current object is on.
/// When the object moves, it will unhook the signal and rehook it to the new object.
/datum/element/connect_loc
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH | ELEMENT_COMPLEX_DETACH
	id_arg_index = 3

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections

	/// An assoc list of locs that are being occupied and a list of targets that occupy them.
	var/list/targets = list()

	/// The callback used when the turf under the tracked object changes
	var/datum/callback/changeturf_callback

/datum/element/connect_loc/New()
	. = ..()
	changeturf_callback = CALLBACK(src, .proc/post_turf_change)

/datum/element/connect_loc/Attach(datum/listener, atom/movable/tracked, list/connections)
	. = ..()
	if (!istype(tracked))
		return ELEMENT_INCOMPATIBLE

	src.connections = connections

	RegisterSignal(tracked, COMSIG_MOVABLE_MOVED, .proc/on_moved, override = TRUE)
	update_signals(listener, tracked)

/datum/element/connect_loc/Detach(datum/listener, atom/movable/tracked, list/connections)
	. = ..()

	if(!tracked)
		unregister_all(listener)
	else if(targets[tracked.loc]) // Detach can happen multiple times due to qdel
		unregister_signals(listener, tracked, tracked.loc)
		UnregisterSignal(tracked, COMSIG_MOVABLE_MOVED)

/datum/element/connect_loc/proc/update_signals(datum/listener, atom/movable/tracked)
	var/existing = length(targets[tracked.loc])
	if(!existing)
		targets[tracked.loc] = list()
	targets[tracked.loc][tracked] = listener

	if(isnull(tracked.loc))
		return

	for (var/signal in connections)
		listener.RegisterSignal(tracked.loc, signal, connections[signal], override=TRUE)
		//override=TRUE because more than one connect_loc element instance tracked object can be on the same loc

	if (!existing && isturf(tracked.loc))
		RegisterSignal(tracked.loc, COMSIG_TURF_CHANGE, .proc/on_turf_change)

/datum/element/connect_loc/proc/unregister_all(datum/listener)
	for(var/atom/location as anything in targets)
		var/list/loc_targets = targets[location]
		for(var/atom/movable/tracked as anything in loc_targets)
			if(tracked == listener)
				unregister_signals(loc_targets[tracked], tracked, location)
			else if(loc_targets[tracked] == listener)
				unregister_signals(listener, tracked, location)
			else
				continue
			UnregisterSignal(tracked, COMSIG_MOVABLE_MOVED)

/datum/element/connect_loc/proc/unregister_signals(datum/listener, atom/movable/tracked, atom/old_loc)
	if (length(targets[old_loc]) <= 1)
		targets -= old_loc
	else
		targets[old_loc] -= tracked

	// Yes this is after the above because we use null as a key when objects are in nullspace
	if(isnull(old_loc))
		return

	for (var/signal in connections)
		listener.UnregisterSignal(old_loc, signal)

	if (!targets[old_loc] && isturf(old_loc))
		UnregisterSignal(old_loc, COMSIG_TURF_CHANGE)

/datum/element/connect_loc/proc/on_moved(atom/movable/tracked, atom/old_loc)
	SIGNAL_HANDLER

	var/datum/listener = targets[old_loc][tracked]
	unregister_signals(listener, tracked, old_loc)
	update_signals(listener, tracked)

/datum/element/connect_loc/proc/on_turf_change(
	turf/source,
	path,
	new_baseturfs,
	flags,
	list/post_change_callbacks,
)
	SIGNAL_HANDLER

	post_change_callbacks += changeturf_callback

/datum/element/connect_loc/proc/post_turf_change(turf/new_turf)
	// If we don't cut the targets list before iterating,
	// then we won't re-register the change turf signal.
	var/list/turf_targets = targets[new_turf]
	var/list/targets_copy = turf_targets.Copy()
	turf_targets.Cut()

	for (var/atom/movable/tracked as anything in targets_copy)
		var/datum/listener = targets_copy[tracked]
		update_signals(listener, tracked)
