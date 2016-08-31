var/datum/subsystem/chemistry/SSchem

/datum/subsystem/chemistry
	name = "Chemistry"
	flags = SS_KEEP_TIMING|SS_NO_INIT
	wait = 10

	var/list/currentrun = list()
	var/list/processing = list()

/datum/subsystem/chemistry/New()
	NEW_SS_GLOBAL(SSchem)

/datum/subsystem/chemistry/stat_entry(msg)
	..("CH:[processing.len]")

/datum/subsystem/chemistry/fire(resumed = 0)
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
