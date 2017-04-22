SUBSYSTEM_DEF(inbounds)
	name = "Inbounds"
	priority = 40
	flags = SS_NO_INIT

	var/list/processing = list()
	var/list/currentrun = list()

/datum/controller/subsystem/inbounds/stat_entry()
	..("P:[processing.len]")

/datum/controller/subsystem/inbounds/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/atom/movable/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.check_in_bounds(wait)
		else
			SSinbounds.processing -= thing
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/inbounds/Recover()
	processing = SSinbounds.processing
