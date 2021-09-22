SUBSYSTEM_DEF(movement)
	name = "Movement Loop"
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING|SS_NO_INIT
	wait = 1 //Fire each tick
	///The list of datums we're processing
	var/list/processing = list()
	///Used to make pausing possible
	var/list/currentrun = list()


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














