/datum/proximity_monitor
	var/atom/host //the atom we are tracking
	var/atom/hasprox_receiver //the atom that will receive HasProximity calls.
	var/atom/last_host_loc
	var/current_range
	var/ignore_if_not_on_turf //don't check turfs in range if the host's loc isn't a turf
	var/wire = FALSE
	var/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
		COMSIG_ATOM_EXITED =.proc/on_uncrossed,
	)

/datum/proximity_monitor/New(atom/_host, range, _ignore_if_not_on_turf = TRUE)
	last_host_loc = _host.loc
	ignore_if_not_on_turf = _ignore_if_not_on_turf
	current_range = range
	SetHost(_host)

/datum/proximity_monitor/proc/SetHost(atom/H,atom/R)
	if(H == host)
		return
	if(host)
		UnregisterSignal(host, COMSIG_MOVABLE_MOVED)
		qdel(GetComponent(/datum/component/connect_range)) //Remove the old connect components if the host isn't tracked anymore.
		if(ignore_if_not_on_turf)
			qdel(GetComponent(/datum/component/connect_loc_behalf))
	if(R)
		hasprox_receiver = R
	else if(hasprox_receiver == host) //Default case
		hasprox_receiver = H
	host = H
	RegisterSignal(host, COMSIG_MOVABLE_MOVED, .proc/HandleMove)
	last_host_loc = host.loc
	SetRange(current_range,TRUE)

/datum/proximity_monitor/Destroy()
	host = null
	last_host_loc = null
	hasprox_receiver = null
	return ..()

/datum/proximity_monitor/proc/HandleMove(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER

	var/atom/_host = host
	var/atom/new_host_loc = _host.loc
	if(last_host_loc == new_host_loc)
		return
	last_host_loc = new_host_loc //hopefully this won't cause GC issues with containers
	if(!current_range)
		return
	if(!isturf(new_host_loc)) //only check the host's loc. We can't use connect_loc because it may conflict with connect_range
		for(var/signal in loc_connections)
			RegisterSignal(new_host_loc, signal, loc_connections[signal])
	else if(old_loc && !isturf(old_loc))
		UnregisterSignal(old_loc, loc_connections)
	testing("HasProx: [host] -> [host]")
	hasprox_receiver.HasProximity(host) //if we are processing, we're guaranteed to be a movable

/datum/proximity_monitor/proc/SetRange(range, force_rebuild = FALSE)
	if(!force_rebuild && range == current_range)
		return FALSE
	. = TRUE
	current_range = range

	if(range > 0)
		//If a connect_range component exists already, this will just update its range. No errors or duplicates.
		AddComponent(/datum/component/connect_range, loc_connections, host, range, !ignore_if_not_on_turf)
		if(ignore_if_not_on_turf && !isturf(host.loc))
			for(var/signal in loc_connections)
				RegisterSignal(host.loc, signal, loc_connections[signal])
	else
		qdel(GetComponent(/datum/component/connect_range))
		if(ignore_if_not_on_turf && !isturf(host.loc))
			UnregisterSignal(host.loc, loc_connections)

/datum/proximity_monitor/proc/on_uncrossed(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	return

/datum/proximity_monitor/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	hasprox_receiver?.HasProximity(AM)
