var/datum/subsystem/objects/SSobj

#define INITIALIZATION_INSSOBJ 0	//New should not call Initialize
#define INITIALIZATION_INNEW_MAPLOAD 1	//New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_REGULAR 2	//New should call Initialize(FALSE)

/datum/subsystem/objects
	name = "Objects"
	init_order = 11
	priority = 40

	var/initialized = INITIALIZATION_INSSOBJ
	var/old_initialized
	var/list/processing = list()
	var/list/currentrun = list()

/datum/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/objects/Initialize(timeofdayl)
	fire_overlay.appearance_flags = RESET_COLOR
	setupGenetics() //to set the mutations' place in structural enzymes, so monkey.initialize() knows where to put the monkey mutation.
	initialized = INITIALIZATION_INNEW_MAPLOAD
	InitializeAtoms()
	. = ..()

/datum/subsystem/objects/proc/InitializeAtoms(list/objects = null)
	if(initialized == INITIALIZATION_INSSOBJ)
		return

	var/list/late_loaders

	initialized = INITIALIZATION_INNEW_MAPLOAD

	if(objects)
		for(var/I in objects)
			var/atom/A = I
			if(!A.initialized)	//this check is to make sure we don't call it twice on an object that was created in a previous Initialize call
				var/start_tick = world.time
				if(A.Initialize(TRUE))
					LAZYADD(late_loaders, A)
				if(start_tick != world.time)
					WARNING("[A]: [A.type] slept during it's Initialize!")
				CHECK_TICK
		testing("Initialized [objects.len] atoms")
	else
		#ifdef TESTING
		var/count = 0
		#endif
		for(var/atom/A in world)
			if(!A.initialized)	//this check is to make sure we don't call it twice on an object that was created in a previous Initialize call
				var/start_tick = world.time
				if(A.Initialize(TRUE))
					LAZYADD(late_loaders, A)
				#ifdef TESTING
				else
					++count
				#endif TESTING
				if(start_tick != world.time)
					WARNING("[A]: [A.type] slept during it's Initialize!")
				CHECK_TICK
		testing("Roundstart initialized [count] atoms")

	initialized = INITIALIZATION_INNEW_REGULAR

	if(late_loaders)
		for(var/I in late_loaders)
			var/atom/A = I
			var/start_tick = world.time
			A.Initialize(FALSE)
			if(start_tick != world.time)
				WARNING("[A]: [A.type] slept during it's Initialize!")
			CHECK_TICK
		testing("Late-initialized [late_loaders.len] atoms")

/datum/subsystem/objects/proc/map_loader_begin()
	old_initialized = initialized
	initialized = INITIALIZATION_INSSOBJ

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
	if(initialized == INITIALIZATION_INNEW_MAPLOAD)
		InitializeAtoms()
	old_initialized = SSobj.old_initialized

	if (istype(SSobj.processing))
		processing = SSobj.processing
