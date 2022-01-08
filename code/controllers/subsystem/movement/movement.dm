SUBSYSTEM_DEF(movement)
	name = "Movement Loops"
	flags = SS_NO_INIT|SS_BACKGROUND|SS_TICKER|SS_KEEP_TIMING
	wait = 1 //Fire each tick
	///The list of datums we're processing
	var/list/processing = list()
	///Used to make pausing possible
	var/list/currentrun = list()
	///The time we started our last fire at
	var/canonical_time = 0
	///The visual delay of the subsystem
	var/visual_delay = 1

/datum/controller/subsystem/movement/stat_entry(msg)
	msg = "P:[length(processing)]"
	return ..()

/datum/controller/subsystem/movement/Recover()
	//Get ready this is gonna be horrible
	//We need to do this to support subtypes by the by
	var/list/typenames = return_typenames(src.type)
	var/our_name = typenames[length(typenames)] //Get the last name in the list, IE the subsystem identifier

	var/datum/controller/subsystem/movement/old_version = global.vars["SS[our_name]"]
	processing = old_version.processing
	currentrun = old_version.currentrun

/datum/controller/subsystem/movement/fire(resumed)
	if(!resumed)
		canonical_time = world.time
		currentrun = processing.Copy()

	var/list/running = currentrun //Cache for... you've heard this before
	while(running.len)
		var/datum/move_loop/loop = running[running.len]
		running.len--
		if(loop.timer <= canonical_time)
			loop.process(wait) //This shouldn't get nulls, if it does, runtime
		if (MC_TICK_CHECK)
			return
	visual_delay = MC_AVERAGE_FAST(visual_delay, max((world.time - canonical_time) / wait, 1))

/datum/controller/subsystem/movement/proc/add_loop(datum/move_loop/add)
	processing += add
	add.start_loop()

/datum/controller/subsystem/movement/proc/remove_loop(datum/move_loop/remove)
	processing -= remove
	currentrun -= remove
	remove.stop_loop()

