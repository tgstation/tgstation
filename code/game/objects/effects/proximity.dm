/datum/proximity_monitor
	var/atom/host //the atom we are tracking
	var/atom/hasprox_receiver //the atom that will receive HasProximity calls.
	var/atom/last_host_loc
	var/list/checkers //list of /obj/effect/abstract/proximity_checkers
	var/current_range
	var/wire = FALSE

/datum/proximity_monitor/New(atom/_host, range)
	last_host_loc = _host.loc
	current_range = range
	SetHost(_host, _host)

/datum/proximity_monitor/proc/SetHost(atom/H,atom/R)
	if(H == host)
		return
	if(host)
		UnregisterSignal(host, COMSIG_MOVABLE_MOVED)
	if(R)
		hasprox_receiver = R
	host = H
	RegisterSignal(host, COMSIG_MOVABLE_MOVED, .proc/HandleMove)
	last_host_loc = host.loc
	SetRange(current_range,TRUE)

/datum/proximity_monitor/Destroy()
	host = null
	last_host_loc = null
	hasprox_receiver = null
	QDEL_LAZYLIST(checkers)
	return ..()

/datum/proximity_monitor/proc/HandleMove(atom/movable/mover, atom/old_loc)
	SIGNAL_HANDLER

	var/atom/new_host_loc = host.loc
	if(last_host_loc != new_host_loc)
		last_host_loc = new_host_loc //hopefully this won't cause GC issues with containers
		SetRange(current_range, TRUE)

/**
 * Sets the detection range.
 *
 * Arguments:
 * * range - how many tiles around host should we detect. 0 means only my own tile, negative values turn the monitor off
 * * force_rebuild - rebuild the checkers even when the range is the same as before
 */
/datum/proximity_monitor/proc/SetRange(range, force_rebuild = FALSE)
	if(!force_rebuild && range == current_range)
		return

	current_range = range
	var/old_checkers_len = LAZYLEN(checkers)

	var/atom/loc_to_use = host.loc
	if(!isturf(loc_to_use) || range < 0)
		QDEL_LAZYLIST(checkers)
		return

	var/list/turfs = RANGE_TURFS(range, host.loc)
	var/turfs_len = turfs.len
	var/old_checkers_used = min(turfs_len, old_checkers_len)

	//reuse what we can
	for(var/I in 1 to old_checkers_len)
		if(I <= old_checkers_used)
			var/obj/effect/abstract/proximity_checker/pc = checkers[I]
			pc.forceMove(turfs[I])
		else
			qdel(checkers[I]) //delete the leftovers

	if(old_checkers_len < turfs_len)
		//create what we lack
		for(var/I in (old_checkers_used + 1) to turfs_len)
			LAZYADD(checkers, new /obj/effect/abstract/proximity_checker(turfs[I], src))
	else
		checkers.Cut(turfs_len + 1)

/obj/effect/abstract/proximity_checker
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	var/datum/proximity_monitor/monitor

/obj/effect/abstract/proximity_checker/Initialize(mapload, datum/proximity_monitor/_monitor)
	. = ..()
	if(_monitor)
		monitor = _monitor
	else
		stack_trace("proximity_checker created without host")
		return INITIALIZE_HINT_QDEL
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
		COMSIG_ATOM_EXITED =.proc/on_uncrossed,
	)
	AddElement(/datum/element/connect_loc, src, loc_connections)

/obj/effect/abstract/proximity_checker/proc/on_uncrossed(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	return

/obj/effect/abstract/proximity_checker/Destroy()
	monitor = null
	return ..()

/obj/effect/abstract/proximity_checker/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	monitor?.hasprox_receiver?.HasProximity(AM)
