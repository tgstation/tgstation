var/datum/subsystem/diseases/SSdisease

/datum/subsystem/diseases
	name = "Diseases"
	priority = 7
	var/list/currentrun = list()
	var/list/processing = list()

/datum/subsystem/diseases/New()
	NEW_SS_GLOBAL(SSdisease)

/datum/subsystem/diseases/stat_entry(msg)
	..("P:[processing.len]")

/datum/subsystem/diseases/fire(resumed = 0)
	if(!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[1]
		currentrun.Cut(1, 2)
		if(thing)
			thing.process()
		else
			processing.Remove(thing)
		if (MC_TICK_CHECK)
			return
