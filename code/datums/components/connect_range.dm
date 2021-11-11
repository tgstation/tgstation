/**
 * This component behaves similar to connect_loc_behalf but for all turfs in range, hooking into a signal on each of them.
 * Just like connect_loc_behalf, It can react to that signal on behalf of a seperate listener.
 * Good for components, though it carries some overhead. Can't be an element as that may lead to bugs.
 */
/datum/component/connect_range
	dupe_mode = COMPONENT_DUPE_SELECTIVE

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections
	var/atom/tracked

	/// The component will hook into signals only on turfs not farther from tracked than this.
	var/range
	/// Whether the component works when the movable isn't directly located on a turf.
	var/works_in_containers

/datum/component/connect_range/Initialize(atom/tracked, list/connections, range, works_in_containers = TRUE)
	if(!isatom(tracked) || isarea(tracked) || range <= 0)
		return COMPONENT_INCOMPATIBLE
	src.connections = connections
	src.tracked = tracked
	src.range = range
	src.works_in_containers = works_in_containers

/datum/component/connect_range/CheckDupeComponent(datum/component/component, atom/movable/tracked, list/connections, range, works_in_containers)
	if(src.tracked != tracked)
		return FALSE

	// Not equivalent. Checks if they are not the same list via shallow comparison.
	if(!compare_list(src.connections, connections))
		return FALSE

	if(src.range != range) //Update the range
		src.range = range
		update_signals(tracked, tracked.loc, TRUE)

	return TRUE

/datum/component/connect_range/RegisterWithParent()
	RegisterSignal(tracked, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	RegisterSignal(tracked, COMSIG_PARENT_QDELETING, .proc/handle_tracked_qdel)
	update_signals(tracked)

/datum/component/connect_range/UnregisterFromParent()
	unregister_signals(tracked)
	UnregisterSignal(tracked, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_PARENT_QDELETING,
	))

	tracked = null

/datum/component/connect_range/proc/handle_tracked_qdel()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/connect_range/proc/update_signals(atom/movable/movable, atom/old_loc, forced = FALSE)
	var/turf/tracked_turf = get_turf(movable)
	var/same_turf = !forced && tracked_turf == get_turf(old_loc) //Only register/unregister turf signals if it's moved to a new turf.
	unregister_signals(old_loc, same_turf)

	if(isnull(tracked_turf))
		return

	var/is_on_turf = tracked_turf == movable.loc
	if(!is_on_turf && !works_in_containers) //the component doesn't register signals while inside other movables.
		return

	if(tracked_turf != movable && !is_on_turf) //the tracked atom is not a turf and is inside another movable.
		for(var/atom/movable/container as anything in get_nested_locs(movable))
			RegisterSignal(container, COMSIG_MOVABLE_MOVED, .proc/on_moved)

	if(!same_turf)
		for(var/turf/target_turf in RANGE_TURFS(range, tracked_turf))
			for (var/signal in connections)
				parent.RegisterSignal(target_turf, signal, connections[signal])

/datum/component/connect_range/proc/unregister_signals(atom/location, same_turf = FALSE)
	//The location is null or is a container and the component shouldn't have register signals on it
	if(isnull(location) || (!works_in_containers && !isturf(location)))
		return

	if(ismovable(location))
		UnregisterSignal(location, COMSIG_MOVABLE_MOVED)
		for(var/atom/movable/container as anything in get_nested_locs(location))
			UnregisterSignal(container, COMSIG_MOVABLE_MOVED)

	if(!same_turf)
		var/turf/tracked_turf = get_turf(location)
		for(var/turf/target_turf in RANGE_TURFS(range, tracked_turf))
			parent.UnregisterSignal(target_turf, connections)

/datum/component/connect_range/proc/on_moved(atom/movable/movable, atom/old_loc)
	SIGNAL_HANDLER
	update_signals(movable, old_loc)
