//Used for active reactions in reagents/equilibrium datums

SUBSYSTEM_DEF(reagents)
	name = "Reagents"
	init_order = INIT_ORDER_REAGENTS
	priority = FIRE_PRIORITY_REAGENTS
	wait = 0.5 SECONDS //You might think that rate_up_lim has to be set to half, but since everything is normalised around delta_time, it automatically adjusts it to be per second. Magic!
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/processing = list()
	var/list/currentrun = list()
	///What time was it when we last ticked
	var/previous_world_time = 0

/datum/controller/subsystem/reagents/Initialize()
	//So our first step isn't insane
	previous_world_time = world.time
	//Build GLOB lists - see holder.dm
	build_chemical_reagent_list()
	build_chemical_reactions_list()
	return ..()

//Comment to delete: I don't really understand SS that well. Please review me
/datum/controller/subsystem/reagents/stat_entry(msg)
	msg = "reagents:[length(processing)]"
	.=..()
	msg = "number of ticks that took a long time (over 2s): [overly_laggy_ticks]"

/datum/controller/subsystem/reagents/fire(resumed = FALSE)
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	//Attempt to realtime reactions in a way that doesn't make them overtly dangerous
	var/delta_realtime = (world.time - previous_world_time)/10 //normalise to s from ds
	previous_world_time = world.time

	while(current_run.len)
		var/datum/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		else if(thing.process(delta_realtime) == PROCESS_KILL) //we are realtime
			// fully stop so that a future START_PROCESSING will work
			STOP_PROCESSING(src, thing)
		if (MC_TICK_CHECK)
			return
