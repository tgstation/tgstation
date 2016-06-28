var/datum/subsystem/fastprocess/SSfastprocess

/datum/subsystem/fastprocess
	name = "Fast Process"
	priority = 25
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING|SS_NO_INIT
	wait = 2

	var/list/processing = list()
	var/list/currentrun = list()

/datum/subsystem/fastprocess/New()
	NEW_SS_GLOBAL(SSfastprocess)

/datum/subsystem/fastprocess/stat_entry()
	..("FP:[processing.len]")


/datum/subsystem/fastprocess/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.process(wait)
		else
			SSfastprocess.processing -= thing
		if (MC_TICK_CHECK)
			return
