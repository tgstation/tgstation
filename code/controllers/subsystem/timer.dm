#define BUCKET_LEN (world.fps*1*60) //how many ticks should we keep in the bucket. (1 minutes worth)
#define BUCKET_POS(timer) ((round((timer.timeToRun - SStimer.head_offset) / world.tick_lag) % BUCKET_LEN) + 1)
#define TIMER_MAX (world.time + TICKS2DS(min(BUCKET_LEN-(SStimer.practical_offset-DS2TICKS(world.time - SStimer.head_offset))-1, BUCKET_LEN-1)))
#define TIMER_ID_MAX (2**24) //max float with integer precision

SUBSYSTEM_DEF(timer)
	name = "Timer"
	wait = 1 //SS_TICKER subsystem, so wait is in ticks
	init_order = INIT_ORDER_TIMER

	flags = SS_TICKER|SS_NO_INIT

	var/list/datum/timedevent/processing = list()
	var/list/hashes = list()

	var/head_offset = 0 //world.time of the first entry in the the bucket.
	var/practical_offset = 1 //index of the first non-empty item in the bucket.
	var/bucket_resolution = 0 //world.tick_lag the bucket was designed for
	var/bucket_count = 0 //how many timers are in the buckets

	var/list/bucket_list = list() //list of buckets, each bucket holds every timer that has to run that byond tick.

	var/list/timer_id_dict = list() //list of all active timers assoicated to their timer id (for easy lookup)

	var/list/clienttime_timers = list() //special snowflake timers that run on fancy pansy "client time"

	var/last_invoke_tick = 0
	var/static/last_invoke_warning = 0
	var/static/bucket_auto_reset = TRUE

/datum/controller/subsystem/timer/PreInit()
	bucket_list.len = BUCKET_LEN

/datum/controller/subsystem/timer/stat_entry(msg)
	..("B:[bucket_count] P:[length(processing)] H:[length(hashes)] C:[length(clienttime_timers)]")

/datum/controller/subsystem/timer/fire(resumed = FALSE)
	var/lit = last_invoke_tick
	var/last_check = world.time - TIMER_NO_INVOKE_WARNING
	var/list/bucket_list = src.bucket_list
	if(!bucket_count)
		last_invoke_tick = world.time

	if(lit && lit < last_check && last_invoke_warning < last_check)
		last_invoke_warning = world.time
		var/msg = "No regular timers processed in the last [TIMER_NO_INVOKE_WARNING] ticks[bucket_auto_reset ? ", resetting buckets" : ""]!"
		message_admins(msg)
		WARNING(msg)
		if(bucket_auto_reset)
			bucket_resolution = 0

		log_world("Timer bucket reset. world.time: [world.time], head_offset: [head_offset], practical_offset: [practical_offset]")
		for (var/i in 1 to length(bucket_list))
			var/datum/timedevent/bucket_head = bucket_list[i]
			if (!bucket_head)
				continue
				
			log_world("Active timers at index [i]:")
			
			var/datum/timedevent/bucket_node = bucket_head
			var/anti_loop_check = 1000
			do
				log_world(get_timer_debug_string(bucket_node))
				bucket_node = bucket_node.next
				anti_loop_check--
			while(bucket_node && bucket_node != bucket_head && anti_loop_check)
		log_world("Active timers in the processing queue:")
		for(var/I in processing)
			log_world(get_timer_debug_string(I))

	while(length(clienttime_timers))
		var/datum/timedevent/ctime_timer = clienttime_timers[clienttime_timers.len]
		if (ctime_timer.timeToRun <= REALTIMEOFDAY)
			--clienttime_timers.len
			var/datum/callback/callBack = ctime_timer.callBack
			ctime_timer.spent = REALTIMEOFDAY
			callBack.InvokeAsync()
			qdel(ctime_timer)
		else
			break	//None of the rest are ready to run
		if (MC_TICK_CHECK)
			return

	var/static/list/spent = list()
	var/static/datum/timedevent/timer
	var/static/current_offset = 1
	if (practical_offset > BUCKET_LEN)
		head_offset += TICKS2DS(BUCKET_LEN)
		practical_offset = 1
		resumed = FALSE

	if ((length(bucket_list) != BUCKET_LEN) || (world.tick_lag != bucket_resolution))
		reset_buckets()
		bucket_list = src.bucket_list
		resumed = FALSE


	if (!resumed)
		timer = null
		current_offset = practical_offset

	while (practical_offset <= BUCKET_LEN && head_offset + (practical_offset*world.tick_lag) <= world.time)
		var/datum/timedevent/head = bucket_list[current_offset]
		if (!timer || !head || timer == head)
			current_offset = practical_offset
			head = bucket_list[current_offset]
			timer = head
		while (timer)
			var/datum/callback/callBack = timer.callBack
			if (!callBack)
				qdel(timer)
				bucket_resolution = null //force bucket recreation
				CRASH("Invalid timer: [get_timer_debug_string(timer)] world.time: [world.time], head_offset: [head_offset], practical_offset: [practical_offset]")

			if (!timer.spent)
				spent += timer
				timer.spent = world.time
				callBack.InvokeAsync()
				last_invoke_tick = world.time

			timer = timer.next
			if (timer == head)
				break
			if (MC_TICK_CHECK)
				return

		bucket_list[current_offset++] = null
		practical_offset = current_offset

		//we freed up a bucket, lets see if anything in processing needs to be shifted to that bucket.
		var/i = 1
		var/L = length(processing)
		for (i in 1 to L)
			timer = processing[i]
			if (timer.timeToRun >= TIMER_MAX)
				debug_admins("Ending timer minishift: i=[i], L = [L], timer.timeToRun = [timer.timeToRun], TIMER_MAX = [TIMER_MAX].")
				break
			bucket_count++
			var/bucket_pos = max(1, BUCKET_POS(timer))

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
		if (i > 1)
			processing.Cut(1, i)

		timer = null

	bucket_count -= length(spent)

	for (var/spent_timer in spent)
		qdel(spent_timer)

	spent.len = 0

//formated this way to be runtime resistant
/datum/controller/subsystem/timer/proc/get_timer_debug_string(datum/timedevent/TE)
	. = "Timer: [TE]"
	. += "Prev: [TE.prev ? TE.prev : "NULL"], Next: [TE.next ? TE.next : "NULL"]"
	if(TE.spent)
		. += ", SPENT([TE.spent])"
	if(QDELETED(TE))
		. += ", QDELETED"
	if(!TE.callBack)
		. += ", NO CALLBACK"

/datum/controller/subsystem/timer/proc/reset_buckets()
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
		if (timer.timeToRun >= TIMER_MAX)
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

/datum/timedevent
	var/id
	var/datum/callback/callBack
	var/timeToRun
	var/hash
	var/list/flags
	var/spent = 0 //time we ran the timer.
	var/name //for easy debugging.
	//cicular doublely linked list
	var/datum/timedevent/next
	var/datum/timedevent/prev

	var/static/nextid = 1

/datum/timedevent/New(datum/callback/callBack, timeToRun, flags, hash)
	id = TIMER_ID_NULL
	src.callBack = callBack
	src.timeToRun = timeToRun
	src.flags = flags
	src.hash = hash

	if (flags & TIMER_UNIQUE)
		SStimer.hashes[hash] = src
	if (flags & TIMER_STOPPABLE)
		do
			if (nextid >= TIMER_ID_MAX)
				nextid = 1
			id = nextid++
		while(SStimer.timer_id_dict["timerid" + num2text(id, 8)])
		SStimer.timer_id_dict["timerid" + num2text(id, 8)] = src

	name = "Timer: " + num2text(id, 8) + ", TTR: [timeToRun], Flags: [jointext(bitfield2list(flags, list("TIMER_UNIQUE", "TIMER_OVERRIDE", "TIMER_CLIENT_TIME", "TIMER_STOPPABLE", "TIMER_NO_HASH_WAIT")), ", ")], callBack: [REF(callBack)], callBack.object: [callBack.object][REF(callBack.object)]([getcallingtype()]), callBack.delegate:[callBack.delegate]([callBack.arguments ? callBack.arguments.Join(", ") : ""])"

	if (spent)
		CRASH("HOLY JESUS. WHAT IS THAT? WHAT THE FUCK IS THAT?")

	if (callBack.object != GLOBAL_PROC)
		LAZYADD(callBack.object.active_timers, src)


	var/list/L

	if (flags & TIMER_CLIENT_TIME)
		L = SStimer.clienttime_timers
	else
		//calculate the longest timer the bucket list can hold
		if (timeToRun >= TIMER_MAX)
			L = SStimer.processing


	if (L)
		//binary search sorted insert
		var/cttl = length(L)
		if(cttl)
			var/left = 1
			var/right = cttl
			var/mid

			var/datum/timedevent/item = L[1]
			while (left < right)
				mid = (left+right) >> 1 //rounded divide by two for hedgehogs
				item = L[mid]
				if (item.timeToRun <= timeToRun)
					left = mid+1
				else
					right = mid

			mid = item.timeToRun > timeToRun ? mid : mid+1
			L.Insert(mid, src)

		else
			L += src
		return

	//get the list of buckets
	var/list/bucket_list = SStimer.bucket_list

	//calculate our place in the bucket list
	var/bucket_pos = BUCKET_POS(src)

	//get the bucket for our tick
	var/datum/timedevent/bucket_head = bucket_list[bucket_pos]
	SStimer.bucket_count++
	//empty bucket, we will just add ourselves
	if (!bucket_head)
		bucket_list[bucket_pos] = src
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
		SStimer.timer_id_dict -= "timerid" + num2text(id, 8)

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


		if (timeToRun >= TIMER_MAX)
			SStimer.processing -= src
		else
			var/bucketpos = BUCKET_POS(src)
			var/datum/timedevent/buckethead
			var/list/bucket_list = SStimer.bucket_list
			buckethead = bucket_list[bucketpos]
			SStimer.bucket_count--
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

/datum/timedevent/proc/getcallingtype()
	. = "ERROR"
	if (callBack.object == GLOBAL_PROC)
		. = "GLOBAL_PROC"
	else
		. = "[callBack.object.type]"

/proc/addtimer(datum/callback/callback, wait, flags)
	if (!callback)
		return

	wait = max(wait, 0)

	var/hash

	if (flags & TIMER_UNIQUE)
		var/list/hashlist
		if(flags & TIMER_NO_HASH_WAIT)
			hashlist = list(callback.object, "([REF(callback.object)])", callback.delegate, flags & TIMER_CLIENT_TIME)
		else
			hashlist = list(callback.object, "([REF(callback.object)])", callback.delegate, wait, flags & TIMER_CLIENT_TIME)
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
	return timer.id 

/proc/deltimer(id)
	if (!id)
		return FALSE
	if (id == TIMER_ID_NULL)
		CRASH("Tried to delete a null timerid. Use TIMER_STOPPABLE flag")
	if (!istext(id))
		if (istype(id, /datum/timedevent))
			qdel(id)
			return TRUE
	//id is string
	var/datum/timedevent/timer = SStimer.timer_id_dict["timerid[id]"]
	if (timer && !timer.spent)
		qdel(timer)
		return TRUE
	return FALSE


#undef BUCKET_LEN
#undef BUCKET_POS
#undef TIMER_MAX
#undef TIMER_ID_MAX