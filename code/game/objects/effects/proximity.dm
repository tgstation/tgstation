/datum/proximity_monitor
	var/atom/host	//the atom we are tracking
	var/atom/last_host_loc
	var/list/checkers //list of /obj/effect/abstract/proximity_checkers
	var/current_range
	var/ignore_if_not_on_turf	//don't check turfs in range if the host's loc isn't a turf

/datum/proximity_monitor/New(atom/_host, range, _ignore_if_not_on_turf = TRUE)
	host = _host
	last_host_loc = _host.loc
	ignore_if_not_on_turf = _ignore_if_not_on_turf
	SetRange(range)

/datum/proximity_monitor/Destroy()
	host = null
	QDEL_LIST(checkers)
	return ..()

/datum/proximity_monitor/proc/HandleMove()
	var/atom/_host = host
	var/atom/new_host_loc = _host.loc
	if(last_host_loc != new_host_loc)
		last_host_loc = new_host_loc	//hopefully this won't cause GC issues with containers
		var/curr_range = current_range
		SetRange(curr_range, TRUE)
		if(curr_range)
			testing("HasProx: [host] -> [host]")
			_host.HasProximity(host)	//if we are processing, we're guaranteed to be a movable

/datum/proximity_monitor/proc/SetRange(range, force_rebuild = FALSE)
	if(!force_rebuild && range == current_range)
		return FALSE
	. = TRUE
	
	current_range = range

	var/list/old_checkers = checkers
	var/old_checkers_len = LAZYLEN(old_checkers)

	var/atom/host_loc = host.loc

	var/atom/loc_to_use = ignore_if_not_on_turf ? host_loc : get_turf(host)
	if(!isturf(loc_to_use))	//only check the host's loc
		if(range)
			var/obj/effect/abstract/proximity_checker/pc
			if(old_checkers_len)
				pc = old_checkers[old_checkers_len]
				--old_checkers.len
			else
				pc = new(host_loc, src)

			checkers = list(pc)	//only check the host's loc
		return

	var/list/turfs = RANGE_TURFS(range, loc_to_use)
	var/old_checkers_used = min(turfs.len, old_checkers_len)

	//reuse what we can
	for(var/I in 1 to old_checkers_len)
		if(I <= old_checkers_used)
			var/obj/effect/abstract/proximity_checker/pc = old_checkers[I]
			pc.loc = turfs[I]
		else
			qdel(old_checkers[I])	//delete the leftovers

	LAZYCLEARLIST(old_checkers)

	//create what we lack
	var/list/checkers_local = list()
	for(var/I in (old_checkers_used + 1) to turfs.len)
		checkers_local += new /obj/effect/abstract/proximity_checker(turfs[I], src)
	
	checkers = checkers_local

/obj/effect/abstract/proximity_checker
	var/datum/proximity_monitor/monitor

/obj/effect/abstract/proximity_checker/Initialize(mapload, datum/proximity_monitor/_monitor)
	. = ..()
	if(_monitor)
		monitor = _monitor
	else
		stack_trace("proximity_checker created without proximity_monitor")
		qdel(src)

/obj/effect/abstract/proximity_checker/Destroy()
	monitor = null
	return ..()

/obj/effect/abstract/proximity_checker/Crossed(atom/movable/AM)
	set waitfor = FALSE
	var/datum/proximity_monitor/M = monitor
	if(!M.current_range)
		return
	var/atom/H = M.host
	testing("HasProx: [H] -> [AM]")
	H.HasProximity(AM)