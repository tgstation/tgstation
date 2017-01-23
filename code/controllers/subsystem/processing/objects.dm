var/datum/subsystem/objects/SSobj

/datum/var/isprocessing = 0
/datum/proc/process()
	set waitfor = 0
	STOP_PROCESSING(SSobj, src)
	return 0

/datum/subsystem/objects
	name = "Objects"
	init_order = 12
	priority = 40

	var/initialized = 0	//0: nothing should call Initialize. 1: New should call Initialize(TRUE). 2, New should call Initialize(FALSE)
	var/old_initialized
	var/list/processing = list()
	var/list/currentrun = list()

/datum/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/objects/Initialize(timeofdayl)
	fire_overlay.appearance_flags = RESET_COLOR
	setupGenetics() //to set the mutations' place in structural enzymes, so monkey.initialize() knows where to put the monkey mutation.
	InitializeAtoms()
	. = ..()

/datum/subsystem/objects/proc/InitializeAtoms(list/objects = null)
	initialized = 1

	if(objects)
		for(var/thing in objects)
			var/atom/A = thing
			A.Initialize(TRUE)
			CHECK_TICK
	else
		for(var/thing in world)
			var/atom/A = thing
			if(!A.initialized)	//this check is to make sure we don't call it twice on an object that was created in a previous Initialize call
				A.Initialize(TRUE)
				CHECK_TICK

	initialized = 2

/datum/subsystem/objects/proc/map_loader_begin()
	old_initialized = initialized
	initialized = 0

/datum/subsystem/objects/proc/map_loader_stop()
	initialized = old_initialized

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
	initialized = SSobj.initialized
	if(initialized == 1) //0.o?
		InitializeAtoms()
	old_initialized = SSobj.old_initialized

	if (istype(SSobj.processing))
		processing = SSobj.processing
