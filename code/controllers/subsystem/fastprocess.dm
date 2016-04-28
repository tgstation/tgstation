var/datum/subsystem/fastprocess/SSfastprocess

/datum/subsystem/fastprocess
	name = "Fast Process"
	priority = 12
	wait = 1
	dynamic_wait = 1
	dwait_upper = 10
	dwait_buffer = 0
	dwait_lower = 1
	dwait_delta = 6

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
		var/datum/thing = currentrun[1]
		currentrun.Cut(1, 2)
		if(thing)
			thing.process(wait)
		else
			SSfastprocess.processing -= thing
		if (MC_TICK_CHECK)
			return
