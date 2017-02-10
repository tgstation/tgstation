var/datum/subsystem/processing/objects/SSobj

#define INITIALIZATION_INSSOBJ 0	//New should not call Initialize
#define INITIALIZATION_INNEW_MAPLOAD 1	//New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_REGULAR 2	//New should call Initialize(FALSE)

/datum/subsystem/processing/objects
	name = "Objects"
	init_order = 12
	priority = 40
	wait = 20

	var/initialized = INITIALIZATION_INSSOBJ
	var/old_initialized

/datum/subsystem/processing/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/processing/objects/Initialize(timeofdayl)
	fire_overlay.appearance_flags = RESET_COLOR
	setupGenetics() //to set the mutations' place in structural enzymes, so monkey.initialize() knows where to put the monkey mutation.
	initialized = INITIALIZATION_INNEW_MAPLOAD
	InitializeAtoms()
	. = ..()

/datum/subsystem/processing/objects/proc/InitializeAtoms(list/objects = null)
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

/datum/subsystem/processing/objects/proc/map_loader_begin()
	old_initialized = initialized
	initialized = INITIALIZATION_INSSOBJ

/datum/subsystem/processing/objects/proc/map_loader_stop()
	initialized = old_initialized

/datum/subsystem/processing/objects/Recover()
	initialized = SSobj.initialized
	if(initialized == INITIALIZATION_INNEW_MAPLOAD)
		InitializeAtoms()
	old_initialized = SSobj.old_initialized
	..(SSobj)

/datum/subsystem/processing/objects/proc/setupGenetics()
	var/list/avnums = new /list(DNA_STRUC_ENZYMES_BLOCKS)
	for(var/i=1, i<=DNA_STRUC_ENZYMES_BLOCKS, i++)
		avnums[i] = i
	CHECK_TICK

	for(var/A in subtypesof(/datum/mutation/human))
		var/datum/mutation/human/B = new A()
		if(B.dna_block == NON_SCANNABLE)
			continue
		B.dna_block = pick_n_take(avnums)
		if(B.quality == POSITIVE)
			good_mutations |= B
		else if(B.quality == NEGATIVE)
			bad_mutations |= B
		else if(B.quality == MINOR_NEGATIVE)
			not_good_mutations |= B
		CHECK_TICK
