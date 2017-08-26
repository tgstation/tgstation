SUBSYSTEM_DEF(garbage)
	name = "Garbage"
	priority = 15
	wait = 20
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/collection_timeout = list(0, 1200, 0, 2400)	// deciseconds to wait before moving something up in the queue to the next level

	//Stat tracking
	var/delslasttick = 0			// number of del()'s we've done this tick
	var/gcedlasttick = 0			// number of things that gc'ed last tick
	var/totaldels = 0
	var/totalgcs = 0

	var/highest_del_time = 0
	var/highest_del_tickusage = 0

	var/list/pass_counts = list(0, 0, 0, 0)
	var/list/fail_counts = list(0, 0, 0, 0)


	//Queues
	var/list/queues = list(list(), list(), list(), list())


	//Bad boy tracking
	var/list/didntgc = list()		// list of all types that have failed to GC associated with the number of times that's happened.
									// the types are stored as strings

	var/list/sleptDestroy = list()	// Same as above but these are paths that slept during their Destroy call

	var/list/noqdelhint = list()	// list of all types that do not return a QDEL_HINT

	var/list/noforcerespect = list()// all types that did not respect qdel(A, force=TRUE) and returned one of the immortality qdel hints

#ifdef TESTING
	var/list/qdel_list = list()	// list of all types that have been qdel()eted
#endif


/datum/controller/subsystem/garbage/stat_entry(msg)
	var/list/counts = list()
	for (var/list/L in queues)
		counts += length(L)
	msg += "Q:[counts.Join(",")]|D:[delslasttick]|G:[gcedlasttick]|"
	msg += "GR:"
	if (!(delslasttick+gcedlasttick))
		msg += "n/a|"
	else
		msg += "[round((gcedlasttick/(delslasttick+gcedlasttick))*100, 0.01)]%|"

	msg += "TD:[totaldels]|TG:[totalgcs]|"
	if (!(totaldels+totalgcs))
		msg += "n/a|"
	else
		msg += "TGR:[round((totalgcs/(totaldels+totalgcs))*100, 0.01)]%"
	msg += "|P:[pass_counts.Join(",")]"
	msg += "|F:[fail_counts.Join(",")]"
	..(msg)

/datum/controller/subsystem/garbage/Shutdown()
	//Adds the del() log to world.log in a format condensable by the runtime condenser found in tools
	if(didntgc.len || sleptDestroy.len)
		var/list/dellog = list()
		for(var/path in didntgc)
			dellog += "Path : [path] \n"
			dellog += "Failures : [didntgc[path]] \n"
			if(path in sleptDestroy)
				dellog += "Sleeps : [sleptDestroy[path]] \n"
				sleptDestroy -= path
		for(var/path in sleptDestroy)
			dellog += "Path : [path] \n"
			dellog += "Sleeps : [sleptDestroy[path]] \n"
		text2file(dellog.Join(), "[GLOB.log_directory]/qdel.log")

/datum/controller/subsystem/garbage/fire()
	//the fact that this resets its processing each fire (rather then resume where it left off) is intentional.
	var/queue = GC_QUEUE_PREQUEUE

	while (state == SS_RUNNING)
		switch (queue)
			if (GC_QUEUE_PREQUEUE)
				HandlePreQueue()
				queue = GC_QUEUE_PREQUEUE+1
			if (GC_QUEUE_CHECK)
				HandleQueue(GC_QUEUE_CHECK)
				queue = GC_QUEUE_CHECK+1
			if (GC_QUEUE_ENDODONTICS)
				HandleQueue(GC_QUEUE_ENDODONTICS)
				queue = GC_QUEUE_ENDODONTICS+1
			if (GC_QUEUE_HARDDELETE)
				HandleQueue(GC_QUEUE_HARDDELETE)
				break

	if (state == SS_PAUSED) //make us wait again before the next run.
		state = SS_RUNNING

//If you see this proc high on the profile, what you are really seeing is the garbage collection/soft delete overhead in byond.
//Don't attempt to optimize, not worth the effort.
/datum/controller/subsystem/garbage/proc/HandlePreQueue()
	var/list/tobequeued = queues[GC_QUEUE_PREQUEUE]
	var/static/count = 0
	if (count)
		var/c = count
		count = 0 //so if we runtime on the Cut, we don't try again.
		tobequeued.Cut(1,c+1)

	for (var/ref in tobequeued)
		count++
		Queue(ref, GC_QUEUE_PREQUEUE+1)
		if (MC_TICK_CHECK)
			break

	tobequeued.Cut(1,count+1)
	count = 0

/datum/controller/subsystem/garbage/proc/HandleQueue(level = GC_QUEUE_CHECK)
	if (level == GC_QUEUE_CHECK)
		delslasttick = 0
		gcedlasttick = 0
	var/cut_off_time = world.time - collection_timeout[level] //ignore entries newer then this
	var/list/queue = queues[level]
	var/static/lastlevel
	var/static/count = 0
	if (count) //runtime last run before we could do this.
		var/c = count
		count = 0 //so if we runtime on the Cut, we don't try again.
		queue.Cut(1,c+1)

	lastlevel = level

	for (var/refID in queue)
		if (MC_TICK_CHECK)
			break

		if (!refID)
			count++
			continue

		var/GCd_at_time = queue[refID]
		if(GCd_at_time > cut_off_time)
			break // Everything else is newer, skip them
		count++

		var/datum/D
		D = locate(refID)

		if (!D || D.gc_destroyed != GCd_at_time) // So if something else coincidently gets the same ref, it's not deleted by mistake
			if (level == GC_QUEUE_CHECK)
				++gcedlasttick
				++totalgcs
			pass_counts[level]++
			continue

		// Something's still referring to the qdel'd object.
		fail_counts[level]++
		switch (level)
			if (GC_QUEUE_CHECK)
				#ifdef GC_FAILURE_HARD_LOOKUP
				D.find_references()
				#endif
				var/type = D.type
				testing("GC: -- \ref[D] | [type] was unable to be GC'd and was sent to endo --")
				didntgc["[type]"]++
				++delslasttick
				++totaldels
			if (GC_QUEUE_ENDODONTICS)
				EndodonticTherapy(D)
			if (GC_QUEUE_HARDDELETE)
				HardDelete(D)
				continue

		Queue(D, ++level)

	queue.Cut(1,count+1)
	count = 0


//a root canal is called a "final restoration" because you basically gut everything out and hope that keeps it from being a pain.
//	ie: its the final attempt to fix the issue before just removing it.
/datum/controller/subsystem/garbage/proc/EndodonticTherapy(datum/D)
	var/static/list/exclude = list("locs", "color", "transform", "parent_type", "vars", "verbs", "type", "gc_destroyed")
	for (var/V in D.vars - exclude)
		var/value = D.vars[V]
		switch(V)
			if ("ckey", "tag")
				D.vars[V] = null
				continue
			if ("contents")
				var/list/L = value
				if (islist(L))
					L.Cut()
				continue
			if ("loc") //this is where we assume that a turf would never enter the qdel queue. one day this assumption will be wrong.
				D.vars[V] = null
				continue


		if (islist(value))
			value -= D
			if (IS_NORMAL_LIST(value))
				D.vars[V] = null
		else if (isdatum(value))
			var/datum/DD = value
			for (var/VV in DD.vars - exclude)
				value = DD.vars[VV]
				if (islist(value))
					value -= D
				else
					if (value == D)
						value = null
			D.vars[V] = null



/datum/controller/subsystem/garbage/proc/PreQueue(datum/D)
	if (D.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		queues[GC_QUEUE_PREQUEUE] += D
		D.gc_destroyed = GC_QUEUED_FOR_QUEUING

/datum/controller/subsystem/garbage/proc/Queue(datum/D, level = GC_QUEUE_CHECK)
	if (isnull(D))
		return
	if (D.gc_destroyed == GC_QUEUED_FOR_HARD_DEL)
		level = GC_QUEUE_ENDODONTICS
	if (level > GC_QUEUE_HARDDELETE)
		HardDelete(D)
		return
	var/gctime = world.time
	var/refid = "\ref[D]"

	D.gc_destroyed = gctime
	var/list/queue = queues[level]
	if (queue[refid])
		queue -= refid // Removing any previous references that were GC'd so that the current object will be at the end of the list.

	queue[refid] = gctime

//this is purely to separate things profile wise.
/datum/controller/subsystem/garbage/proc/HardDelete(datum/D)
	var/time = world.timeofday
	var/tick = TICK_USAGE
	var/ticktime = world.time

	var/type = D.type
	var/refID = "\ref[D]"

	del(D)

	tick = (TICK_USAGE-tick+((world.time-ticktime)/world.tick_lag*100))
	if (tick > highest_del_tickusage)
		highest_del_tickusage = tick
	time = world.timeofday - time
	if (!time && TICK_DELTA_TO_MS(tick) > 1)
		time = TICK_DELTA_TO_MS(tick)/100
	if (time > highest_del_time)
		highest_del_time = time
	if (time > 10)
		log_game("Error: [type]([refID]) took longer than 1 second to delete (took [time/10] seconds to delete)")
		message_admins("Error: [type]([refID]) took longer than 1 second to delete (took [time/10] seconds to delete).")
		postpone(time/5)

/datum/controller/subsystem/garbage/proc/HardQueue(datum/D)
	if (D.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		queues[GC_QUEUE_PREQUEUE] += D
		D.gc_destroyed = GC_QUEUED_FOR_HARD_DEL

/datum/controller/subsystem/garbage/Recover()
	if (istype(SSgarbage.queues))
		for (var/i in 1 to SSgarbage.queues.len)
			queues[i] |= SSgarbage.queues[i]


// Should be treated as a replacement for the 'del' keyword.
// Datums passed to this will be given a chance to clean up references to allow the GC to collect them.
/proc/qdel(datum/D, force=FALSE)
	if(!istype(D))
		del(D)
		return
#ifdef TESTING
	SSgarbage.qdel_list += "[D.type]"
#endif
	if(isnull(D.gc_destroyed))
		D.SendSignal(COMSIG_PARENT_QDELETED)
		D.gc_destroyed = GC_CURRENTLY_BEING_QDELETED
		var/start_time = world.time
		var/hint = D.Destroy(force) // Let our friend know they're about to get fucked up.
		if(world.time != start_time)
			SSgarbage.sleptDestroy["[D.type]"]++
		if(!D)
			return
		switch(hint)
			if (QDEL_HINT_QUEUE)		//qdel should queue the object for deletion.
				SSgarbage.PreQueue(D)
			if (QDEL_HINT_IWILLGC)
				D.gc_destroyed = world.time
				return
			if (QDEL_HINT_LETMELIVE)	//qdel should let the object live after calling destory.
				if(!force)
					D.gc_destroyed = null //clear the gc variable (important!)
					return
				// Returning LETMELIVE after being told to force destroy
				// indicates the objects Destroy() does not respect force
				if(!SSgarbage.noforcerespect["[D.type]"])
					SSgarbage.noforcerespect["[D.type]"] = "[D.type]"
					testing("WARNING: [D.type] has been force deleted, but is \
						returning an immortal QDEL_HINT, indicating it does \
						not respect the force flag for qdel(). It has been \
						placed in the queue, further instances of this type \
						will also be queued.")
				SSgarbage.PreQueue(D)
			if (QDEL_HINT_HARDDEL)		//qdel should assume this object won't gc, and queue a hard delete using a hard reference to save time from the locate()
				SSgarbage.HardQueue(D)
			if (QDEL_HINT_HARDDEL_NOW)	//qdel should assume this object won't gc, and hard del it post haste.
				SSgarbage.HardDelete(D)
			if (QDEL_HINT_FINDREFERENCE)//qdel will, if TESTING is enabled, display all references to this object, then queue the object for deletion.
				SSgarbage.PreQueue(D)
				#ifdef TESTING
				D.find_references()
				#endif
			else
				if(!SSgarbage.noqdelhint["[D.type]"])
					SSgarbage.noqdelhint["[D.type]"] = "[D.type]"
					testing("WARNING: [D.type] is not returning a qdel hint. It is being placed in the queue. Further instances of this type will also be queued.")
				SSgarbage.PreQueue(D)
	else if(D.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		CRASH("[D.type] destroy proc was called multiple times, likely due to a qdel loop in the Destroy logic")

#ifdef TESTING

/datum/verb/find_refs()
	set category = "Debug"
	set name = "Find References"
	set background = 1
	set src in world

	find_references(FALSE)

/datum/proc/find_references(skip_alert)
	running_find_references = type
	if(usr && usr.client)
		if(usr.client.running_find_references)
			testing("CANCELLED search for references to a [usr.client.running_find_references].")
			usr.client.running_find_references = null
			running_find_references = null
			//restart the garbage collector
			SSgarbage.can_fire = 1
			SSgarbage.next_fire = world.time + world.tick_lag
			return

		if(!skip_alert)
			if(alert("Running this will lock everything up for about 5 minutes.  Would you like to begin the search?", "Find References", "Yes", "No") == "No")
				running_find_references = null
				return

	//this keeps the garbage collector from failing to collect objects being searched for in here
	SSgarbage.can_fire = 0

	if(usr && usr.client)
		usr.client.running_find_references = type

	testing("Beginning search for references to a [type].")
	last_find_references = world.time
	DoSearchVar(GLOB)
	for(var/datum/thing in world)
		DoSearchVar(thing, "WorldRef: [thing]")
	testing("Completed search for references to a [type].")
	if(usr && usr.client)
		usr.client.running_find_references = null
	running_find_references = null

	//restart the garbage collector
	SSgarbage.can_fire = 1
	SSgarbage.next_fire = world.time + world.tick_lag

/datum/verb/qdel_then_find_references()
	set category = "Debug"
	set name = "qdel() then Find References"
	set background = 1
	set src in world

	qdel(src)
	if(!running_find_references)
		find_references(TRUE)

/client/verb/show_qdeleted()
	set category = "Debug"
	set name = "Show qdel() Log"
	set desc = "Render the qdel() log and display it"

	var/dat = "<B>List of things that have been qdel()eted this round</B><BR><BR>"

	var/tmplist = list()
	for(var/elem in SSgarbage.qdel_list)
		if(!(elem in tmplist))
			tmplist[elem] = 0
		tmplist[elem]++

	for(var/path in tmplist)
		dat += "[path] - [tmplist[path]] times<BR>"

	usr << browse(dat, "window=qdeletedlog")

/datum/proc/DoSearchVar(X, Xname)
	if(usr && usr.client && !usr.client.running_find_references) return
	if(istype(X, /datum))
		var/datum/D = X
		if(D.last_find_references == last_find_references)
			return
		D.last_find_references = last_find_references
		for(var/V in D.vars)
			for(var/varname in D.vars)
				var/variable = D.vars[varname]
				if(variable == src)
					testing("Found [src.type] \ref[src] in [D.type]'s [varname] var. [Xname]")
				else if(islist(variable))
					if(src in variable)
						testing("Found [src.type] \ref[src] in [D.type]'s [varname] list var. Global: [Xname]")
#ifdef GC_FAILURE_HARD_LOOKUP
					for(var/I in variable)
						DoSearchVar(I, TRUE)
				else
					DoSearchVar(variable, "[Xname]: [varname]")
#endif
	else if(islist(X))
		if(src in X)
			testing("Found [src.type] \ref[src] in list [Xname].")
#ifdef GC_FAILURE_HARD_LOOKUP
		for(var/I in X)
			DoSearchVar(I, Xname + ": list")
#else
	CHECK_TICK
#endif

#endif
