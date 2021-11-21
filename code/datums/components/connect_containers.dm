/// This component behaves similar to connect_loc_behalf, but it's nested and hooks a signal onto all MOVABLES containing this atom.
/datum/component/connect_containers
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections
	var/atom/movable/tracked

/datum/component/connect_containers/Initialize(atom/movable/tracked, list/connections)
	. = ..()
	if (!ismovable(tracked))
		return COMPONENT_INCOMPATIBLE

	src.connections = connections
	src.tracked = tracked

/datum/component/connect_containers/InheritComponent(datum/component/component, original, atom/movable/tracked, list/connections)
	// Not equivalent. Checks if they are not the same list via shallow comparison.
	if(!compare_list(src.connections, connections))
		return
	if(src.tracked != tracked)
		set_tracked(tracked)

/datum/component/connect_containers/RegisterWithParent()
	set_tracked(tracked, TRUE)

/datum/component/connect_containers/UnregisterFromParent()
	set_tracked(null)

/datum/component/connect_containers/proc/set_tracked(atom/movable/new_tracked, first_run = FALSE)
	if(tracked && !first_run)
		UnregisterSignal(tracked, COMSIG_MOVABLE_MOVED)
		unregister_signals(tracked.loc)
	tracked = new_tracked
	if(!tracked)
		return
	RegisterSignal(tracked, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	update_signals(tracked)

/datum/component/connect_containers/proc/update_signals(atom/movable/listener)
	if(!ismovable(listener.loc))
		return

	for(var/atom/movable/container as anything in get_nested_locs(listener))
		RegisterSignal(container, COMSIG_MOVABLE_MOVED, .proc/on_moved)
		for(var/signal in connections)
			parent.RegisterSignal(container, signal, connections[signal])

/datum/component/connect_containers/proc/unregister_signals(atom/movable/location)
	if(!ismovable(location))
		return

	var/list/movables_to_unregister = get_nested_locs(location) + location
	for(var/atom/movable/target as anything in movables_to_unregister)
		UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
		for(var/signal in connections)
			parent.UnregisterSignal(target, signal)

/datum/component/connect_containers/proc/on_moved(atom/movable/listener, atom/old_loc)
	SIGNAL_HANDLER
	unregister_signals(old_loc)
	update_signals(listener)
