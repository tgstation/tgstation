/// This component behaves similar to connect_loc, hooking into a signal on a tracked object's turf
/// It has the ability to react to that signal on behalf of a separate listener however
/// This has great use, primarily for components, but it carries with it some overhead
/// So we do it separately as it needs to hold state which is very likely to lead to bugs if it remains as an element.
/datum/component/connect_loc_behalf
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections

	var/atom/movable/tracked

	var/atom/tracked_loc

/datum/component/connect_loc_behalf/Initialize(atom/movable/tracked, list/connections)
	. = ..()
	if (!istype(tracked))
		return COMPONENT_INCOMPATIBLE
	src.connections = connections
	src.tracked = tracked

/datum/component/connect_loc_behalf/RegisterWithParent()
	RegisterSignal(tracked, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(tracked, COMSIG_PARENT_QDELETING, PROC_REF(handle_tracked_qdel))
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
	qdel(src)

/datum/component/connect_loc_behalf/proc/update_signals()
	unregister_signals()
	//You may ask yourself, isn't this just silencing an error?
	//The answer is yes, but there's no good cheap way to fix it
	//What happens is the tracked object or hell the listener gets say, deleted, which makes targets[old_loc] return a null
	//The null results in a bad index, because of course it does
	//It's not a solvable problem though, since both actions, the destroy and the move, are sourced from the same signal send
	//And sending a signal should be agnostic of the order of listeners
	//So we need to either pick the order agnositic, or destroy safe
	//And I picked destroy safe. Let's hope this is the right path!
	if(isnull(tracked.loc))
		return

	tracked_loc = tracked.loc

	for (var/signal in connections)
		parent.RegisterSignal(tracked_loc, signal, connections[signal])

/datum/component/connect_loc_behalf/proc/unregister_signals()
	if(isnull(tracked_loc))
		return

	parent.UnregisterSignal(tracked_loc, connections)

	tracked_loc = null

/datum/component/connect_loc_behalf/proc/on_moved(sigtype, atom/movable/tracked, atom/old_loc)
	SIGNAL_HANDLER
	update_signals()

