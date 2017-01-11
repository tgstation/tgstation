#define BUCKET_LEN (world.fps*10*60) //how many ticks should we keep in the bucket. (10 minutes worth)
#define BUCKET_POS(timer) (round((timer.timeToRun - SStimer.head_offset) / world.tick_lag) + 1)
var/datum/subsystem/timer/SStimer

/datum/subsystem/timer
	name = "Timer"
	wait = 1 //SS_TICKER subsystem, so wait is in ticks
	init_order = 1
	display_order = 3

	flags = SS_FIRE_IN_LOBBY|SS_TICKER|SS_NO_INIT

	var/list/datum/timedevent/processing
	var/list/hashes

	var/head_offset = 0 //world.time of the first entry in the the bucket.
	var/practical_offset = 0 //index of the first non-empty item in the bucket.
	var/bucket_resolution = 0 //world.tick_lag the bucket was designed for

	var/list/buckets //list of buckets, each bucket holds every timer that has to run that byond tick.

	var/list/timer_id_dict //list of all active timers assoicated to their timer id (for easy lookup)

	var/list/timer_src_dict //list of everything with an active timer attached to it as key with a list of those timers as the value (for destroy)

	var/list/clienttime_timers //special snowflake timers that run on fancy pansy "client time"


/datum/subsystem/timer/New()
	processing = list()
	hashes = list()

	timer_id_dict = list()
	timer_src_dict = list()

	clienttime_timers = list()

	NEW_SS_GLOBAL(SStimer)


/datum/subsystem/timer/stat_entry(msg)
	..("P:[length(processing)] H:[length(hashes)] C:[length(clienttime_timers)]")

/datum/subsystem/timer/fire()
	if (length(clienttime_timers))
		for (var/thing in clienttime_timers)
			var/datum/timedevent/event = thing
			if (event.timeToRun <= REALTIMEOFDAY)
				var/datum/callback/callback = event.callback
				qdel(event) //this is right, we delete the event before running it so that stack overflows don't cause us to repeatively run the same event
				callback.InvokeAsync()

			if (MC_TICK_CHECK)
				return

	if (head_offset + (world.tick_lag * BUCKET_LEN) < world.time || length(src.buckets) != BUCKET_LEN || world.tick_lag != bucket_resolution)
		refill_buckets()

	var/list/buckets = src.buckets
	while (practical_offset <= BUCKET_LEN && head_offset + (practical_offset*world.tick_lag) <= world.time && !MC_TICK_CHECK)
		var/datum/timedevent/event = buckets[practical_offset]
		while (event)
			var/datum/callback/callback = event.callback
			if (!callback)
				stack_trace("FAILURE! [event]||[event.timeToRun]|[qdeleted(event)]|||[world.time]||[head_offset]||[practical_offset]")
			if (event.timeToRun > world.time)
				stack_trace("HOLY JESUS! SHIT BE FUCKED [event]||[event.timeToRun]||[world.time]||[event.callback.object]||[event.callback.delegate]||[head_offset]||[practical_offset]")
			qdel(event) //same as above
			callback.InvokeAsync()
			if (MC_TICK_CHECK)
				return
			event = buckets[practical_offset]

		practical_offset++

/datum/subsystem/timer/proc/refill_buckets()
	sortTim(processing, /proc/cmp_timer)
	src.buckets = new(BUCKET_LEN)
	practical_offset = 1
	bucket_resolution = world.tick_lag
	var/list/buckets = src.buckets
	var/new_offset
	for (var/thing in processing)
		var/datum/timedevent/event = thing
		if (!event)
			processing -= event
			continue

		if (isnull(new_offset))
			new_offset = event.timeToRun

		var/bucket_pos = round((event.timeToRun - new_offset) / world.tick_lag) + 1
		if (bucket_pos > BUCKET_LEN)
			break

		var/datum/timedevent/bucket_head = buckets[bucket_pos]
		if (!bucket_head)
			buckets[bucket_pos] = event
			continue

		if (!bucket_head.prev)
			bucket_head.prev = bucket_head
		event.next = bucket_head
		event.prev = bucket_head.prev
		event.next.prev = event
		event.prev.next = event
	head_offset = new_offset


/datum/subsystem/timer/Recover()
	processing |= SStimer.processing
	hashes |= SStimer.hashes

/datum/timedevent
	var/id
	var/datum/callback/callback
	var/timeToRun
	var/datum/timerid
	var/hash
	var/list/flags

	//cicular doublely linked list
	var/datum/timedevent/next
	var/datum/timedevent/prev

	var/static/nextid = 1

/datum/timedevent/New(datum/callback/callback, timeToRun, flags, hash)
	id = nextid++
	src.callback = callback
	src.timeToRun = timeToRun
	src.flags = flags

	if (hash)
		src.hash = hash
		SStimer.hashes[hash] = src

	SStimer.timer_id_dict["timerid[id]"] = src

	if (callback.object != GLOBAL_PROC)
		SStimer.timer_src_dict[callback.object] = src

	if (flags & TIMER_CLIENT_TIME)
		SStimer.clienttime_timers += src
		return

	SStimer.processing += src

	//get the list of buckets
	var/list/buckets = SStimer.buckets
	//calculate our place in the bucket list
	var/bucket_pos = BUCKET_POS(src)
	//we are too far aways from needing to run to be in the bucket list, refill_buckets() will handle us.
	debug_admins("Timer insert: [bucket_pos] for [timeToRun] at [world.time] and [SStimer.head_offset]")
	if (bucket_pos > length(buckets))
		return
	//get the bucket for our tick
	var/datum/timedevent/event = buckets[bucket_pos]
	//empty bucket, we will just add ourself
	if (!event)
		buckets[bucket_pos] = src
		if (bucket_pos < SStimer.practical_offset)
			SStimer.practical_offset = bucket_pos
		return
	//other wise, lets do a simplified linked list add.
	if (!event.prev)
		event.prev = event

	next = event
	prev = event.prev
	next.prev = src
	prev.next = src


/datum/timedevent/Destroy()
	if (hash)
		SStimer.hashes -= hash

	SStimer.timer_id_dict -= "timerid[id]"

	if (callback && callback.object != GLOBAL_PROC)
		SStimer.timer_src_dict -= callback.object

	callback = null

	if (flags & TIMER_CLIENT_TIME)
		SStimer.clienttime_timers -= src
		return QDEL_HINT_IWILLGC

	SStimer.processing -= src

	if (prev == next && next)
		next.prev = null
		prev.next = null
	else
		if (prev)
			prev.next = next

		if (next)
			next.prev = prev

	var/bucketpos = BUCKET_POS(src)
	var/datum/timedevent/buckethead
	var/list/buckets = SStimer.buckets

	if (bucketpos > 0 && bucketpos <= length(buckets))
		buckethead = buckets[bucketpos]
	if (buckethead == src)
		buckets[bucketpos] = next

	prev = null
	next = null

	return QDEL_HINT_IWILLGC


/proc/addtimer(datum/callback/callback, wait, flags)
	if (!callback)
		return

	if (wait <= 0)
		callback.InvokeAsync()
		return

	var/hash

	if (flags & TIMER_UNIQUE)
		var/list/hashlist = list(callback.object, "(\ref[callback.object])", callback.delegate, wait, flags & TIMER_CLIENT_TIME)
		hashlist += callback.arguments
		hash = hashlist.Join("|||||||")

		var/datum/timedevent/hash_event = SStimer.hashes[hash]
		if(hash_event)
			if (flags & TIMER_OVERRIDE)
				qdel(hash_event)
			else
				return hash_event.id

	var/timeToRun = world.time + wait
	if (flags & TIMER_CLIENT_TIME)
		timeToRun = REALTIMEOFDAY + wait

	var/datum/timedevent/event = new(callback, timeToRun, flags, hash)


	return event.id


/proc/deltimer(id)
	if (!id)
		return FALSE
	var/datum/timedevent/event = SStimer.timer_id_dict["timerid[id]"]
	if (event)
		qdel(event)
		return TRUE
	return FALSE
