var/datum/controller/subsystem/diseases/SSdisease

/datum/controller/subsystem/diseases
	name = "Diseases"
	flags = SS_KEEP_TIMING|SS_NO_INIT

	var/list/currentrun = list()
	var/list/processing = list()

/datum/controller/subsystem/diseases/New()
	NEW_SS_GLOBAL(SSdisease)

/datum/controller/subsystem/diseases/stat_entry(msg)
	..("P:[processing.len]")

/datum/controller/subsystem/diseases/fire(resumed = 0)
	if(!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.process()
		else
			processing.Remove(thing)
		if (MC_TICK_CHECK)
			return
