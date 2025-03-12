/// The subsystem is intended to tick things related to space/newtonian movement, such as constant sources of inertia
MOVEMENT_SUBSYSTEM_DEF(newtonian_movement)
	name = "Newtonian Movement"
	flags = SS_NO_INIT|SS_TICKER
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/stat_tag = "P" //Used for logging
	var/list/processing = list()
	var/list/currentrun = list()

/datum/controller/subsystem/movement/newtonian_movement/stat_entry(msg)
	msg = "[stat_tag]:[length(processing)]"
	return ..()

/datum/controller/subsystem/movement/newtonian_movement/fire(resumed = FALSE)
	if(!resumed)
		canonical_time = world.time
		currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/datum/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		else if(thing.process(TICKS2DS(wait) * 0.1) == PROCESS_KILL)
			// fully stop so that a future START_PROCESSING will work
			STOP_PROCESSING(src, thing)
		if (MC_TICK_CHECK)
			return

	for(var/list/bucket_info as anything in sorted_buckets)
		var/time = bucket_info[MOVEMENT_BUCKET_TIME]
		if(time > canonical_time || MC_TICK_CHECK)
			return
		pour_bucket(bucket_info)

/datum/controller/subsystem/movement/newtonian_movement/proc/fire_moveloop(datum/move_loop/loop)
	// Loop isn't even running right now
	if(!(loop.status & MOVELOOP_STATUS_QUEUED))
		return
	// Drop the loop, process it, and if its still valid - queue it again
	dequeue_loop(loop)
	loop.process()
	if(QDELETED(loop))
		return
	loop.timer = world.time + loop.delay
	queue_loop(loop)
