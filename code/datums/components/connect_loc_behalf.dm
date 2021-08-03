/// This element behaves the same as connect_loc, hooking into a signal on a tracked object's turf
/// It has the ability to react to that signal on behalf of a seperate listener however
/// This has great use, primarially for components, but it carries with it some overhead
/// So we do it seperately rather then intigrating the behavior with the main element
/datum/component/connect_loc_behalf
	dupe_mode = COMPONENT_DUPE_SELECTIVE

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections

	var/atom/movable/tracked

	var/atom/signal_atom

/datum/component/connect_loc_behalf/Initialize(atom/movable/tracked, list/connections)
	. = ..()
	if (!istype(tracked))
		return COMPONENT_INCOMPATIBLE
	src.connections = connections
	src.tracked = tracked

/datum/component/connect_loc_behalf/CheckDupeComponent(datum/component/component, atom/movable/tracked, list/connections)
	if(src.tracked != tracked)
		return

	// Not equivalent. Checks if they are the same list or not via shallow copy.
	if(src.connections ~! connections)
		return

	return TRUE


/datum/component/connect_loc_behalf/RegisterWithParent()
	src.connections = connections

	RegisterSignal(tracked, COMSIG_MOVABLE_MOVED, .proc/on_moved, override = TRUE)
	RegisterSignal(tracked, COMSIG_PARENT_QDELETING, .proc/handle_tracked_qdel)
	update_signals()

/datum/component/connect_loc_behalf/UnregisterFromParent()
	unregister_signals()
	UnregisterSignal(tracked, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_PARENT_QDELETING,
	))

	tracked = null

/datum/component/connect_loc_behalf/proc/handle_tracked_qdel()
	SIGNAL_HANDLER
	// We don't qdel ourself here because it's likely something is holding a reference to us.
	// We can get cleaned up when whatever is holding a reference to us gets deleted.
	unregister_signals()

/datum/component/connect_loc_behalf/proc/update_signals()
	unregister_signals()

	if(isnull(tracked.loc))
		return

	signal_atom = tracked.loc

	for (var/signal in connections)
		parent.RegisterSignal(signal_atom, signal, connections[signal])

/datum/component/connect_loc_behalf/proc/unregister_signals()
	if(isnull(signal_atom))
		return

	for (var/signal in connections)
		parent.UnregisterSignal(signal_atom, signal)

	signal_atom = null

/datum/component/connect_loc_behalf/proc/on_moved(atom/movable/tracked, atom/old_loc)
	SIGNAL_HANDLER
	update_signals()

