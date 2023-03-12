SUBSYSTEM_DEF(movement)
	name = "Movement Loops"
	flags = SS_NO_INIT|SS_BACKGROUND|SS_TICKER
	wait = 1 //Fire each tick
	/*
		A breif aside about the bucketing system here

		The goal is to allow for higher loads of semi long delays while reducing cpu usage
		Bucket insertion and management are much less complex then what you might see in SStimer
		This is intentional, as we loop our delays much more often then that ss is designed for
		We also have much shorter term timers, so we need to worry about redundant buckets much less
	*/
	///Assoc list of "target time" -> list(things to process). Used for quick lookup
	var/list/buckets = list()
	///Sorted list of list(target time, bucket to process)
	var/list/sorted_buckets = list()
	///The time we started our last fire at
	var/canonical_time = 0
	///The visual delay of the subsystem
	var/visual_delay = 1

/datum/controller/subsystem/movement/stat_entry(msg)
	var/total_len = 0
	for(var/list/bucket as anything in sorted_buckets)
		total_len += length(bucket[MOVEMENT_BUCKET_LIST])
	msg = "B:[length(sorted_buckets)] E:[total_len]"
	return ..()

/datum/controller/subsystem/movement/Recover()
	//Get ready this is gonna be horrible
	//We need to do this to support subtypes by the by
	var/list/typenames = return_typenames(src.type)
	var/our_name = typenames[length(typenames)] //Get the last name in the list, IE the subsystem identifier

	var/datum/controller/subsystem/movement/old_version = global.vars["SS[our_name]"]
	buckets = old_version.buckets
	sorted_buckets = old_version.sorted_buckets

/datum/controller/subsystem/movement/fire(resumed)
	if(!resumed)
		canonical_time = world.time

	for(var/list/bucket_info as anything in sorted_buckets)
		var/time = bucket_info[MOVEMENT_BUCKET_TIME]
		if(time > canonical_time || MC_TICK_CHECK)
			return
		pour_bucket(bucket_info)

/// Processes a bucket of movement loops (This should only ever be called by fire(), it exists to prevent runtime fuckery)
/datum/controller/subsystem/movement/proc/pour_bucket(list/bucket_info)
	var/list/processing = bucket_info[MOVEMENT_BUCKET_LIST] // Cache for lookup speed
	while(processing.len)
		var/datum/move_loop/loop = processing[processing.len]
		processing.len--
		loop.process() //This shouldn't get nulls, if it does, runtime
		if(!QDELETED(loop)) //Re-Insert the loop
			loop.timer = world.time + loop.delay
			queue_loop(loop)
		if (MC_TICK_CHECK)
			break

	if(length(processing))
		return // Still work to be done
	var/bucket_time = bucket_info[MOVEMENT_BUCKET_TIME]
	smash_bucket(1, bucket_time) // We assume we're the first bucket in the queue right now
	visual_delay = MC_AVERAGE_FAST(visual_delay, max((world.time - canonical_time) / wait, 1))

/// Removes a bucket from our system. You only need to pass in the time, but if you pass in the index of the list you save us some work
/datum/controller/subsystem/movement/proc/smash_bucket(index, bucket_time)
	var/sorted_length = length(sorted_buckets)
	if(!index)
		index = sorted_length + 1 // let's setup the failure condition
		for(var/i in 1 to sorted_length)
			var/list/bucket_info = sorted_buckets[i]
			if(bucket_info[MOVEMENT_BUCKET_TIME] != bucket_time)
				continue
			index = i
			break
	//This is technically possible, if our bucket is smashed inside the loop's process
	//Let's be nice, the cost of doing it is cheap
	if(index > sorted_length || !buckets["[bucket_time]"])
		return

	sorted_buckets.Cut(index, index + 1) //Removes just this list
	//Removes the assoc lookup too
	buckets -= "[bucket_time]"

/datum/controller/subsystem/movement/proc/queue_loop(datum/move_loop/loop)
	var/target_time = loop.timer
	var/string_time = "[target_time]"
	// If there's no bucket for this, lets set them up
	if(!buckets[string_time])
		buckets[string_time] = list()
		// This makes assoc buckets and sorted buckets point to the same place, allowing for quicker inserts
		var/list/new_bucket = list(list(target_time, buckets[string_time]))
		BINARY_INSERT_DEFINE(new_bucket, sorted_buckets, SORT_VAR_NO_TYPE, list(target_time), SORT_FIRST_INDEX, COMPARE_KEY)

	buckets[string_time] += loop

/datum/controller/subsystem/movement/proc/dequeue_loop(datum/move_loop/loop)
	var/list/our_entries = buckets["[loop.timer]"]
	our_entries -= loop
	if(!length(our_entries))
		smash_bucket(bucket_time = loop.timer) // We can't pass an index in for context because we don't know our position

/datum/controller/subsystem/movement/proc/add_loop(datum/move_loop/add)
	add.loop_started()
	if(QDELETED(add))
		return
	queue_loop(add)

/datum/controller/subsystem/movement/proc/remove_loop(datum/move_loop/remove)
	dequeue_loop(remove)
	remove.loop_stopped()

