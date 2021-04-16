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

	RegisterSignal(tracked, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	update_signals(listener, tracked)

/datum/element/connect_loc/Detach(datum/listener, atom/movable/tracked, list/connections)
	. = ..()

	if(!tracked)
		tracked = listener

	if(!istype(tracked))
		return

	if (!isnull(tracked.loc))
		unregister_signals(listener, tracked, tracked.loc)

	UnregisterSignal(tracked, COMSIG_MOVABLE_MOVED)

/datum/element/connect_loc/proc/update_signals(datum/listener, atom/movable/tracked)
	var/existing = length(targets[tracked.loc])
	LAZYSET(targets[tracked.loc], tracked, listener)

	if (isnull(tracked.loc))
		return

	for (var/signal in connections)
		listener.RegisterSignal(tracked.loc, signal, connections[signal])

	if (!existing && isturf(tracked.loc))
		RegisterSignal(tracked.loc, COMSIG_TURF_CHANGE, .proc/on_turf_change)

/datum/element/connect_loc/proc/unregister_signals(datum/listener, atom/movable/tracked, atom/old_loc)
	targets[old_loc] -= tracked
	if (length(targets[old_loc]) == 0)
		targets -= old_loc

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
	for (var/atom/movable/tracked as anything in targets[new_turf])
		var/datum/listener = targets[new_turf][tracked]
		update_signals(listener, tracked)
