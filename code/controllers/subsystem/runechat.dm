///SSrunechat, essentially acts as a hyper specialized SStimer that only works for [/datum/chatmessage] instances to schedule events in the future
///without the overhead of more general timing systems.
SUBSYSTEM_DEF(runechat)
	name = "Runechat"
	wait = 1
	flags = SS_TICKER|SS_NO_INIT
	priority = FIRE_PRIORITY_RUNECHAT

	///list that keeps track of all runechat message datums by their creation_string. used to keep track of runechat messages.
	///associative list of the form: list(creation string = the chatmessage datum assigned to that string)
	var/list/messages_by_creation_string = list()

	///anything going into message_lifespan_bucket must be offset from world.time by exactly this amount, otherwise it goes in non_default_bucket
	var/lifespan_bucket_time = CHAT_MESSAGE_LIFESPAN + CHAT_MESSAGE_EOL_FADE + CHAT_MESSAGE_SPAWN_TIME + 1 SECONDS

	/**
	 * the default timer bucket for chat messages that are fully visible until their time in this list is over.
	 * this bucket is ONLY filled with chatmessages with a lifespan of exactly [lifespan_bucket_time] so they can be cheaply put at the end of the list.
	 * if the time is different then they go into [non_default_bucket]
	 *
	 * insertion time: O(1) - appends the end of this list
	 *
	 * associative list of the form: list("[world.time that messages are set to start fading at]" = list(all [/datum/message_timer] set to fade at that time))
	 * e.g. list("1024.5" = list(event, event), "1025" = list(event), "1029.5" = list(event, event, event)) <- ascending order
	 */
	var/list/message_lifespan_bucket = list()

	/**
	 * the default bucket only accepts a single duration for incoming events - this is because that duration is by far the most common one
	 * only using the single predefined message duration allows us to simply append events to the end of the default bucket.
	 * however if for any reason an event comes in with another duration we cant have to search through this list to find its place
	 * so that takes longer.
	 *
	 * insertion time: O(log(n)) - must be binary inserted
	 *
	 * associative list of the form: list("[world.time that messages are set to be deleted at]" = list(all [/datum/message_timer] set to fade at that time))
	 * e.g. list("1024.5" = list(event, event), "1025" = list(event), "1029.5" = list(event, event, event)) <- ascending order
	 */
	var/list/non_default_bucket = list()

	///list used to find timers by their hash id. the timers hold any further information needed to find them
	///associative list of the form: list(timer hash = [/datum/message_timer] instance with that timer)
	var/list/timers_by_hash = list()

/datum/controller/subsystem/runechat/fire(resumed)
	var/current_time = world.time

	for(var/timer_end in message_lifespan_bucket)
		if(text2num(timer_end) > current_time)
			break

		for(var/datum/message_timer/timer_to_invoke as anything in message_lifespan_bucket[timer_end])
			end_timer(timer_to_invoke, message_lifespan_bucket, timer_end)

		if(MC_TICK_CHECK)
			return

	for(var/timer_end in non_default_bucket)
		if(text2num(timer_end) > current_time)
			break

		for(var/datum/message_timer/timer_to_invoke as anything in non_default_bucket[timer_end])
			end_timer(timer_to_invoke, non_default_bucket, timer_end)

		if(MC_TICK_CHECK)
			return

/**
 * schedule an event in the subsystem for a callback created for a [/datum/chatmessage] instance. acts like addtimer()
 *
 * Arguments:
 * * callback_to_schedule - callback to be invoked after duration deciseconds have elapsed. must contain a [/datum/chatmessage] datum as its object
 * * duration - how many deciseconds the event will last for. will take more cpu if it doesnt match the default value depending on the given event
 */
/datum/controller/subsystem/runechat/proc/schedule_message(datum/callback/callback_to_schedule, duration)

	if(!callback_to_schedule || duration <= 0)
		return FALSE

	var/end_time = CEILING(world.time + duration, world.tick_lag)
	//round up to the nearest possible world.time value to increase the chance of grouping up timers into the same bucket

	var/datum/message_timer/new_timer = generate_timer(callback_to_schedule, end_time)
	if(!new_timer)
		stack_trace("something tried to use SSrunechat as a timer for something other than a /datum/chatmessage created callback!")
		return FALSE

	if(duration == lifespan_bucket_time)
		bucket_insert(new_timer, message_lifespan_bucket, end_time, append_insert = TRUE)
	else
		bucket_insert(new_timer, non_default_bucket, end_time, append_insert = FALSE)

	return new_timer.timer_hash

/datum/controller/subsystem/runechat/proc/adjust_timer_by_hash(timer_hash, new_duration)
	if(new_duration <= 0)
		return FALSE

	var/datum/message_timer/retrieved_timer = timers_by_hash[timer_hash]
	if(!retrieved_timer)
		return FALSE

	var/new_end_time = world.time + new_duration

	var/list/old_bucket = retrieved_timer.bucket_house
	var/old_end_time = retrieved_timer.scheduled_time

	bucket_pop(retrieved_timer, old_bucket, old_end_time)
	bucket_insert(retrieved_timer, non_default_bucket, new_end_time, append_insert = FALSE)

	return TRUE

/datum/controller/subsystem/runechat/proc/delete_timer_by_hash(timer_hash)

	var/datum/message_timer/retrieved_timer = timers_by_hash[timer_hash]
	if(!retrieved_timer)
		return FALSE

	var/list/bucket_list = retrieved_timer.bucket_house
	var/timer_end_time = retrieved_timer.scheduled_time

	bucket_pop(retrieved_timer, bucket_list, timer_end_time)
	qdel(retrieved_timer)
	return TRUE

/datum/controller/subsystem/runechat/proc/get_time_remaining(timer_hash)
	var/datum/message_timer/retrieved_timer = timers_by_hash[timer_hash]
	if(!retrieved_timer)
		return FALSE

	return text2num(retrieved_timer.scheduled_time)

/datum/controller/subsystem/runechat/proc/generate_timer(datum/callback/callback, end_time, list/bucket_to_use)
	PRIVATE_PROC(TRUE)
	if(!istype(callback, /datum/callback) || !istype(callback.object, /datum/chatmessage))
		return FALSE

	var/static/counter = 0

	var/datum/message_timer/new_timer = new(callback, end_time, "[REALTIMEOFDAY]-[end_time]-[counter++]", bucket_to_use)
	return new_timer

/**
 * private proc for inserting timer_to_insert into bucket_to_use at its scheduled end_time.
 * adds a list association: "[end_time]" = list(timer_to_insert)
 * located either at the end of bucket_to_insert or binary inserted into it if binary_insert = FALSE
 * if that end_time key already exists, then its associated with its own list of timers to execute at that world.time, so add the timer to that inner list
 */
/datum/controller/subsystem/runechat/proc/bucket_insert(datum/message_timer/timer_to_insert, list/bucket_to_use, end_time, append_insert = FALSE)
	PRIVATE_PROC(TRUE)

	if(append_insert)
		if(bucket_to_use["[end_time]"])
			bucket_to_use["[end_time]"] += timer_to_insert //add to that inner list if our end_time already exists in the outer list
		return TRUE

	if(!length(bucket_to_use))//if theres nothing in the bucket list then we can just append to it anyways
		bucket_to_use["[end_time]"] = list(timer_to_insert)
		return TRUE

	//otherwise, do a binary insert

	///we found an end_time exactly equal to ours already existing, so append the timer to the list associated with that end time
	var/existing_list = FALSE

	var/right_index = length(bucket_to_use)
	var/left_index = 1

	var/target_index = (left_index + right_index) >> 1
	var/compared_time = text2num(bucket_to_use[target_index])//i wish we could associate numbers as keys without wrapping them in text

	while(left_index <= right_index)//binary insert algorithm.
		if(end_time > compared_time)
			left_index = target_index + 1

		else if(end_time < compared_time)
			right_index = target_index - 1

		else
			existing_list = TRUE
			break

		target_index = (left_index + right_index) >> 1
		compared_time = text2num(bucket_to_use[target_index])

	if(existing_list)
		//append our timer to the inner list
		bucket_to_use[target_index] += timer_to_insert
	else
		//insert the key at that index and then associate that with a list containing timer
		INSERT_ASSOCIATIVE_KV_PAIR(bucket_to_use, "[end_time]", list(timer_to_insert), max(target_index, 1))

	timers_by_hash[timer_to_insert.timer_hash] = timer_to_insert

	return TRUE

/datum/controller/subsystem/runechat/proc/end_timer(datum/message_timer/timer_to_end, list/bucket_to_use, bucket_index)
	PRIVATE_PROC(TRUE)

	timer_to_end.invoke()
	bucket_pop(timer_to_end, bucket_to_use, bucket_index)

/datum/controller/subsystem/runechat/proc/bucket_pop(datum/message_timer/timer_to_remove, list/bucket_to_use, bucket_index)
	PRIVATE_PROC(TRUE)

	var/list/timer_list = bucket_to_use[bucket_index]
	timer_list -= timer_to_remove

	if(!length(timer_list))
		bucket_to_use -= bucket_index//remove the world.time index if there are no more timers set to be invoked at that time

	timers_by_hash[timer_to_remove.timer_hash] -= timer_to_remove

	return TRUE


///wrapper class for the invoked callbacks that contains data relevant to its place in the subsystem lists
/datum/message_timer
	///the callback to invoke
	var/datum/callback/message_callback
	///the world.time we are scheduled to invoke() in. text form
	///used for finding this timer's location after finding its reference via the timers hash
	var/scheduled_time = "0"
	///unique hash used to get a reference to us.
	var/timer_hash = ""
	///the bucket list on SSrunechat we have been put into.
	///used for finding this timer's location after finding its reference via the timers hash
	var/list/bucket_house

/datum/message_timer/New(datum/callback/message_callback, scheduled_time, timer_hash, list/bucket_house)
	. = ..()
	src.message_callback = message_callback
	src.scheduled_time = "[scheduled_time]"
	src.timer_hash = timer_hash
	src.bucket_house = bucket_house

/datum/message_timer/Destroy(force, ...)
	message_callback = null
	. = ..()

///literally just a wrapper for invoking our callback so SSrunechat/fire() doesnt have to cast the callback itself
/datum/message_timer/proc/invoke()
	message_callback.InvokeAsync()
