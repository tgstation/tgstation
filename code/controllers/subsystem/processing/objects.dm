var/datum/subsystem/objects/SSobj

#define INITIALIZATION_INSSOBJ 0	//New should not call Initialize
#define INITIALIZATION_INNEW_MAPLOAD 1	//New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_REGULAR 2	//New should call Initialize(FALSE)

/datum/subsystem/objects
	name = "Objects"
	priority = 40
	flags = SS_NO_INIT

	var/initialized = INITIALIZATION_INSSOBJ
	var/old_initialized
	var/list/processing = list()
	var/list/currentrun = list()

/datum/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)
/datum/subsystem/objects/stat_entry()
	..("P:[processing.len]")

/datum/subsystem/objects/fire(resumed = 0)
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
			SSobj.processing -= thing
		if (MC_TICK_CHECK)
			return

/datum/subsystem/objects/Recover()
	processing = SSobj.processing
