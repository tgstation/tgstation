SUBSYSTEM_DEF(movement)
	name = "Movement Loop"
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING|SS_NO_INIT
	wait = 1 //Fire each tick
	///The list of datums we're processing
	var/list/processing = list()
	///Used to make pausing possible
	var/list/currentrun = list()
	///An assoc list of source to movement datum, used for lookups and removal
	var/list/lookup = list()

/**
 * Adds an object to the subsystem,
 *
 * Arguments:
 * looptype - What sort of loop do we want to make
 * override - Should we replace the current loop if it exists. Defaults to TRUE
 * moving - The atom we want to move
 * delay - How many deci-seconds to wait between fires, defaults to the lowest value, 0.1
 * timeout - Time in deci-seconds until the moveloop self expires, defaults to INFINITY
 *
 * Returns TRUE if the loop sucessfully started, or FALSE if it failed
**/
/datum/controller/subsystem/movement/proc/start_looping(looptype, override = TRUE, atom/moving, delay = 1, timeout = INFINITY)
	PRIVATE_PROC(TRUE)
	var/datum/move_loop/old = lookup[moving]
	if(old)
		if(!override)
			return FALSE
		remove_from_loop(moving, old) //Kill it

	//Kill me
	var/datum/move_loop/loop = new looptype()
	processing += loop
	currentrun += loop
	lookup[moving] = loop //Cache the datum so lookups are cheap
	var/list/arguments = args.Copy(3) //Send all the arguments past override to the new datum
	return loop.setup(arglist(arguments))

///Stops an object from being processed, assuming it is being processed
/datum/controller/subsystem/movement/proc/stop_looping(atom/moving)
	var/datum/loop = lookup[moving]
	if(loop)
		remove_from_loop(moving, lookup[moving])
		return TRUE
	return FALSE

///Removes a loop from processing based on the moving object and the loop itself
/datum/controller/subsystem/movement/proc/remove_from_loop(atom/moving, datum/move_loop/loop)
	processing -= loop
	currentrun -= loop
	lookup -= moving
	qdel(loop)

/datum/controller/subsystem/movement/fire(resumed)
	if(!resumed)
		currentrun = processing.Copy()

	var/list/running = currentrun //Cache for... you've heard this before
	while(running.len)
		var/datum/move_loop/loop = running[running.len]
		running.len--
		loop.process(wait) //This shouldn't get nulls, if it does, runtime
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/movement/stat_entry(msg)
	msg = "P:[length(processing)]"
	return ..()














