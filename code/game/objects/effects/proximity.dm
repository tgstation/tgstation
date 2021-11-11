/datum/proximity_monitor
	///The atom we are tracking
	var/atom/host
	///The atom that will receive HasProximity calls.
	var/atom/hasprox_receiver
	var/current_range
	///If we don't check turfs in range if the host's loc isn't a turf
	var/ignore_if_not_on_turf
	var/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)

/datum/proximity_monitor/New(atom/_host, range, _ignore_if_not_on_turf = TRUE)
	ignore_if_not_on_turf = _ignore_if_not_on_turf
	current_range = range
	SetHost(_host)

/datum/proximity_monitor/proc/SetHost(atom/H,atom/R)
	if(H == host)
		return
	if(host)
		//Remove the old connect components if the host isn't tracked anymore.
		qdel(GetComponent(/datum/component/connect_range))
		qdel(GetComponent(/datum/component/connect_containers))
	if(R)
		hasprox_receiver = R
	else if(hasprox_receiver == host) //Default case
		hasprox_receiver = H
	host = H
	var/static/list/containers_connections = list(COMSIG_MOVABLE_MOVED = .proc/on_moved)
	AddComponent(/datum/component/connect_containers, host, containers_connections)
	SetRange(current_range,TRUE)

/datum/proximity_monitor/Destroy()
	host = null
	hasprox_receiver = null
	return ..()

/datum/proximity_monitor/proc/SetRange(range, force_rebuild = FALSE)
	if(!force_rebuild && range == current_range)
		return FALSE
	. = TRUE
	current_range = range

	if(range > 0)
		//If the connect_range component exists already, this will just update its range. No errors or duplicates.
		AddComponent(/datum/component/connect_range, host, loc_connections, range, !ignore_if_not_on_turf)
	else
		qdel(GetComponent(/datum/component/connect_range))

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

/datum/proximity_monitor/proc/on_entered(atom/source, atom/movable/arrived)
	SIGNAL_HANDLER
	hasprox_receiver?.HasProximity(arrived)
