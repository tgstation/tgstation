/// This element hooks a signal onto the loc the current object is on.
/// When the object moves, it will unhook the signal and rehook it to the new object.
/datum/element/connect_loc
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections

	/// A list of everything with this element so that it can be tracked during ChangeTurf.
	var/list/targets

/datum/element/connect_loc/Attach(datum/target, list/connections)
	. = ..()
	if (!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.connections = connections

	LAZYADD(targets, target)

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	update_signals(target)

/datum/element/connect_loc/Detach(datum/source, force)
	. = ..()

	if (!ismovable(source))
		return

	var/atom/movable/movable_source = source

	if (!isnull(movable_source.loc))
		unregister_signals(source, movable_source.loc)

	LAZYREMOVE(targets, source)

/datum/element/connect_loc/proc/update_signals(atom/movable/target)
	if (isnull(target.loc))
		return

	for (var/signal in connections)
		target.RegisterSignal(target.loc, signal, connections[signal])

	if (isturf(target.loc))
		// override is fine, it just means multiple `connect_loc`s are on the same turf.
		RegisterSignal(target.loc, COMSIG_TURF_CHANGE, .proc/on_turf_change, override = TRUE)

/datum/element/connect_loc/proc/unregister_signals(atom/movable/target, atom/old_loc)
	for (var/signal in connections)
		target.UnregisterSignal(old_loc, signal)

	if (isturf(old_loc))
		// Only unregister this signal once no other target needs it.
		for (var/atom/movable/on_old_location in old_loc)
			if (on_old_location in targets && on_old_location != target)
				return

		UnregisterSignal(old_loc, COMSIG_TURF_CHANGE)

/datum/element/connect_loc/proc/on_moved(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER

	if (!isnull(old_loc))
		unregister_signals(source, old_loc)

	update_signals(source)

/datum/element/connect_loc/proc/on_turf_change(
	turf/source,
	path,
	new_baseturfs,
	flags,
	list/post_change_callbacks,
)
	SIGNAL_HANDLER

	post_change_callbacks += CALLBACK(src, .proc/post_turf_change)

/datum/element/connect_loc/proc/post_turf_change(turf/new_turf, turf/old_turf)
	for (var/atom/movable/target as anything in targets)
		if (target.loc != new_turf)
			continue

		unregister_signals(target, old_turf)
		update_signals(target)
