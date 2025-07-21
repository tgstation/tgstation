/// Behaves similarly to `connect_containers`, but allows a single parent to register different connections for multiple targets.
/datum/component/multi_connect_containers
	dupe_mode = COMPONENT_DUPE_SOURCES

	/// An assoc-list of targets to registered signals.
	var/list/atom/movable/tracked

	/// An assoc-list of movables to the targets they contain.
	var/list/tracked_by_listener

	/// An assoc-list of identifiers (formatted as "sigtype:procname") to callback wrappers.
	var/list/callback_wrappers

/datum/component/multi_connect_containers/Destroy(force)
	for(var/atom/movable/movable in tracked)
		remove_tracked(movable)
	return ..()

/datum/component/multi_connect_containers/on_source_add(source, connections)
	. = ..()
	var/atom/movable/movable = locate(source)
	if(!istype(movable))
		return COMPONENT_INCOMPATIBLE
	add_tracked(movable, connections)

/datum/component/multi_connect_containers/on_source_remove(source)
	. = ..()
	var/atom/movable/movable = locate(source)
	if(!istype(movable))
		return
	remove_tracked(movable)

/datum/component/multi_connect_containers/proc/add_tracked(atom/movable/target, list/connections)
	if(!LAZYACCESS(tracked, target))
		RegisterSignal(tracked, COMSIG_QDELETING, PROC_REF(on_tracked_deleted))
	LAZYORASSOCLIST(tracked, target, connections)
	update_signals(target, target)

/datum/component/multi_connect_containers/proc/remove_tracked(atom/movable/target)
	remove_signals(target, target)
	UnregisterSignal(target, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	LAZYREMOVE(tracked, target)

/datum/component/multi_connect_containers/proc/on_tracked_deleted(datum/source)
	SIGNAL_HANDLER
	on_source_remove(REF(source))

/datum/component/multi_connect_containers/proc/update_signals(atom/movable/listener, atom/movable/target)
	if(!ismovable(listener))
		return
	var/list/connections = LAZYACCESS(tracked, target)
	if(!connections)
		return

	for(var/atom/movable/container as anything in (get_nested_locs(listener) + listener))
		if(!LAZYACCESS(tracked_by_listener, container))
			RegisterSignal(container, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
		LAZYORASSOCLIST(tracked_by_listener, container, target)
		for(var/signal in connections)
			var/procname = connections[signal]
			var/identifier = "[signal]:[procname]"
			if(LAZYACCESS(callback_wrappers, identifier))
				continue
			LAZYADDASSOC(callback_wrappers, "[signal]:[procname]", new /datum/callback_wrapper_for_signal_handling(target, signal, parent, procname))


/datum/component/multi_connect_containers/proc/remove_signals(atom/movable/listener, atom/movable/target)
	if(!ismovable(listener))
		return
	var/list/connections = LAZYACCESS(tracked, target)
	if(!connections)
		return

	for(var/atom/movable/container as anything in (get_nested_locs(listener) + listener))
		var/list/tracked_in_container = tracked_by_listener[listener]
		for(var/signal in connections)
			var/procname = connections[signal]
			var/identifier = "[signal]:[procname]"
			var/datum/callback_wrapper_for_signal_handling/wrapper = LAZYACCESS(callback_wrappers, identifier)
			qdel(wrapper)
			LAZYREMOVE(callback_wrappers, identifier)
		tracked_in_container -= target
		if(!length(tracked_in_container))
			LAZYREMOVE(tracked_by_listener, container)
			UnregisterSignal(container, COMSIG_MOVABLE_MOVED)

/datum/component/multi_connect_containers/proc/on_moved(atom/movable/source, atom/old_loc)
	var/list/tracked_in_source = LAZYACCESS(tracked_by_listener, source)
	if(!tracked_in_source)
		return
	for(var/atom/movable/target as anything in tracked_in_source)
		if(ismovable(old_loc))
			remove_signals(old_loc, target)
		if(ismovable(source.loc))
			update_signals(source, target)
