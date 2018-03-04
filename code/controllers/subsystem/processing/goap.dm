PROCESSING_SUBSYSTEM_DEF(goap)
	name = "Goal Oriented Action Planning"
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING
	wait = 2
	stat_tag = "GP"
	priority = 1
	init_order = -101

/datum/controller/subsystem/processing/goap/Initialize(timeofday)
	generate_pathfinding_list()
	..()

/datum/controller/subsystem/processing/goap/fire(resumed = 0)
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/datum/goap_agent/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing))
			processing -= thing
		else if(thing.able_to_run())
			if(thing.process(wait) == PROCESS_KILL)
				processing -= thing
		if(MC_TICK_CHECK)
			return