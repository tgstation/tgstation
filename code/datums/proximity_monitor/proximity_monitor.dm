/datum/proximity_monitor
	///The atom we are tracking
	var/atom/host
	///The atom that will receive HasProximity calls.
	var/atom/hasprox_receiver
	///The range of the proximity monitor. Things moving wihin it will trigger HasProximity calls.
	var/current_range
	///If we don't check turfs in range if the host's loc isn't a turf
	var/ignore_if_not_on_turf
	///The signals of the connect range component, needed to monitor the turfs in range.
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
		COMSIG_ATOM_EXITED = .proc/on_uncrossed,
		COMSIG_ATOM_INITIALIZED_ON = .proc/on_entered,
	)

/datum/proximity_monitor/New(atom/_host, range, _ignore_if_not_on_turf = TRUE)
	ignore_if_not_on_turf = _ignore_if_not_on_turf
	current_range = range
	set_host(_host)

/datum/proximity_monitor/proc/set_host(atom/new_host, atom/new_receiver)
	if(new_host == host)
		return
	if(host) //No need to delete the connect range and containers comps. They'll be updated with the new tracked host.
		UnregisterSignal(host, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	if(hasprox_receiver)
		UnregisterSignal(hasprox_receiver, COMSIG_PARENT_QDELETING)
	if(new_receiver)
		hasprox_receiver = new_receiver
		if(new_receiver != new_host)
			RegisterSignal(new_receiver, COMSIG_PARENT_QDELETING, .proc/on_host_or_receiver_del)
	else if(hasprox_receiver == host) //Default case
		hasprox_receiver = new_host
	host = new_host
	RegisterSignal(new_host, COMSIG_PARENT_QDELETING, .proc/on_host_or_receiver_del)
	var/static/list/containers_connections = list(COMSIG_MOVABLE_MOVED = .proc/on_moved)
	AddComponent(/datum/component/connect_containers, host, containers_connections)
	RegisterSignal(host, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	set_range(current_range, TRUE)

/datum/proximity_monitor/proc/on_host_or_receiver_del(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/proximity_monitor/Destroy()
	host = null
	hasprox_receiver = null
	return ..()

/datum/proximity_monitor/proc/set_range(range, force_rebuild = FALSE)
	if(!force_rebuild && range == current_range)
		return FALSE
	. = TRUE
	current_range = range

	//If the connect_range component exists already, this will just update its range. No errors or duplicates.
	AddComponent(/datum/component/connect_range, host, loc_connections, range, !ignore_if_not_on_turf)

/datum/proximity_monitor/proc/on_moved(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	if(source == host)
		hasprox_receiver?.HasProximity(host)

/datum/proximity_monitor/proc/set_ignore_if_not_on_turf(does_ignore = TRUE)
	if(ignore_if_not_on_turf == does_ignore)
		return
	ignore_if_not_on_turf = does_ignore
	//Update the ignore_if_not_on_turf
	AddComponent(/datum/component/connect_range, host, loc_connections, current_range, ignore_if_not_on_turf)

/datum/proximity_monitor/proc/on_uncrossed()
	SIGNAL_HANDLER
	return //Used by the advanced subtype for effect fields.

/datum/proximity_monitor/proc/on_entered(atom/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(source != host)
		hasprox_receiver?.HasProximity(arrived)
