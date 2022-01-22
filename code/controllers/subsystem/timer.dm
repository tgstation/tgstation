/// Controls how many buckets should be kept, each representing a tick. (1 minutes worth)
#define BUCKET_LEN (world.fps*1*60)
/// Helper for getting the correct bucket for a given timer
#define BUCKET_POS(timer) (((round((timer.timeToRun - timer.timer_subsystem.head_offset) / world.tick_lag)+1) % BUCKET_LEN)||BUCKET_LEN)
/// Gets the maximum time at which timers will be invoked from buckets, used for deferring to secondary queue
#define TIMER_MAX(timer_ss) (timer_ss.head_offset + TICKS2DS(BUCKET_LEN + timer_ss.practical_offset - 1))
/// Max float with integer precision
#define TIMER_ID_MAX (2**24)

/**
 * # Timer Subsystem
 *
 * Handles creation, callbacks, and destruction of timed events.
 *
 * It is important to understand the buckets used in the timer subsystem are just a series of doubly-linked
 * lists. The object at a given index in bucket_list is a /datum/timedevent, the head of a list, which has prev
 * and next references for the respective elements in that bucket's list.
 */
SUBSYSTEM_DEF(timer)
	name = "Timer"
	wait = 1 // SS_TICKER subsystem, so wait is in ticks
	init_order = INIT_ORDER_TIMER
	priority = FIRE_PRIORITY_TIMER
	flags = SS_TICKER|SS_NO_INIT

	/// Queue used for storing timers that do not fit into the current buckets
	var/list/datum/timedevent/second_queue = list()
	/// A hashlist dictionary used for storing unique timers
	var/list/hashes = list()
	/// world.time of the first entry in the bucket list, effectively the 'start time' of the current buckets
	var/head_offset = 0
	/// Index of the wrap around pivot for buckets. buckets before this are later running buckets wrapped around from the end of the bucket list.
	var/practical_offset = 1
	/// world.tick_lag the bucket was designed for
	var/bucket_resolution = 0
	/// How many timers are in the buckets
	var/bucket_count = 0
	/// List of buckets, each bucket holds every timer that has to run that byond tick
	var/list/bucket_list = list()
	/// List of all active timers associated to their timer ID (for easy lookup)
	var/list/timer_id_dict = list()
	/// Special timers that run in real-time, not BYOND time; these are more expensive to run and maintain
	var/list/clienttime_timers = list()
	/// Contains the last time that a timer's callback was invoked, or the last tick the SS fired if no timers are being processed
	var/last_invoke_tick = 0
	/// Keeps track of the next index to work on for client timers
	var/next_clienttime_timer_index = 0
	/// Contains the last time that a warning was issued for not invoking callbacks
	var/static/last_invoke_warning = 0
	/// Boolean operator controlling if the timer SS will automatically reset buckets if it fails to invoke callbacks for an extended period of time
	var/static/bucket_auto_reset = TRUE
	/// How many times bucket was reset
	var/bucket_reset_count = 0

/datum/controller/subsystem/timer/PreInit()
	bucket_list.len = BUCKET_LEN
	head_offset = world.time
	bucket_resolution = world.tick_lag

/datum/controller/subsystem/timer/stat_entry(msg)
	msg = "B:[bucket_count] P:[length(second_queue)] H:[length(hashes)] C:[length(clienttime_timers)] S:[length(timer_id_dict)] RST:[bucket_reset_count]"
	return ..()

/datum/controller/subsystem/timer/proc/dump_timer_buckets(full = TRUE)
	var/list/to_log = list("Timer bucket reset. world.time: [world.time], head_offset: [head_offset], practical_offset: [practical_offset]")
	if (full)
		for (var/i in 1 to length(bucket_list))
			var/datum/timedevent/bucket_head = bucket_list[i]
			if (!bucket_head)
				continue

			to_log += "Active timers at index [i]:"
			var/datum/timedevent/bucket_node = bucket_head
			var/anti_loop_check = 1
			do
				to_log += get_timer_debug_string(bucket_node)
				bucket_node = bucket_node.next
				anti_loop_check--
			while(bucket_node && bucket_node != bucket_head && anti_loop_check)

		to_log += "Active timers in the second_queue queue:"
		for(var/I in second_queue)
			to_log += get_timer_debug_string(I)

	// Dump all the logged data to the world log
	log_world(to_log.Join("\n"))

/datum/controller/subsystem/timer/fire(resumed = FALSE)
	// Store local references to datum vars as it is faster to access them
	var/lit = last_invoke_tick
	var/list/bucket_list = src.bucket_list
	var/last_check = world.time - TICKS2DS(BUCKET_LEN * 1.5)

	// If there are no timers being tracked, then consider now to be the last invoked time
	if(!bucket_count)
		last_invoke_tick = world.time

	// Check that we have invoked a callback in the last 1.5 minutes of BYOND time,
	// and throw a warning and reset buckets if this is true
	if(lit && lit < last_check && head_offset < last_check && last_invoke_warning < last_check)
		last_invoke_warning = world.time
		var/msg = "No regular timers processed in the last [BUCKET_LEN * 1.5] ticks[bucket_auto_reset ? ", resetting buckets" : ""]!"
		message_admins(msg)
		WARNING(msg)
		if(bucket_auto_reset)
			bucket_resolution = 0
		dump_timer_buckets(CONFIG_GET(flag/log_timers_on_bucket_reset))

	// Process client-time timers
	if (next_clienttime_timer_index)
		clienttime_timers.Cut(1, next_clienttime_timer_index+1)
		next_clienttime_timer_index = 0
	for (next_clienttime_timer_index in 1 to length(clienttime_timers))
		if (MC_TICK_CHECK)
			next_clienttime_timer_index--
			break
		var/datum/timedevent/ctime_timer = clienttime_timers[next_clienttime_timer_index]
		if (ctime_timer.timeToRun > REALTIMEOFDAY)
			next_clienttime_timer_index--
			break

		var/datum/callback/callBack = ctime_timer.callBack
		if (!callBack)
			CRASH("Invalid timer: [get_timer_debug_string(ctime_timer)] world.time: [world.time], \
				head_offset: [head_offset], practical_offset: [practical_offset], REALTIMEOFDAY: [REALTIMEOFDAY]")

		ctime_timer.spent = REALTIMEOFDAY
		callBack.InvokeAsync()

		if(ctime_timer.flags & TIMER_LOOP)
			ctime_timer.spent = 0
			ctime_timer.timeToRun = REALTIMEOFDAY + ctime_timer.wait
			BINARY_INSERT(ctime_timer, clienttime_timers, /datum/timedevent, ctime_timer, timeToRun, COMPARE_KEY)
		else
			qdel(ctime_timer)

	// Remove invoked client-time timers
	if (next_clienttime_timer_index)
		clienttime_timers.Cut(1, next_clienttime_timer_index+1)
		next_clienttime_timer_index = 0

	// Check for when we need to loop the buckets, this occurs when
	// the head_offset is approaching BUCKET_LEN ticks in the past
	if (practical_offset > BUCKET_LEN)
		head_offset += TICKS2DS(BUCKET_LEN)
		practical_offset = 1
		resumed = FALSE

	// Check for when we have to reset buckets, typically from auto-reset
	if ((length(bucket_list) != BUCKET_LEN) || (world.tick_lag != bucket_resolution))
		reset_buckets()
		bucket_list = src.bucket_list
		resumed = FALSE


	// Iterate through each bucket starting from the practical offset
	while (practical_offset <= BUCKET_LEN && head_offset + ((practical_offset - 1) * world.tick_lag) <= world.time)
		var/datum/timedevent/timer
		while ((timer = bucket_list[practical_offset]))
			var/datum/callback/callBack = timer.callBack
			if (!callBack)
				stack_trace("Invalid timer: [get_timer_debug_string(timer)] world.time: [world.time], \
					head_offset: [head_offset], practical_offset: [practical_offset], bucket_joined: [timer.bucket_joined]")
				if (!timer.spent)
					bucket_resolution = null // force bucket recreation
					return

			timer.bucketEject() //pop the timer off of the bucket list.

			// Invoke callback if possible
			if (!timer.spent)
				timer.spent = world.time
				callBack.InvokeAsync()
				last_invoke_tick = world.time

			if (timer.flags & TIMER_LOOP) // Prepare looping timers to re-enter the queue
				timer.spent = 0
				timer.timeToRun = world.time + timer.wait
				timer.bucketJoin()
			else
				qdel(timer)

			if (MC_TICK_CHECK)
				break

		if (!bucket_list[practical_offset])
			// Empty the bucket, check if anything in the secondary queue should be shifted to this bucket
			bucket_list[practical_offset] = null // Just in case
			practical_offset++
			var/i = 0
			for (i in 1 to length(second_queue))
				timer = second_queue[i]
				if (timer.timeToRun >= TIMER_MAX(src))
					i--
					break

				// Check for timers that are scheduled to run in the past
				if (timer.timeToRun < head_offset)
					bucket_resolution = null // force bucket recreation
					stack_trace("[i] Invalid timer state: Timer in long run queue with a time to run less then head_offset. \
						[get_timer_debug_string(timer)] world.time: [world.time], head_offset: [head_offset], practical_offset: [practical_offset]")
					break

				// Check for timers that are not capable of being scheduled to run without rebuilding buckets
				if (timer.timeToRun < head_offset + TICKS2DS(practical_offset - 1))
					bucket_resolution = null // force bucket recreation
					stack_trace("[i] Invalid timer state: Timer in long run queue that would require a backtrack to transfer to \
						short run queue. [get_timer_debug_string(timer)] world.time: [world.time], head_offset: [head_offset], practical_offset: [practical_offset]")
					break

				timer.bucketJoin()
			if (i)
				second_queue.Cut(1, i+1)
		if (MC_TICK_CHECK)
			break

/**
 * Generates a string with details about the timed event for debugging purposes
 */
/datum/controller/subsystem/timer/proc/get_timer_debug_string(datum/timedevent/TE)
	. = "Timer: [TE]"
	. += "Prev: [TE.prev ? TE.prev : "NULL"], Next: [TE.next ? TE.next : "NULL"]"
	if(TE.spent)
		. += ", SPENT([TE.spent])"
	if(QDELETED(TE))
		. += ", QDELETED"
	if(!TE.callBack)
		. += ", NO CALLBACK"

/**
 * Destroys the existing buckets and creates new buckets from the existing timed events
 */
/datum/controller/subsystem/timer/proc/reset_buckets()
	WARNING("Timer buckets has been reset, this may cause timer to lag")
	bucket_reset_count++

	var/list/bucket_list = src.bucket_list // Store local reference to datum var, this is faster
	var/list/alltimers = list()

	// Get all timers currently in the buckets
	for (var/bucket_head in bucket_list)
		if (!bucket_head) // if bucket is empty for this tick
			continue
		var/datum/timedevent/bucket_node = bucket_head
		do
			alltimers += bucket_node
			bucket_node = bucket_node.next
		while(bucket_node && bucket_node != bucket_head)

	// Empty the list by zeroing and re-assigning the length
	bucket_list.len = 0
	bucket_list.len = BUCKET_LEN

	// Reset values for the subsystem to their initial values
	practical_offset = 1
	bucket_count = 0
	head_offset = world.time
	bucket_resolution = world.tick_lag

	// Add all timed events from the secondary queue as well
	alltimers += second_queue

	for (var/datum/timedevent/t as anything in alltimers)
		t.bucket_joined = FALSE
		t.bucket_pos = -1
		t.prev = null
		t.next = null

	// If there are no timers being tracked by the subsystem,
	// there is no need to do any further rebuilding
	if (!length(alltimers))
		return

	// Sort all timers by time to run
	sortTim(alltimers, .proc/cmp_timer)

	// Get the earliest timer, and if the TTR is earlier than the current world.time,
	// then set the head offset appropriately to be the earliest time tracked by the
	// current set of buckets
	var/datum/timedevent/head = alltimers[1]
	if (head.timeToRun < head_offset)
		head_offset = head.timeToRun

	// Iterate through each timed event and insert it into an appropriate bucket,
	// up unto the point that we can no longer insert into buckets as the TTR
	// is outside the range we are tracking, then insert the remainder into the
	// secondary queue
	var/new_bucket_count
	var/i = 1
	for (i in 1 to length(alltimers))
		var/datum/timedevent/timer = alltimers[i]
		if (!timer)
			continue

		// Check that the TTR is within the range covered by buckets, when exceeded we've finished
		if (timer.timeToRun >= TIMER_MAX(src))
			i--
			break

		// Check that timer has a valid callback and hasn't been invoked
		if (!timer.callBack || timer.spent)
			WARNING("Invalid timer: [get_timer_debug_string(timer)] world.time: [world.time], \
				head_offset: [head_offset], practical_offset: [practical_offset]")
			if (timer.callBack)
				qdel(timer)
			continue

		// Insert the timer into the bucket, and perform necessary doubly-linked list operations
		new_bucket_count++
		var/bucket_pos = BUCKET_POS(timer)
		timer.bucket_pos = bucket_pos
		timer.bucket_joined = TRUE

		var/datum/timedevent/bucket_head = bucket_list[bucket_pos]
		if (!bucket_head)
			bucket_list[bucket_pos] = timer
			timer.next = null
			timer.prev = null
			continue

		bucket_head.prev = timer
		timer.next = bucket_head
		timer.prev = null
		bucket_list[bucket_pos] = timer

	// Cut the timers that are tracked by the buckets from the secondary queue
	if (i)
		alltimers.Cut(1, i + 1)
	second_queue = alltimers
	bucket_count = new_bucket_count


/datum/controller/subsystem/timer/Recover()
	//Find the current timer sub-subsystem in global and recover its buckets etc
	var/datum/controller/subsystem/timer/timerSS = null
	for(var/global_var in global.vars)
		if (istype(global.vars[global_var],src.type))
			timerSS = global.vars[global_var]
	second_queue |= timerSS.second_queue
	hashes |= timerSS.hashes
	timer_id_dict |= timerSS.timer_id_dict
	bucket_list |= timerSS.bucket_list

/**
 * # Timed Event
 *
 * This is the actual timer, it contains the callback and necessary data to maintain
 * the timer.
 *
 * See the documentation for the timer subsystem for an explanation of the buckets referenced
 * below in next and prev
 */
/datum/timedevent
	/// ID used for timers when the TIMER_STOPPABLE flag is present
	var/id
	/// The callback to invoke after the timer completes
	var/datum/callback/callBack
	/// The time at which the callback should be invoked at
	var/timeToRun
	/// The length of the timer
	var/wait
	/// Unique hash generated when TIMER_UNIQUE flag is present
	var/hash
	/// The source of the timedevent, whatever called addtimer
	var/source
	/// Flags associated with the timer, see _DEFINES/subsystems.dm
	var/list/flags
	/// Time at which the timer was invoked or destroyed
	var/spent = 0
	/// An informative name generated for the timer as its representation in strings, useful for debugging
	var/name
	/// Next timed event in the bucket
	var/datum/timedevent/next
	/// Previous timed event in the bucket
	var/datum/timedevent/prev
	/// The timer subsystem this event is associated with
	var/datum/controller/subsystem/timer/timer_subsystem
	/// Boolean indicating if timer joined into bucket
	var/bucket_joined = FALSE
	/// Initial bucket position
	var/bucket_pos = -1

/datum/timedevent/New(datum/callback/callBack, wait, flags, datum/controller/subsystem/timer/timer_subsystem, hash, source)
	var/static/nextid = 1
	id = TIMER_ID_NULL
	src.callBack = callBack
	src.wait = wait
	src.flags = flags
	src.hash = hash
	src.source = source
	src.timer_subsystem = timer_subsystem || SStimer

	// Determine time at which the timer's callback should be invoked
	timeToRun = (flags & TIMER_CLIENT_TIME ? REALTIMEOFDAY : world.time) + wait

	// Include the timer in the hash table if the timer is unique
	if (flags & TIMER_UNIQUE)
		timer_subsystem.hashes[hash] = src

	// Generate ID for the timer if the timer is stoppable, include in the timer id dictionary
	if (flags & TIMER_STOPPABLE)
		id = num2text(nextid, 100)
		if (nextid >= SHORT_REAL_LIMIT)
			nextid += min(1, 2 ** round(nextid / SHORT_REAL_LIMIT))
		else
			nextid++
		timer_subsystem.timer_id_dict[id] = src

	if ((timeToRun < world.time || timeToRun < timer_subsystem.head_offset) && !(flags & TIMER_CLIENT_TIME))
		CRASH("Invalid timer state: Timer created that would require a backtrack to run (addtimer would never let this happen): [SStimer.get_timer_debug_string(src)]")

	if (callBack.object != GLOBAL_PROC && !QDESTROYING(callBack.object))
		LAZYADD(callBack.object.active_timers, src)

	bucketJoin()

/datum/timedevent/Destroy()
	..()
	if (flags & TIMER_UNIQUE && hash)
		timer_subsystem.hashes -= hash

	if (callBack && callBack.object && callBack.object != GLOBAL_PROC && callBack.object.active_timers)
		callBack.object.active_timers -= src
		UNSETEMPTY(callBack.object.active_timers)

	callBack = null

	if (flags & TIMER_STOPPABLE)
		timer_subsystem.timer_id_dict -= id

	if (flags & TIMER_CLIENT_TIME)
		if (!spent)
			spent = world.time
			timer_subsystem.clienttime_timers -= src
		return QDEL_HINT_IWILLGC

	if (!spent)
		spent = world.time
		bucketEject()
	else
		if (prev && prev.next == src)
			prev.next = next
		if (next && next.prev == src)
			next.prev = prev
	next = null
	prev = null
	return QDEL_HINT_IWILLGC

/**
 * Removes this timed event from any relevant buckets, or the secondary queue
 */
/datum/timedevent/proc/bucketEject()
	// Store local references for the bucket list and secondary queue
	// This is faster than referencing them from the datum itself
	var/list/bucket_list = timer_subsystem.bucket_list
	var/list/second_queue = timer_subsystem.second_queue

	// Attempt to get the head of the bucket
	var/datum/timedevent/buckethead
	if(bucket_pos > 0)
		buckethead = bucket_list[bucket_pos]

	// Decrement the number of timers in buckets if the timed event is
	// the head of the bucket, or has a TTR less than TIMER_MAX implying it fits
	// into an existing bucket, or is otherwise not present in the secondary queue
	if(buckethead == src)
		bucket_list[bucket_pos] = next
		timer_subsystem.bucket_count--
	else if(timeToRun < TIMER_MAX(timer_subsystem))
		timer_subsystem.bucket_count--
	else
		var/l = length(second_queue)
		second_queue -= src
		if(l == length(second_queue))
			timer_subsystem.bucket_count--

	// Remove the timed event from the bucket, ensuring to maintain
	// the integrity of the bucket's list if relevant
	if (prev && prev.next == src)
		prev.next = next
	if (next && next.prev == src)
		next.prev = prev
	prev = next = null
	bucket_pos = -1
	bucket_joined = FALSE

/**
 * Attempts to add this timed event to a bucket, will enter the secondary queue
 * if there are no appropriate buckets at this time.
 *
 * Secondary queueing of timed events will occur when the timespan covered by the existing
 * buckets is exceeded by the time at which this timed event is scheduled to be invoked.
 * If the timed event is tracking client time, it will be added to a special bucket.
 */
/datum/timedevent/proc/bucketJoin()
	// Generate debug-friendly name for timer
	var/static/list/bitfield_flags = list("TIMER_UNIQUE", "TIMER_OVERRIDE", "TIMER_CLIENT_TIME", "TIMER_STOPPABLE", "TIMER_NO_HASH_WAIT", "TIMER_LOOP")
	name = "Timer: [id] (\ref[src]), TTR: [timeToRun], wait:[wait] Flags: [jointext(bitfield_to_list(flags, bitfield_flags), ", ")], \
		callBack: \ref[callBack], callBack.object: [callBack.object]\ref[callBack.object]([getcallingtype()]), \
		callBack.delegate:[callBack.delegate]([callBack.arguments ? callBack.arguments.Join(", ") : ""]), source: [source]"

	if (bucket_joined)
		stack_trace("Bucket already joined! [name]")

	// Check if this timed event should be diverted to the client time bucket, or the secondary queue
	var/list/L
	if (flags & TIMER_CLIENT_TIME)
		L = timer_subsystem.clienttime_timers
	else if (timeToRun >= TIMER_MAX(timer_subsystem))
		L = timer_subsystem.second_queue
	if(L)
		BINARY_INSERT(src, L, /datum/timedevent, src, timeToRun, COMPARE_KEY)
		return

	// Get a local reference to the bucket list, this is faster than referencing the datum
	var/list/bucket_list = timer_subsystem.bucket_list

	// Find the correct bucket for this timed event
	bucket_pos = BUCKET_POS(src)

	if (bucket_pos < timer_subsystem.practical_offset && timeToRun < (timer_subsystem.head_offset + TICKS2DS(BUCKET_LEN)))
		WARNING("Bucket pos in past: bucket_pos = [bucket_pos] < practical_offset = [timer_subsystem.practical_offset] \
			&& timeToRun = [timeToRun] < [timer_subsystem.head_offset + TICKS2DS(BUCKET_LEN)], Timer: [name]")
		bucket_pos = timer_subsystem.practical_offset // Recover bucket_pos to avoid timer blocking queue

	var/datum/timedevent/bucket_head = bucket_list[bucket_pos]
	timer_subsystem.bucket_count++

	// If there is no timed event at this position, then the bucket is 'empty'
	// and we can just set this event to that position
	if (!bucket_head)
		bucket_joined = TRUE
		bucket_list[bucket_pos] = src
		return

	// Otherwise, we merely add this timed event into the bucket, which is a
	// doubly-linked list
	bucket_joined = TRUE
	bucket_head.prev = src
	next = bucket_head
	prev = null
	bucket_list[bucket_pos] = src

/**
 * Returns a string of the type of the callback for this timer
 */
/datum/timedevent/proc/getcallingtype()
	. = "ERROR"
	if (callBack.object == GLOBAL_PROC)
		. = "GLOBAL_PROC"
	else
		. = "[callBack.object.type]"

/**
 * Create a new timer and insert it in the queue.
 * You should not call this directly, and should instead use the addtimer macro, which includes source information.
 *
 * Arguments:
 * * callback the callback to call on timer finish
 * * wait deciseconds to run the timer for
 * * flags flags for this timer, see: code\__DEFINES\subsystems.dm
 */
/proc/_addtimer(datum/callback/callback, wait = 0, flags = 0, datum/controller/subsystem/timer/timer_subsystem, file, line)
	if (!callback)
		CRASH("addtimer called without a callback")

	if (wait < 0)
		stack_trace("addtimer called with a negative wait. Converting to [world.tick_lag]")

	if (callback.object != GLOBAL_PROC && QDELETED(callback.object) && !QDESTROYING(callback.object))
		stack_trace("addtimer called with a callback assigned to a qdeleted object. In the future such timers will not \
			be supported and may refuse to run or run with a 0 wait")

	wait = max(CEILING(wait, world.tick_lag), world.tick_lag)

	if(wait >= INFINITY)
		CRASH("Attempted to create timer with INFINITY delay")

	timer_subsystem = timer_subsystem || SStimer

	// Generate hash if relevant for timed events with the TIMER_UNIQUE flag
	var/hash
	if (flags & TIMER_UNIQUE)
		var/list/hashlist = list(callback.object, "([REF(callback.object)])", callback.delegate, flags & TIMER_CLIENT_TIME)
		if(!(flags & TIMER_NO_HASH_WAIT))
			hashlist += wait
		hashlist += callback.arguments
		hash = hashlist.Join("|||||||")

		var/datum/timedevent/hash_timer = timer_subsystem.hashes[hash]
		if(hash_timer)
			if (hash_timer.spent) // it's pending deletion, pretend it doesn't exist.
				hash_timer.hash = null // but keep it from accidentally deleting us
			else
				if (flags & TIMER_OVERRIDE)
					hash_timer.hash = null // no need having it delete it's hash if we are going to replace it
					qdel(hash_timer)
				else
					if (hash_timer.flags & TIMER_STOPPABLE)
						. = hash_timer.id
					return
	else if(flags & TIMER_OVERRIDE)
		stack_trace("TIMER_OVERRIDE used without TIMER_UNIQUE")

	var/datum/timedevent/timer = new(callback, wait, flags, timer_subsystem, hash, file && "[file]:[line]")
	return timer.id

/**
 * Delete a timer
 *
 * Arguments:
 * * id a timerid or a /datum/timedevent
 */
/proc/deltimer(id, datum/controller/subsystem/timer/timer_subsystem)
	if (!id)
		return FALSE
	if (id == TIMER_ID_NULL)
		CRASH("Tried to delete a null timerid. Use TIMER_STOPPABLE flag")
	if (istype(id, /datum/timedevent))
		qdel(id)
		return TRUE
	timer_subsystem = timer_subsystem || SStimer
	//id is string
	var/datum/timedevent/timer = timer_subsystem.timer_id_dict[id]
	if (timer && (!timer.spent || timer.flags & TIMER_DELETE_ME))
		qdel(timer)
		return TRUE
	return FALSE

/**
 * Get the remaining deciseconds on a timer
 *
 * Arguments:
 * * id a timerid or a /datum/timedevent
 */
/proc/timeleft(id, datum/controller/subsystem/timer/timer_subsystem)
	if (!id)
		return null
	if (id == TIMER_ID_NULL)
		CRASH("Tried to get timeleft of a null timerid. Use TIMER_STOPPABLE flag")
	if (istype(id, /datum/timedevent))
		var/datum/timedevent/timer = id
		return timer.timeToRun - world.time
	timer_subsystem = timer_subsystem || SStimer
	//id is string
	var/datum/timedevent/timer = timer_subsystem.timer_id_dict[id]
	if(!timer || timer.spent)
		return null
	return timer.timeToRun - (timer.flags & TIMER_CLIENT_TIME ? REALTIMEOFDAY : world.time)

#undef BUCKET_LEN
#undef BUCKET_POS
#undef TIMER_MAX
#undef TIMER_ID_MAX
