var/datum/subsystem/garbage_collector/SSgarbage

/datum/subsystem/garbage_collector
	name = "Garbage"
	priority = -1
	wait = 5
	dynamic_wait = 1
	dwait_upper = 50
	dwait_delta = 10
	dwait_buffer = 0
	display = 2

	can_fire = 1 // This needs to fire before round start.

	var/collection_timeout = 300// deciseconds to wait to let running procs finish before we just say fuck it and force del() the object
	var/max_run_time = 1		// how long, in deciseconds, can we run before waiting for the next tick
	var/delslasttick = 0		// number of del()'s we've done this tick
	var/gcedlasttick = 0		// number of things that gc'ed last tick
	var/totaldels = 0
	var/totalgcs = 0

	var/list/queue = list() 	// list of refID's of things that should be garbage collected
								// refID's are associated with the time at which they time out and need to be manually del()
								// we do this so we aren't constantly locating them and preventing them from being gc'd

	var/list/tobequeued = list()	//We store the references of things to be added to the queue seperately so we can spread out GC overhead over a few ticks

	var/list/didntgc = list()	// list of all types that have failed to GC associated with the number of times that's happened.
								// the types are stored as strings

	var/list/noqdelhint = list()// list of all types that do not return a QDEL_HINT

#ifdef TESTING
	var/list/qdel_list = list()	// list of all types that have been qdel()eted
#endif

/datum/subsystem/garbage_collector/New()
	NEW_SS_GLOBAL(SSgarbage)

/datum/subsystem/garbage_collector/stat_entry(msg)
	msg += "Q:[queue.len]|D:[delslasttick]|G:[gcedlasttick]|"
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
	..(msg)

/datum/subsystem/garbage_collector/fire()
	var/time_to_stop = world.timeofday + max_run_time
	HandleToBeQueued(time_to_stop)
	HandleQueue(time_to_stop)

//If you see this proc high on the profile, what you are really seeing is the garbage collection/soft delete overhead in byond.
//Don't attempt to optimize, not worth the effort.
/datum/subsystem/garbage_collector/proc/HandleToBeQueued(time_to_stop)
	var/list/tobequeued = src.tobequeued
	while(tobequeued.len && world.timeofday < time_to_stop)
		if (MC_TICK_CHECK)
			break
		var/ref = tobequeued[1]
		Queue(ref)
		tobequeued.Cut(1, 2)

/datum/subsystem/garbage_collector/proc/HandleQueue(time_to_stop)
	delslasttick = 0
	gcedlasttick = 0
	var/time_to_kill = world.time - collection_timeout // Anything qdel() but not GC'd BEFORE this time needs to be manually del()
	var/list/queue = src.queue
	while(queue.len && world.timeofday < time_to_stop)
		if (MC_TICK_CHECK)
			break
		var/refID = queue[1]
		if (!refID)
			queue.Cut(1, 2)
			continue

		var/GCd_at_time = queue[refID]
		if(GCd_at_time > time_to_kill)
			break // Everything else is newer, skip them

		var/datum/A
		if (!istext(refID))
			del(A)
		else
			A = locate(refID)
			if (A && A.gc_destroyed == GCd_at_time) // So if something else coincidently gets the same ref, it's not deleted by mistake
				// Something's still referring to the qdel'd object.  Kill it.
				testing("GC: -- \ref[A] | [A.type] was unable to be GC'd and was deleted --")
				didntgc["[A.type]"]++
				del(A)
				++delslasttick
				++totaldels
			else
				++gcedlasttick
				++totalgcs
		queue.Cut(1, 2)

/datum/subsystem/garbage_collector/proc/QueueForQueuing(datum/A)
	if (istype(A) && isnull(A.gc_destroyed))
		tobequeued += A
		A.gc_destroyed = -1

/datum/subsystem/garbage_collector/proc/Queue(datum/A)
	if (!istype(A) || (!isnull(A.gc_destroyed) && A.gc_destroyed >= 0))
		return
	var/gctime = world.time
	var/refid = "\ref[A]"

	A.gc_destroyed = gctime

	if (queue[refid])
		queue -= refid // Removing any previous references that were GC'd so that the current object will be at the end of the list.

	queue[refid] = gctime

/datum/subsystem/garbage_collector/proc/HardQueue(datum/A)
	if (!istype(A) || !isnull(A.gc_destroyed))
		return
	A.gc_destroyed = world.time
	queue -= A // Removing any previous references that were GC'd so that the current object will be at the end of the list.
	queue[A] = world.time


// Should be treated as a replacement for the 'del' keyword.
// Datums passed to this will be given a chance to clean up references to allow the GC to collect them.
/proc/qdel(datum/D)
	if(!D)
		return
#ifdef TESTING
	SSgarbage.qdel_list += "[A.type]"
#endif
	if(!istype(D))
		del(D)
	else if(isnull(D.gc_destroyed))
		var/hint = D.Destroy() // Let our friend know they're about to get fucked up.
		if(!D)
			return
		switch(hint)
			if (QDEL_HINT_QUEUE)		//qdel should queue the object for deletion.
				SSgarbage.QueueForQueuing(D)
			if (QDEL_HINT_LETMELIVE)	//qdel should let the object live after calling destory.
				return
			if (QDEL_HINT_IWILLGC)		//functionally the same as the above. qdel should assume the object will gc on its own, and not check it.
				return
			if (QDEL_HINT_HARDDEL)		//qdel should assume this object won't gc, and queue a hard delete using a hard reference to save time from the locate()
				SSgarbage.HardQueue(D)
			if (QDEL_HINT_HARDDEL_NOW)	//qdel should assume this object won't gc, and hard del it post haste.
				del(D)
			if (QDEL_HINT_PUTINPOOL)	//qdel will put this object in the pool.
				PlaceInPool(D, 0)
			if (QDEL_HINT_FINDREFERENCE)//qdel will, if TESTING is enabled, display all references to this object, then queue the object for deletion.
				SSgarbage.QueueForQueuing(D)
				#ifdef TESTING
				A.find_references()
				#endif
			else
				if(!("[D.type]" in SSgarbage.noqdelhint))
					SSgarbage.noqdelhint += "[D.type]"
					testing("WARNING: [D.type] is not returning a qdel hint. It is being placed in the queue. Further instances of this type will also be queued.")
				SSgarbage.QueueForQueuing(D)

// Returns 1 if the object has been queued for deletion.
/proc/qdeleted(datum/D)
	if(!istype(D))
		return FALSE
	if(D.gc_destroyed)
		return TRUE
	return FALSE

// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return the appropriate QDEL_HINT; in most cases this is QDEL_HINT_QUEUE.
/datum/proc/Destroy()
	tag = null
	return QDEL_HINT_QUEUE

/datum/var/gc_destroyed //Time when this object was destroyed.

#ifdef TESTING
/client/var/running_find_references
/datum/var/running_find_references

/datum/verb/find_references()
	set category = "Debug"
	set name = "Find References"
	set background = 1
	set src in world

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

		if(alert("Running this will create a lot of lag until it finishes.  You can cancel it by running it again.  Would you like to begin the search?", "Find References", "Yes", "No") == "No")
			running_find_references = null
			return

	//this keeps the garbage collector from failing to collect objects being searched for in here
	SSgarbage.can_fire = 0

	if(usr && usr.client)
		usr.client.running_find_references = type

	testing("Beginning search for references to a [type].")
	var/list/things = list()
	for(var/client/thing)
		things |= thing
	for(var/datum/thing)
		things |= thing
	testing("Collected list of things in search for references to a [type]. ([things.len] Thing\s)")
	for(var/datum/thing in things)
		if(usr && usr.client && !usr.client.running_find_references) return
		for(var/varname in thing.vars)
			var/variable = thing.vars[varname]
			if(variable == src)
				testing("Found [src.type] \ref[src] in [thing.type]'s [varname] var.")
			else if(islist(variable))
				if(src in variable)
					testing("Found [src.type] \ref[src] in [thing.type]'s [varname] list var.")
	testing("Completed search for references to a [type].")
	if(usr && usr.client)
		usr.client.running_find_references = null
	running_find_references = null

	//restart the garbage collector
	SSgarbage.can_fire = 1
	SSgarbage.next_fire = world.time + world.tick_lag

/client/verb/purge_all_destroyed_objects()
	set category = "Debug"
	if(SSgarbage)
		while(SSgarbage.queue.len)
			var/datum/o = locate(SSgarbage.queue[1])
			if(istype(o) && o.gc_destroyed)
				del(o)
				SSgarbage.totaldels++
			SSgarbage.queue.Cut(1, 2)

/datum/verb/qdel_then_find_references()
	set category = "Debug"
	set name = "qdel() then Find References"
	set background = 1
	set src in world

	qdel(src)
	if(!running_find_references)
		find_references()

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
#endif
