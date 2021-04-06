/// This element hooks a signal onto the loc the current object is on.
/// When the object moves, it will unhook the signal and rehook it to the new object.
/datum/element/connect_loc
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections

/datum/element/connect_loc/Attach(datum/target, list/connections)
	. = ..()
	if (!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.connections = connections

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	RegisterSignal(target, COMSIG_MOVABLE_TURF_CHANGED, .proc/on_turf_changed)
	update_signals(target)

/datum/element/connect_loc/Detach(datum/source, force)
	. = ..()

	if (!ismovable(source))
		return

	var/atom/movable/movable_source = source

	if (!isnull(movable_source.loc))
		unregister_signals(source, movable_source.loc)

	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_TURF_CHANGED))

/datum/element/connect_loc/proc/update_signals(atom/movable/target)
	if (isnull(target.loc))
		return

	for (var/signal in connections)
		target.RegisterSignal(target.loc, signal, connections[signal])

/datum/element/connect_loc/proc/unregister_signals(atom/movable/target, atom/old_loc)
	for (var/signal in connections)
		target.UnregisterSignal(old_loc, signal)

/datum/element/connect_loc/proc/on_moved(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER

	if (!isnull(old_loc))
		unregister_signals(source, old_loc)

	update_signals(source)

/datum/element/connect_loc/proc/on_turf_changed(atom/movable/source, turf/old_turf)
	SIGNAL_HANDLER

	unregister_signals(source, old_turf)
	update_signals(source)
