//Used for active reactions in reagents/equilibrium datums

SUBSYSTEM_DEF(reagents)
	name = "Reagents"
	init_order = INIT_ORDER_REAGENTS
	priority = FIRE_PRIORITY_REAGENTS
	wait = 0.5 SECONDS
	flags = SS_NO_INIT | SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/processing = list()
	var/list/currentrun = list()

//Comment to delete: I don't really understand SS that well.
/datum/controller/subsystem/reagents/stat_entry(msg)
	msg = "reagents:[length(processing)]"
	return ..()

//This is a copy - I'll customise it as it's needed. I'm a little shaky on how all of this works, but I might write a handiler to keep real time with reactions.
/datum/controller/subsystem/reagents/fire(resumed = FALSE)
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/datum/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		else if(thing.process(wait * 0.1) == PROCESS_KILL)
			// fully stop so that a future START_PROCESSING will work
			STOP_PROCESSING(src, thing)
		if (MC_TICK_CHECK)
			return
