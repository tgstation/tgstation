/// Behaves similar to connect_loc_behalf, but hooks into signals on the perspective of the plane master group
/datum/component/connect_perspective
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/connections
	var/datum/plane_master_group/tracked

/datum/component/connect_perspective/Initialize(datum/plane_master_group/tracked, connections)
	. = ..()
	if(!istype(tracked))
		return COMPONENT_INCOMPATIBLE
	src.connections = connections
	src.tracked = tracked

/datum/component/connect_perspective/RegisterWithParent()
	RegisterSignal(tracked, COMSIG_PLANE_GROUP_PERSPECTIVE_CHANGED, PROC_REF(on_perspective_change))
	RegisterSignal(tracked, COMSIG_QDELETING, PROC_REF(handle_tracked_qdel))
	update_signals(null, tracked.get_perspective())

/datum/component/connect_perspective/UnregisterFromParent()
	update_signals(tracked.get_perspective(), null)
	UnregisterSignal(tracked, list(COMSIG_PLANE_GROUP_PERSPECTIVE_CHANGED, COMSIG_QDELETING))

/datum/component/connect_perspective/proc/handle_tracked_qdel()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/connect_perspective/proc/on_perspective_change(datum/source, atom/old_perspective, atom/new_perspective)
	SIGNAL_HANDLER
	update_signals(old_perspective, new_perspective)

/datum/component/connect_perspective/proc/update_signals(atom/old_perspective, atom/new_perspective)
	if(!isnull(old_perspective))
		parent.UnregisterSignal(old_perspective, connections)
	if(!isnull(new_perspective))
		for(var/signal in connections)
			parent.RegisterSignal(new_perspective, signal, connections[signal])
