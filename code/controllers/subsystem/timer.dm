#define BUCKET_LEN (world.fps*1*60) //how many ticks should we keep in the bucket. (1 minutes worth)
#define BUCKET_POS(timer) (round((timer.timeToRun - SStimer.head_offset) / world.tick_lag) + 1)

SUBSYSTEM_DEF(timer)
	name = "Timer"
	wait = 1 //SS_TICKER subsystem, so wait is in ticks
	init_order = INIT_ORDER_TIMER

	flags = SS_TICKER|SS_NO_INIT

	var/list/datum/timedevent/processing = list()
	var/list/hashes = list()

	var/head_offset = 0 //world.time of the first entry in the the bucket.
	var/practical_offset = 0 //index of the first non-empty item in the bucket.
	var/bucket_resolution = 0 //world.tick_lag the bucket was designed for
	var/bucket_count = 0 //how many timers are in the buckets

	var/list/bucket_list = list() //list of buckets, each bucket holds every timer that has to run that byond tick.

	var/list/timer_id_dict = list() //list of all active timers assoicated to their timer id (for easy lookup)

	var/list/clienttime_timers = list() //special snowflake timers that run on fancy pansy "client time"

	var/last_invoke_tick = 0
	var/static/last_invoke_warning = 0
	var/static/bucket_auto_reset = TRUE

/datum/controller/subsystem/timer/stat_entry(msg)
	..("B:[bucket_count] P:[length(processing)] H:[length(hashes)] C:[length(clienttime_timers)]")

/datum/controller/subsystem/timer/fire(resumed = FALSE)
	var/lit = last_invoke_tick
	var/last_check = world.time - TIMER_NO_INVOKE_WARNING

	if(!bucket_count)
		last_invoke_tick = world.time

	if(lit && lit < last_check && last_invoke_warning < last_check)
		last_invoke_warning = world.time
		var/msg = "No regular timers processed in the last [TIMER_NO_INVOKE_WARNING] ticks[bucket_auto_reset ? ", resetting buckets" : ""]!"
		message_admins(msg)
		WARNING(msg)
		if(bucket_auto_reset)
			bucket_resolution = 0
		
		log_world("Active timers at tick [world.time]:")
		for(var/I in processing)
			var/datum/timedevent/TE = I
			msg = "Timer: [TE.id]: TTR: [TE.timeToRun], Flags: [TE.flags], "
			if(TE.spent)
				msg += "SPENT"
			else
				var/datum/callback/CB = TE.callBack
				msg += "callBack: "
				if(CB.object == GLOBAL_PROC)
					msg += "GP: [CB.delegate]"
				else
					msg += "[!QDELETED(CB.object) ? CB.object : "SRC DELETED"]: [CB.delegate]("
					var/first = TRUE
					for(var/J in CB.arguments)
						msg += "[first ? "" : ", "][J]"
						first = FALSE
					msg += ")"
			log_world(msg)

	while(length(clienttime_timers))
		var/datum/timedevent/ctime_timer = clienttime_timers[clienttime_timers.len]
		if (ctime_timer.timeToRun <= REALTIMEOFDAY)
			--clienttime_timers.len
			var/datum/callback/callBack = ctime_timer.callBack
			ctime_timer.spent = TRUE
			callBack.InvokeAsync()
			qdel(ctime_timer)
		else
			break	//None of the rest are ready to run
		if (MC_TICK_CHECK)
			return

	var/static/list/spent = list()
	var/static/datum/timedevent/timer
	var/static/datum/timedevent/head

	if (practical_offset > BUCKET_LEN || (!resumed  && length(src.bucket_list) != BUCKET_LEN || world.tick_lag != bucket_resolution))
		shift_buckets()
		resumed = FALSE


	if (!resumed)
		timer = null
		head = null

	var/list/bucket_list = src.bucket_list

	while (practical_offset <= BUCKET_LEN && head_offset + (practical_offset*world.tick_lag) <= world.time && !MC_TICK_CHECK)
		if (!timer || !head || timer == head)
			head = bucket_list[practical_offset]
			if (!head)
				practical_offset++
				if (MC_TICK_CHECK)
					break
				continue
			timer = head
		do
			var/datum/callback/callBack = timer.callBack
			if (!callBack)
				qdel(timer)
				bucket_resolution = null //force bucket recreation
				CRASH("Invalid timer: timer.timeToRun=[timer.timeToRun]||QDELETED(timer)=[QDELETED(timer)]||world.time=[world.time]||head_offset=[head_offset]||practical_offset=[practical_offset]||timer.spent=[timer.spent]")

			if (!timer.spent)
				spent += timer
				timer.spent = TRUE
				callBack.InvokeAsync()
				last_invoke_tick = world.time

			timer = timer.next

			if (MC_TICK_CHECK)
				return
		while (timer && timer != head)
		timer = null
		bucket_list[practical_offset++] = null
		if (MC_TICK_CHECK)
			return

	bucket_count -= length(spent)

	for (var/spent_timer in spent)
		qdel(spent_timer)

	spent.len = 0


/datum/controller/subsystem/timer/proc/shift_buckets()
	var/list/bucket_list = src.bucket_list
	var/list/alltimers = list()
	//collect the timers currently in the bucket
	for (var/bucket_head in bucket_list)
		if (!bucket_head)
			continue
		var/datum/timedevent/bucket_node = bucket_head
		do
			alltimers += bucket_node
			bucket_node = bucket_node.next
		while(bucket_node && bucket_node != bucket_head)

	bucket_list.len = 0
	bucket_list.len = BUCKET_LEN

	practical_offset = 1
	bucket_count = 0
	head_offset = world.time
	bucket_resolution = world.tick_lag

	alltimers += processing
	if (!length(alltimers))
		return

	sortTim(alltimers, .proc/cmp_timer)

	var/datum/timedevent/head = alltimers[1]

	if (head.timeToRun < head_offset)
		head_offset = head.timeToRun

	var/list/timers_to_remove = list()

	for (var/thing in alltimers)
		var/datum/timedevent/timer = thing
		if (!timer)
			timers_to_remove += timer
			continue

		var/bucket_pos = BUCKET_POS(timer)
		if (bucket_pos > BUCKET_LEN)
			break

		timers_to_remove += timer //remove it from the big list once we are done
		if (!timer.callBack || timer.spent)
			continue
		bucket_count++
		var/datum/timedevent/bucket_head = bucket_list[bucket_pos]
		if (!bucket_head)
			bucket_list[bucket_pos] = timer
			timer.next = null
			timer.prev = null
			continue

		if (!bucket_head.prev)
			bucket_head.prev = bucket_head
		timer.next = bucket_head
		timer.prev = bucket_head.prev
		timer.next.prev = timer
		timer.prev.next = timer

	processing = (alltimers - timers_to_remove)


/datum/controller/subsystem/timer/Recover()
	processing |= SStimer.processing
	hashes |= SStimer.hashes
	timer_id_dict |= SStimer.timer_id_dict
	bucket_list |= SStimer.bucket_list

/datum/var/list/active_timers
/datum/timedevent
	var/id
	var/datum/callback/callBack
	var/timeToRun
	var/hash
	var/list/flags
	var/spent = FALSE //set to true right before running.

	//cicular doublely linked list
	var/datum/timedevent/next
	var/datum/timedevent/prev

	var/static/nextid = 1

/datum/timedevent/New(datum/callback/callBack, timeToRun, flags, hash)
	id = nextid++
	src.callBack = callBack
	src.timeToRun = timeToRun
	src.flags = flags
	src.hash = hash

	if (flags & TIMER_UNIQUE)
		SStimer.hashes[hash] = src
	if (flags & TIMER_STOPPABLE)
		SStimer.timer_id_dict["timerid[id]"] = src

	if (callBack.object != GLOBAL_PROC)
		LAZYADD(callBack.object.active_timers, src)

	if (flags & TIMER_CLIENT_TIME)
		//sorted insert
		var/list/ctts = SStimer.clienttime_timers
		var/cttl = length(ctts)
		if(cttl)
			var/datum/timedevent/Last = ctts[cttl]
			if(Last.timeToRun >= timeToRun)
				ctts += src
			else if(cttl > 1)
				for(var/I in cttl to 1)
					var/datum/timedevent/E = ctts[I]
					if(E.timeToRun <= timeToRun)
						ctts.Insert(src, I)
						break
		else
			ctts += src
		return

	//get the list of buckets
	var/list/bucket_list = SStimer.bucket_list
	//calculate our place in the bucket list
	var/bucket_pos = BUCKET_POS(src)
	//we are too far aways from needing to run to be in the bucket list, shift_buckets() will handle us.
	if (bucket_pos > length(bucket_list))
		SStimer.processing += src
		return
	//get the bucket for our tick
	var/datum/timedevent/bucket_head = bucket_list[bucket_pos]
	SStimer.bucket_count++
	//empty bucket, we will just add ourselves
	if (!bucket_head)
		bucket_list[bucket_pos] = src
		if (bucket_pos < SStimer.practical_offset)
			SStimer.practical_offset = bucket_pos
		return
	//other wise, lets do a simplified linked list add.
	if (!bucket_head.prev)
		bucket_head.prev = bucket_head
	next = bucket_head
	prev = bucket_head.prev
	next.prev = src
	prev.next = src

/datum/timedevent/Destroy()
	..()
	if (flags & TIMER_UNIQUE)
		SStimer.hashes -= hash


	if (callBack && callBack.object && callBack.object != GLOBAL_PROC && callBack.object.active_timers)
		callBack.object.active_timers -= src
		UNSETEMPTY(callBack.object.active_timers)

	callBack = null

	if (flags & TIMER_STOPPABLE)
		SStimer.timer_id_dict -= "timerid[id]"

	if (flags & TIMER_CLIENT_TIME)
		SStimer.clienttime_timers -= src
		return QDEL_HINT_IWILLGC

	if (!spent)
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
		var/list/bucket_list = SStimer.bucket_list

		if (bucketpos > 0 && bucketpos <= length(bucket_list))
			buckethead = bucket_list[bucketpos]
			SStimer.bucket_count--
		else
			SStimer.processing -= src

		if (buckethead == src)
			bucket_list[bucketpos] = next
	else
		if (prev && prev.next == src)
			prev.next = next
		if (next && next.prev == src)
			next.prev = prev
	next = null
	prev = null
	return QDEL_HINT_IWILLGC

/proc/addtimer(datum/callback/callback, wait, flags)
	if (!callback)
		return

	wait = max(wait, 0)

	var/hash

	if (flags & TIMER_UNIQUE)
		var/list/hashlist
		if(flags & TIMER_NO_HASH_WAIT)
			hashlist = list(callback.object, "(\ref[callback.object])", callback.delegate, flags & TIMER_CLIENT_TIME)
		else
			hashlist = list(callback.object, "(\ref[callback.object])", callback.delegate, wait, flags & TIMER_CLIENT_TIME)
		hashlist += callback.arguments
		hash = hashlist.Join("|||||||")

		var/datum/timedevent/hash_timer = SStimer.hashes[hash]
		if(hash_timer)
			if (hash_timer.spent) //it's pending deletion, pretend it doesn't exist.
				hash_timer.hash = null
				SStimer.hashes -= hash
			else

				if (flags & TIMER_OVERRIDE)
					qdel(hash_timer)
				else
					if (hash_timer.flags & TIMER_STOPPABLE)
						. = hash_timer.id
					return


	var/timeToRun = world.time + wait
	if (flags & TIMER_CLIENT_TIME)
		timeToRun = REALTIMEOFDAY + wait

	var/datum/timedevent/timer = new(callback, timeToRun, flags, hash)
	if (flags & TIMER_STOPPABLE)
		return timer.id

/proc/deltimer(id)
	if (!id)
		return FALSE
	if (!istext(id))
		if (istype(id, /datum/timedevent))
			qdel(id)
			return TRUE
	var/datum/timedevent/timer = SStimer.timer_id_dict["timerid[id]"]
	if (timer && !timer.spent)
		qdel(timer)
		return TRUE
	return FALSE


#undef BUCKET_LEN
#undef BUCKET_POS
