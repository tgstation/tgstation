/*!
## Debugging GC issues

In order to debug `qdel()` failures, there are several tools available.
To enable these tools, define `TESTING` in [_compile_options.dm](https://github.com/tgstation/-tg-station/blob/master/code/_compile_options.dm).

First is a verb called "Find References", which lists **every** refererence to an object in the world. This allows you to track down any indirect or obfuscated references that you might have missed.

Complementing this is another verb, "qdel() then Find References".
This does exactly what you'd expect; it calls `qdel()` on the object and then it finds all references remaining.
This is great, because it means that `Destroy()` will have been called before it starts to find references,
so the only references you'll find will be the ones preventing the object from `qdel()`ing gracefully.

If you have a datum or something you are not destroying directly (say via the singulo),
the next tool is `QDEL_HINT_FINDREFERENCE`. You can return this in `Destroy()` (where you would normally `return ..()`),
to print a list of references once it enters the GC queue.

Finally is a verb, "Show qdel() Log", which shows the deletion log that the garbage subsystem keeps. This is helpful if you are having race conditions or need to review the order of deletions.

Note that for any of these tools to work `TESTING` must be defined.
By using these methods of finding references, you can make your life far, far easier when dealing with `qdel()` failures.
*/

SUBSYSTEM_DEF(garbage)
	name = "Garbage"
	priority = FIRE_PRIORITY_GARBAGE
	wait = 2 SECONDS
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND|SS_NO_INIT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	init_order = INIT_ORDER_GARBAGE
	init_stage = INITSTAGE_EARLY

	var/list/collection_timeout = list(GC_FILTER_QUEUE, GC_CHECK_QUEUE, GC_DEL_QUEUE) // deciseconds to wait before moving something up in the queue to the next level

	//Stat tracking
	var/delslasttick = 0 // number of del()'s we've done this tick
	var/gcedlasttick = 0 // number of things that gc'ed last tick
	var/totaldels = 0
	var/totalgcs = 0

	var/highest_del_ms = 0
	var/highest_del_type_string = ""

	var/list/pass_counts
	var/list/fail_counts

	var/list/items = list() // Holds our qdel_item statistics datums

	//Queue
	var/list/queues
	#ifdef REFERENCE_TRACKING
	var/list/reference_find_on_fail = list()
	#ifdef REFERENCE_TRACKING_DEBUG
	//Should we save found refs. Used for unit testing
	var/should_save_refs = FALSE
	#endif
	#endif


/datum/controller/subsystem/garbage/PreInit()
	InitQueues()

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
	msg += " P:[pass_counts.Join(",")]"
	msg += "|F:[fail_counts.Join(",")]"
	return ..()

/datum/controller/subsystem/garbage/Shutdown()
	//Adds the del() log to the qdel log file
	var/list/del_log = list()

	//sort by how long it's wasted hard deleting
	sortTim(items, cmp=/proc/cmp_qdel_item_time, associative = TRUE)
	for(var/path in items)
		var/datum/qdel_item/I = items[path]
		var/list/entry = list()
		del_log[path] = entry

		if (I.qdel_flags & QDEL_ITEM_SUSPENDED_FOR_LAG)
			entry["SUSPENDED FOR LAG"] = TRUE
		if (I.failures)
			entry["Failures"] = I.failures
		entry["qdel() Count"] = I.qdels
		entry["Destroy() Cost (ms)"] = I.destroy_time

		if (I.hard_deletes)
			entry["Total Hard Deletes"] = I.hard_deletes
			entry["Time Spend Hard Deleting (ms)"] = I.hard_delete_time
			entry["Highest Time Spend Hard Deleting (ms)"] = I.hard_delete_max
			if (I.hard_deletes_over_threshold)
				entry["Hard Deletes Over Threshold"] = I.hard_deletes_over_threshold
		if (I.slept_destroy)
			entry["Total Sleeps"] = I.slept_destroy
		if (I.no_respect_force)
			entry["Total Ignored Force"] = I.no_respect_force
		if (I.no_hint)
			entry["Total No Hint"] = I.no_hint
		if(LAZYLEN(I.extra_details))
			entry["Deleted Metadata"] = I.extra_details

	log_qdel("", del_log)

/datum/controller/subsystem/garbage/fire()
	//the fact that this resets its processing each fire (rather then resume where it left off) is intentional.
	var/queue = GC_QUEUE_FILTER

	while (state == SS_RUNNING)
		switch (queue)
			if (GC_QUEUE_FILTER)
				HandleQueue(GC_QUEUE_FILTER)
				queue = GC_QUEUE_FILTER+1
			if (GC_QUEUE_CHECK)
				HandleQueue(GC_QUEUE_CHECK)
				queue = GC_QUEUE_CHECK+1
			if (GC_QUEUE_HARDDELETE)
				HandleQueue(GC_QUEUE_HARDDELETE)
				if (state == SS_PAUSED) //make us wait again before the next run.
					state = SS_RUNNING
				break



/datum/controller/subsystem/garbage/proc/InitQueues()
	if (isnull(queues)) // Only init the queues if they don't already exist, prevents overriding of recovered lists
		queues = new(GC_QUEUE_COUNT)
		pass_counts = new(GC_QUEUE_COUNT)
		fail_counts = new(GC_QUEUE_COUNT)
		for(var/i in 1 to GC_QUEUE_COUNT)
			queues[i] = list()
			pass_counts[i] = 0
			fail_counts[i] = 0


/datum/controller/subsystem/garbage/proc/HandleQueue(level = GC_QUEUE_FILTER)
	if (level == GC_QUEUE_FILTER)
		delslasttick = 0
		gcedlasttick = 0
	var/cut_off_time = world.time - collection_timeout[level] //ignore entries newer then this
	var/list/queue = queues[level]
	var/static/lastlevel
	var/static/count = 0
	if (count) //runtime last run before we could do this.
		var/c = count
		count = 0 //so if we runtime on the Cut, we don't try again.
		var/list/lastqueue = queues[lastlevel]
		lastqueue.Cut(1, c+1)

	lastlevel = level

// 1 from the hard reference in the queue, and 1 from the variable used before this
#define REFS_WE_EXPECT 2

	//We do this rather then for(var/list/ref_info in queue) because that sort of for loop copies the whole list.
	//Normally this isn't expensive, but the gc queue can grow to 40k items, and that gets costly/causes overrun.
	for (var/i in 1 to length(queue))
		var/list/L = queue[i]
		if (length(L) < GC_QUEUE_ITEM_INDEX_COUNT)
			count++
			if (MC_TICK_CHECK)
				return
			continue

		var/queued_at_time = L[GC_QUEUE_ITEM_QUEUE_TIME]
		if(queued_at_time > cut_off_time)
			break // Everything else is newer, skip them
		count++

		var/datum/D = L[GC_QUEUE_ITEM_REF]

		// If that's all we've got, send er off
		if (refcount(D) == REFS_WE_EXPECT)
			++gcedlasttick
			++totalgcs
			pass_counts[level]++
			#ifdef REFERENCE_TRACKING
			reference_find_on_fail -= text_ref(D) //It's deleted we don't care anymore.
			#endif
			if (MC_TICK_CHECK)
				return
			continue

		// Something's still referring to the qdel'd object.
		fail_counts[level]++

		#ifdef REFERENCE_TRACKING
		var/ref_searching = FALSE
		#endif

		switch (level)
			if (GC_QUEUE_CHECK)
				#ifdef REFERENCE_TRACKING
				// Decides how many refs to look for (potentially)
				// Based off the remaining and the ones we can account for
				var/remaining_refs = refcount(D) - REFS_WE_EXPECT
				if(reference_find_on_fail[text_ref(D)])
					INVOKE_ASYNC(D, TYPE_PROC_REF(/datum,find_references), remaining_refs)
					ref_searching = TRUE
				#ifdef GC_FAILURE_HARD_LOOKUP
				else
					INVOKE_ASYNC(D, TYPE_PROC_REF(/datum,find_references), remaining_refs)
					ref_searching = TRUE
				#endif
				reference_find_on_fail -= text_ref(D)
				#endif
				var/type = D.type
				var/datum/qdel_item/I = items[type]

				var/message = "## TESTING: GC: -- [text_ref(D)] | [type] was unable to be GC'd --"
				message = "[message] (ref count of [refcount(D)])"
				log_world(message)

				var/detail = D.dump_harddel_info()
				if(detail)
					LAZYADD(I.extra_details, detail)

				#ifdef TESTING
				for(var/c in GLOB.admins) //Using testing() here would fill the logs with ADMIN_VV garbage
					var/client/admin = c
					if(!check_rights_for(admin, R_ADMIN))
						continue
					to_chat(admin, "## TESTING: GC: -- [ADMIN_VV(D)] | [type] was unable to be GC'd --")
				#endif
				I.failures++

				if (I.qdel_flags & QDEL_ITEM_SUSPENDED_FOR_LAG)
					#ifdef REFERENCE_TRACKING
					if(ref_searching)
						return //ref searching intentionally cancels all further fires while running so things that hold references don't end up getting deleted, so we want to return here instead of continue
					#endif
					continue
			if (GC_QUEUE_HARDDELETE)
				HardDelete(D)
				if (MC_TICK_CHECK)
					return
				continue

		Queue(D, level+1)

		#ifdef REFERENCE_TRACKING
		if(ref_searching)
			return
		#endif

		if (MC_TICK_CHECK)
			return
	if (count)
		queue.Cut(1,count+1)
		count = 0

#undef REFS_WE_EXPECT

/datum/controller/subsystem/garbage/proc/Queue(datum/D, level = GC_QUEUE_FILTER)
	if (isnull(D))
		return
	if (level > GC_QUEUE_COUNT)
		HardDelete(D)
		return
	var/queue_time = world.time

	if (D.gc_destroyed <= 0)
		D.gc_destroyed = queue_time

	var/list/queue = queues[level]
	queue[++queue.len] = list(queue_time, D, D.gc_destroyed) // not += for byond reasons

//this is mainly to separate things profile wise.
/datum/controller/subsystem/garbage/proc/HardDelete(datum/D)
	++delslasttick
	++totaldels
	var/type = D.type
	var/refID = text_ref(D)
	var/datum/qdel_item/type_info = items[type]
	var/detail = D.dump_harddel_info()
	if(detail)
		LAZYADD(type_info.extra_details, detail)

	var/tick_usage = TICK_USAGE
	del(D)
	tick_usage = TICK_USAGE_TO_MS(tick_usage)

	type_info.hard_deletes++
	type_info.hard_delete_time += tick_usage
	if (tick_usage > type_info.hard_delete_max)
		type_info.hard_delete_max = tick_usage
	if (tick_usage > highest_del_ms)
		highest_del_ms = tick_usage
		highest_del_type_string = "[type]"

	var/time = MS2DS(tick_usage)

	if (time > 0.1 SECONDS)
		postpone(time)
	var/threshold = CONFIG_GET(number/hard_deletes_overrun_threshold)
	if (threshold && (time > threshold SECONDS))
		if (!(type_info.qdel_flags & QDEL_ITEM_ADMINS_WARNED))
			log_game("Error: [type]([refID]) took longer than [threshold] seconds to delete (took [round(time/10, 0.1)] seconds to delete)")
			message_admins("Error: [type]([refID]) took longer than [threshold] seconds to delete (took [round(time/10, 0.1)] seconds to delete).")
			type_info.qdel_flags |= QDEL_ITEM_ADMINS_WARNED
		type_info.hard_deletes_over_threshold++
		var/overrun_limit = CONFIG_GET(number/hard_deletes_overrun_limit)
		if (overrun_limit && type_info.hard_deletes_over_threshold >= overrun_limit)
			type_info.qdel_flags |= QDEL_ITEM_SUSPENDED_FOR_LAG

/datum/controller/subsystem/garbage/Recover()
	InitQueues() //We first need to create the queues before recovering data
	if (istype(SSgarbage.queues))
		for (var/i in 1 to SSgarbage.queues.len)
			queues[i] |= SSgarbage.queues[i]

/// Qdel Item: Holds statistics on each type that passes thru qdel
/datum/qdel_item
	var/name = "" //!Holds the type as a string for this type
	var/qdels = 0 //!Total number of times it's passed thru qdel.
	var/destroy_time = 0 //!Total amount of milliseconds spent processing this type's Destroy()
	var/failures = 0 //!Times it was queued for soft deletion but failed to soft delete.
	var/hard_deletes = 0 //!Different from failures because it also includes QDEL_HINT_HARDDEL deletions
	var/hard_delete_time = 0 //!Total amount of milliseconds spent hard deleting this type.
	var/hard_delete_max = 0 //!Highest time spent hard_deleting this in ms.
	var/hard_deletes_over_threshold = 0 //!Number of times hard deletes took longer than the configured threshold
	var/no_respect_force = 0 //!Number of times it's not respected force=TRUE
	var/no_hint = 0 //!Number of times it's not even bother to give a qdel hint
	var/slept_destroy = 0 //!Number of times it's slept in its destroy
	var/qdel_flags = 0 //!Flags related to this type's trip thru qdel.
	var/list/extra_details //!Lazylist of string metadata about the deleted objects

/datum/qdel_item/New(mytype)
	name = "[mytype]"

/// Should be treated as a replacement for the 'del' keyword.
///
/// Datums passed to this will be given a chance to clean up references to allow the GC to collect them.
/proc/qdel(datum/to_delete, force = FALSE)
	if(!istype(to_delete))
		DREAMLUAU_CLEAR_REF_USERDATA(to_delete)
		del(to_delete)
		return

	var/datum/qdel_item/trash = SSgarbage.items[to_delete.type]
	if (isnull(trash))
		trash = SSgarbage.items[to_delete.type] = new /datum/qdel_item(to_delete.type)
	trash.qdels++

	if(!isnull(to_delete.gc_destroyed))
		if(to_delete.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
			CRASH("[to_delete.type] destroy proc was called multiple times, likely due to a qdel loop in the Destroy logic")
		return

	if (SEND_SIGNAL(to_delete, COMSIG_PREQDELETED, force)) // Give the components a chance to prevent their parent from being deleted
		return

	to_delete.gc_destroyed = GC_CURRENTLY_BEING_QDELETED
	var/start_time = world.time
	var/start_tick = world.tick_usage
	SEND_SIGNAL(to_delete, COMSIG_QDELETING, force) // Let the (remaining) components know about the result of Destroy
	var/hint = to_delete.Destroy(force) // Let our friend know they're about to get fucked up.

	if(world.time != start_time)
		trash.slept_destroy++
	else
		trash.destroy_time += TICK_USAGE_TO_MS(start_tick)

	if(isnull(to_delete))
		return

	switch(hint)
		if (QDEL_HINT_QUEUE) //qdel should queue the object for deletion.
			SSgarbage.Queue(to_delete)
		if (QDEL_HINT_IWILLGC)
			to_delete.gc_destroyed = world.time
			return
		if (QDEL_HINT_LETMELIVE) //qdel should let the object live after calling destory.
			if(!force)
				to_delete.gc_destroyed = null //clear the gc variable (important!)
				return
			// Returning LETMELIVE after being told to force destroy
			// indicates the objects Destroy() does not respect force
			#ifdef TESTING
			if(!trash.no_respect_force)
				testing("WARNING: [to_delete.type] has been force deleted, but is \
					returning an immortal QDEL_HINT, indicating it does \
					not respect the force flag for qdel(). It has been \
					placed in the queue, further instances of this type \
					will also be queued.")
			#endif
			trash.no_respect_force++

			SSgarbage.Queue(to_delete)
		if (QDEL_HINT_HARDDEL) //qdel should assume this object won't gc, and queue a hard delete
			SSgarbage.Queue(to_delete, GC_QUEUE_HARDDELETE)
		if (QDEL_HINT_HARDDEL_NOW) //qdel should assume this object won't gc, and hard del it post haste.
			SSgarbage.HardDelete(to_delete)
		#ifdef REFERENCE_TRACKING
		if (QDEL_HINT_FINDREFERENCE) //qdel will, if REFERENCE_TRACKING is enabled, display all references to this object, then queue the object for deletion.
			SSgarbage.Queue(to_delete)
			INVOKE_ASYNC(to_delete, TYPE_PROC_REF(/datum, find_references))
		if (QDEL_HINT_IFFAIL_FINDREFERENCE) //qdel will, if REFERENCE_TRACKING is enabled and the object fails to collect, display all references to this object.
			SSgarbage.Queue(to_delete)
			SSgarbage.reference_find_on_fail[text_ref(to_delete)] = TRUE
		#endif
		else
			#ifdef TESTING
			if(!trash.no_hint)
				testing("WARNING: [to_delete.type] is not returning a qdel hint. It is being placed in the queue. Further instances of this type will also be queued.")
			#endif
			trash.no_hint++
			SSgarbage.Queue(to_delete)
