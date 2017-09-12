PROCESSING_SUBSYSTEM_DEF(projectiles)
	name = "Projectiles"
	priority = 25
	wait = 1
	stat_tag = "PP"
	flags = SS_NO_INIT|SS_TICKER|SS_KEEP_TIMING

/datum/controller/subsystem/processing/projectiles/fire(resumed = 0)
	if (!resumed)
		currentrun = processing.Copy()
	var/list/current_run = currentrun
	while(current_run.len)
		var/datum/thing = current_run[current_run.len]
		current_run.len--
		if(QDELETED(thing) || thing.process(wait) == PROCESS_KILL)
			processing -= thing
