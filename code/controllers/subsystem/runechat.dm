/// Controls how many buckets should be kept, each representing a tick. (30 seconds worth)
#define BUCKET_LEN (world.fps * 1 * 30)
/// Helper for getting the correct bucket for a given chatmessage
#define BUCKET_POS(scheduled_destruction) (((round((scheduled_destruction - SSrunechat.head_offset) / world.tick_lag) + 1) % BUCKET_LEN) || BUCKET_LEN)
/// Gets the maximum time at which messages will be handled in buckets, used for deferring to secondary queue
#define BUCKET_LIMIT (world.time + TICKS2DS(min(BUCKET_LEN - (SSrunechat.practical_offset - DS2TICKS(world.time - SSrunechat.head_offset)) - 1, BUCKET_LEN - 1)))

/**
 * # Runechat Subsystem
 *
 * Maintains a timer-like system to handle destruction of runechat messages. Much of this code is modeled
 * after or adapted from the timer subsystem.
 *
 * Note that this has the same structure for storing and queueing messages as the timer subsystem does
 * for handling timers: the bucket_list is a list of chatmessage datums, each of which are the head
 * of a circularly linked list. Any given index in bucket_list could be null, representing an empty bucket.
 */
SUBSYSTEM_DEF(runechat)
	name = "Runechat"
	flags = SS_TICKER | SS_NO_INIT
	wait = 1
	priority = FIRE_PRIORITY_RUNECHAT

	/// world.time of the first entry in the bucket list, effectively the 'start time' of the current buckets
	var/head_offset = 0
	/// Index of the first non-empty bucket
	var/practical_offset = 1
	/// world.tick_lag the bucket was designed for
	var/bucket_resolution = 0
	/// How many messages are in the buckets
	var/bucket_count = 0
	/// List of buckets, each bucket holds every message that has to be killed that byond tick
	var/list/bucket_list = list()
	/// Queue used for storing messages that are scheduled for deletion too far in the future for the buckets
	var/list/datum/chatmessage/second_queue = list()

/datum/controller/subsystem/runechat/PreInit()
	bucket_list.len = BUCKET_LEN
	head_offset = world.time
	bucket_resolution = world.tick_lag

/datum/controller/subsystem/runechat/stat_entry(msg)
	msg = "ActMsgs:[bucket_count] SecQueue:[length(second_queue)]"
	return msg

/datum/controller/subsystem/runechat/fire(resumed = FALSE)
	// Store local references to datum vars as it is faster to access them this way
	var/list/bucket_list = src.bucket_list

	if (MC_TICK_CHECK)
		return


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
	// Store a reference to the 'working' chatmessage so that we can resume if the MC
	// has us stop mid-way through processing
	var/static/datum/chatmessage/cm
	if (!resumed)
		cm = null

	// Iterate through each bucket starting from the practical offset
	while (practical_offset <= BUCKET_LEN && head_offset + ((practical_offset - 1) * world.tick_lag) <= world.time)
		var/datum/chatmessage/bucket_head = bucket_list[practical_offset]
		if (!cm || !bucket_head || cm == bucket_head)
			bucket_head = bucket_list[practical_offset]
			cm = bucket_head

		while (cm)
			// If the chatmessage hasn't yet had its life ended then do that now
			var/datum/chatmessage/next = cm.next
			if (!cm.eol_complete)
				cm.end_of_life()
			else if (!QDELETED(cm)) // otherwise if we haven't deleted it yet, do so (this is after EOL completion)
				qdel(cm)

			if (MC_TICK_CHECK)
				return

			// Break once we've processed the entire bucket
			cm = next
			if (cm == bucket_head)
				break

		// Empty the bucket, check if anything in the secondary queue should be shifted to this bucket
		bucket_list[practical_offset++] = null
		var/i = 0
		for (i in 1 to length(second_queue))
			cm = second_queue[i]
			if (cm.scheduled_destruction >= BUCKET_LIMIT)
				i--
				break

			// Transfer the message into the bucket, performing necessary circular doubly-linked list operations
			bucket_count++
			var/bucket_pos = max(1, BUCKET_POS(cm.scheduled_destruction))
			var/datum/timedevent/head = bucket_list[bucket_pos]
			if (!head)
				bucket_list[bucket_pos] = cm
				cm.next = null
				cm.prev = null
				continue

			if (!head.prev)
				head.prev = head
			cm.next = head
			cm.prev = head.prev
			cm.next.prev = cm
			cm.prev.next = cm
		if (i)
			second_queue.Cut(1, i + 1)
		cm = null

/datum/controller/subsystem/runechat/Recover()
	bucket_list |= SSrunechat.bucket_list
	second_queue |= SSrunechat.second_queue

/datum/controller/subsystem/runechat/proc/reset_buckets()
	bucket_list.len = BUCKET_LEN
	head_offset = world.time
	bucket_resolution = world.tick_lag

/**
 * Enters the runechat subsystem with this chatmessage, inserting it into the end-of-life queue
 *
 * This will also account for a chatmessage already being registered, and in which case
 * the position will be updated to remove it from the previous location if necessary
 *
 * Arguments:
 * * new_sched_destruction Optional, when provided is used to update an existing message with the new specified time
 */
/datum/chatmessage/proc/enter_subsystem(new_sched_destruction = 0)
	// Get local references from subsystem as they are faster to access than the datum references
	var/list/bucket_list = SSrunechat.bucket_list
	var/list/second_queue = SSrunechat.second_queue

	// When necessary, de-list the chatmessage from its previous position
	if (new_sched_destruction)
		if (scheduled_destruction >= BUCKET_LIMIT)
			second_queue -= src
		else
			SSrunechat.bucket_count--
			var/bucket_pos = BUCKET_POS(scheduled_destruction)
			if (bucket_pos > 0)
				var/datum/chatmessage/bucket_head = bucket_list[bucket_pos]
				if (bucket_head == src)
					bucket_list[bucket_pos] = next
			if (prev != next)
				prev.next = next
				next.prev = prev
			else
				prev?.next = null
				next?.prev = null
			prev = next = null
		scheduled_destruction = new_sched_destruction

	// Ensure the scheduled destruction time is properly bound to avoid missing a scheduled event
	scheduled_destruction = max(CEILING(scheduled_destruction, world.tick_lag), world.time + world.tick_lag)

	// Handle insertion into the secondary queue if the required time is outside our tracked amounts
	if (scheduled_destruction >= BUCKET_LIMIT)
		BINARY_INSERT(src, SSrunechat.second_queue, /datum/chatmessage, src, scheduled_destruction, COMPARE_KEY)
		return

	// Get bucket position and a local reference to the datum var, it's faster to access this way
	var/bucket_pos = BUCKET_POS(scheduled_destruction)

	// Get the bucket head for that bucket, increment the bucket count
	var/datum/chatmessage/bucket_head = bucket_list[bucket_pos]
	SSrunechat.bucket_count++

	// If there is no existing head of this bucket, we can set this message to be that head
	if (!bucket_head)
		bucket_list[bucket_pos] = src
		return

	// Otherwise it's a simple insertion into the circularly doubly-linked list
	if (!bucket_head.prev)
		bucket_head.prev = bucket_head
	next = bucket_head
	prev = bucket_head.prev
	next.prev = src
	prev.next = src


/**
 * Removes this chatmessage datum from the runechat subsystem
 */
/datum/chatmessage/proc/leave_subsystem()
	// Attempt to find the bucket that contains this chat message
	var/bucket_pos = BUCKET_POS(scheduled_destruction)

	// Get local references to the subsystem's vars, faster than accessing on the datum
	var/list/bucket_list = SSrunechat.bucket_list
	var/list/second_queue = SSrunechat.second_queue

	// Attempt to get the head of the bucket
	var/datum/chatmessage/bucket_head
	if (bucket_pos > 0)
		bucket_head = bucket_list[bucket_pos]

	// Decrement the number of messages in buckets if the message is
	// the head of the bucket, or has a SD less than BUCKET_LIMIT implying it fits
	// into an existing bucket, or is otherwise not present in the secondary queue
	if(bucket_head == src)
		bucket_list[bucket_pos] = next
		SSrunechat.bucket_count--
	else if(scheduled_destruction < BUCKET_LIMIT)
		SSrunechat.bucket_count--
	else
		var/l = length(second_queue)
		second_queue -= src
		if(l == length(second_queue))
			SSrunechat.bucket_count--

	// Remove the message from the bucket, ensuring to maintain
	// the integrity of the bucket's list if relevant
	if(prev != next)
		prev.next = next
		next.prev = prev
	else
		prev?.next = null
		next?.prev = null
	prev = next = null

#undef BUCKET_LEN
#undef BUCKET_POS
#undef BUCKET_LIMIT
