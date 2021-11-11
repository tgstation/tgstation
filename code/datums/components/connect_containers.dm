/// This component behaves similar to connect_loc_behalf, but it's nested and hooks a signal onto all MOVABLES containing this atom.
/datum/component/connect_containers
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections
	var/atom/movable/tracked

/datum/component/connect_containers/Initialize(atom/movable/tracked, list/connections)
	. = ..()
	if (!istype(parent))
		return COMPONENT_INCOMPATIBLE

	src.connections = connections
	src.tracked = tracked

/datum/component/connect_containers/RegisterWithParent()
	RegisterSignal(tracked, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	update_signals(tracked)

/datum/component/connect_containers/UnregisterFromParent()
	unregister_signals(tracked)
	tracked = null

/datum/component/connect_containers/proc/update_signals(atom/movable/listener)
	if(!ismovable(listener.loc))
		return

	for(var/atom/movable/container as anything in get_nested_locs(listener))
		RegisterSignal(container, COMSIG_MOVABLE_MOVED, .proc/on_moved)
		for (var/signal in connections)
			parent.RegisterSignal(container, signal, connections[signal])

/datum/component/connect_containers/proc/unregister_signals(atom/movable/location)
	if(!ismovable(location))
		return

	UnregisterSignal(location, COMSIG_MOVABLE_MOVED)
	for(var/atom/movable/container as anything in get_nested_locs(location))
		UnregisterSignal(container, COMSIG_MOVABLE_MOVED)
		parent.UnregisterSignal(container, connections)

/datum/component/connect_containers/proc/on_moved(atom/movable/listener, atom/old_loc)
	SIGNAL_HANDLER
	unregister_signals(old_loc)
	update_signals(listener)
