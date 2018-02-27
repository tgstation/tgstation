PROCESSING_SUBSYSTEM_DEF(goap)
	name = "Goal Oriented Action Planning"
	wait = 2
	stat_tag = "GP"
	priority = 1

/datum/controller/subsystem/processing/goap/fire(resumed = 0)
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	while(current_run.len)
		var/datum/goap_agent/thing = current_run[current_run.len]
		current_run.len--
		if(thing && thing.able_to_run())
			if(QDELETED(thing) || thing.process(wait) == PROCESS_KILL)
				processing -= thing
			if (MC_TICK_CHECK)
				return