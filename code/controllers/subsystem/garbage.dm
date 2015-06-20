var/datum/subsystem/garbage_collector/SSgarbage

/datum/subsystem/garbage_collector
	name = "Garbage"
	can_fire = 1
	wait = 5
	priority = -1
	dynamic_wait = 1
	dwait_delta = 5

	var/collection_timeout = 300// deciseconds to wait to let running procs finish before we just say fuck it and force del() the object
	var/max_run_time = 1		// how long, in deciseconds, can we run before waiting for the next tick
	var/delslasttick = 0		// number of del()'s we've done this tick
	var/gcedlasttick = 0		// number of things that gc'ed last tick
	var/totaldels = 0
	var/totalgcs = 0

	var/list/queue = list() 	// list of refID's of things that should be garbage collected
								// refID's are associated with the time at which they time out and need to be manually del()
								// we do this so we aren't constantly locating them and preventing them from being gc'd


	var/list/didntgc = list()	// list of all types that have failed to GC associated with the number of times that's happened.
								// the types are stored as strings


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
	delslasttick = 0
	gcedlasttick = 0
	var/time_to_stop = world.timeofday + max_run_time
	var/time_to_kill = world.time - collection_timeout // Anything qdel() but not GC'd BEFORE this time needs to be manually del()


	while(queue.len && world.timeofday < time_to_stop)
		var/refID = queue[1]
		if (!refID)
			queue.Cut(1, 2)
			continue

		var/GCd_at_time = queue[refID]
		if(GCd_at_time > time_to_kill)
			break // Everything else is newer, skip them

		var/atom/A
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


/datum/subsystem/garbage_collector/proc/Queue(datum/A, harddel = 0)
	if (!istype(A) || !isnull(A.gc_destroyed))
		return
	A.gc_destroyed = world.time
	queue -= "\ref[A]" // Removing any previous references that were GC'd so that the current object will be at the end of the list.
	queue["\ref[A]"] = world.time

/datum/subsystem/garbage_collector/proc/HardQueue(datum/A, harddel = 0)
	if (!istype(A) || !isnull(A.gc_destroyed))
		return
	A.gc_destroyed = world.time
	queue -= A // Removing any previous references that were GC'd so that the current object will be at the end of the list.
	queue[A] = world.time


// Should be treated as a replacement for the 'del' keyword.
// Datums passed to this will be given a chance to clean up references to allow the GC to collect them.
/proc/qdel(var/datum/A)
	if (!A)
		return
	if (!istype(A))
		//warning("qdel() passed object of type [A.type]. qdel() can only handle /datum types.")
		del(A)
	else if (isnull(A.gc_destroyed))
		// Let our friend know they're about to get fucked up.
		var/hint = A.Destroy()
		if (!A)
			return
		switch (hint)
			if (QDEL_HINT_QUEUE)		//qdel should queue the object for deletion.
				SSgarbage.Queue(A)
			if (QDEL_HINT_LETMELIVE)	//qdel should let the object live after calling destory.
				return
			if (QDEL_HINT_IWILLGC)		//functionally the same as the above. qdel should assume the object will gc on its own, and not check it.
				return
			if (QDEL_HINT_HARDDEL)		//qdel should assume this object won't gc, and queue a hard delete using a hard reference to save time from the locate()
				SSgarbage.HardQueue(A)
			if (QDEL_HINT_HARDDEL_NOW)	//qdel should assume this object won't gc, and hard del it post haste.
				del(A)
			if (QDEL_HINT_PUTINPOOL)	//qdel will put this object in the pool.
				PlaceInPool(A,0)
			else
				SSgarbage.Queue(A)

// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return true if the the GC controller should allow the object to continue existing. (Useful if pooling objects.)
/datum/proc/Destroy()
	//del(src)
	tag = null
	return QDEL_HINT_QUEUE

/datum/var/gc_destroyed //Time when this object was destroyed.

#ifdef TESTING
/client/var/running_find_references

/atom/verb/find_references()
	set category = "Debug"
	set name = "Find References"
	set background = 1
	set src in world

	if(!usr || !usr.client)
		return

	if(usr.client.running_find_references)
		testing("CANCELLED search for references to a [usr.client.running_find_references].")
		usr.client.running_find_references = null
		return

	if(alert("Running this will create a lot of lag until it finishes.  You can cancel it by running it again.  Would you like to begin the search?", "Find References", "Yes", "No") == "No")
		return

	// Remove this object from the list of things to be auto-deleted.
	if(garbage)
		garbage.destroyed -= "\ref[src]"

	usr.client.running_find_references = type
	testing("Beginning search for references to a [type].")
	var/list/things = list()
	for(var/client/thing)
		things += thing
	for(var/datum/thing)
		things += thing
	for(var/atom/thing)
		things += thing
	testing("Collected list of things in search for references to a [type]. ([things.len] Thing\s)")
	for(var/datum/thing in things)
		if(!usr.client.running_find_references) return
		for(var/varname in thing.vars)
			var/variable = thing.vars[varname]
			if(variable == src)
				testing("Found [src.type] \ref[src] in [thing.type]'s [varname] var.")
			else if(islist(variable))
				if(src in variable)
					testing("Found [src.type] \ref[src] in [thing.type]'s [varname] list var.")
	testing("Completed search for references to a [type].")
	usr.client.running_find_references = null

/client/verb/purge_all_destroyed_objects()
	set category = "Debug"
	if(garbage)
		while(garbage.destroyed.len)
			var/datum/o = locate(garbage.destroyed[1])
			if(istype(o) && o.gc_destroyed)
				del(o)
				garbage.dels++
			garbage.destroyed.Cut(1, 2)
#endif
