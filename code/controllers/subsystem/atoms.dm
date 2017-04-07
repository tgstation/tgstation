#define BAD_INIT_QDEL_BEFORE 1
#define BAD_INIT_DIDNT_INIT 2
#define BAD_INIT_SLEPT 4
#define BAD_INIT_NO_HINT 8

SUBSYSTEM_DEF(atoms)
	name = "Atoms"
	init_order = 11
	flags = SS_NO_FIRE

	var/initialized = INITIALIZATION_INSSATOMS
	var/old_initialized

	var/list/late_loaders

	var/list/BadInitializeCalls = list()

/datum/controller/subsystem/atoms/Initialize(timeofday)
	fire_overlay.appearance_flags = RESET_COLOR
	setupGenetics() //to set the mutations' place in structural enzymes, so monkey.initialize() knows where to put the monkey mutation.
	initialized = INITIALIZATION_INNEW_MAPLOAD
	InitializeAtoms()
	return ..()

/datum/controller/subsystem/atoms/proc/InitializeAtoms(list/atoms, LateRecurse = FALSE)
	if(initialized == INITIALIZATION_INSSATOMS)
		return

	if(!LateRecurse)
		initialized = INITIALIZATION_INNEW_MAPLOAD
		LAZYINITLIST(late_loaders)
	
	var/thing_to_check = atoms ? atoms : world

	for(var/I in thing_to_check)
		var/atom/A = I
		if(!A.initialized)	//this check is to make sure we don't call it twice on an object that was created in a previous Initialize call
			if(QDELING(A))
				BadInitializeCalls[A.type] |= BAD_INIT_QDEL_BEFORE
				continue
			var/start_tick = world.time
			var/result = A.Initialize(TRUE)
			if(start_tick != world.time)
				BadInitializeCalls[A.type] |= BAD_INIT_SLEPT

			if(!A.initialized)
				BadInitializeCalls[A.type] |= BAD_INIT_DIDNT_INIT
			
			if(result != INITIALIZE_HINT_NORMAL)
				switch(result)
					if(INITIALIZE_HINT_LATELOAD)
						if(!LateRecurse)
							late_loaders += A
						break
					if(INITIALIZE_HINT_QDEL)
						qdel(A)
						break
					else
						BadInitializeCalls[A.type] |= BAD_INIT_NO_HINT

			CHECK_TICK
	testing("Initialized [atoms ? atoms.len : world.contents.len] atoms")

	if(!LateRecurse)
		initialized = INITIALIZATION_INNEW_REGULAR
		.(late_loaders, TRUE)
		late_loaders.Cut()

/datum/controller/subsystem/atoms/proc/map_loader_begin()
	old_initialized = initialized
	initialized = INITIALIZATION_INSSATOMS

/datum/controller/subsystem/atoms/proc/map_loader_stop()
	initialized = old_initialized

/datum/controller/subsystem/atoms/Recover()
	initialized = SSatoms.initialized
	if(initialized == INITIALIZATION_INNEW_MAPLOAD)
		InitializeAtoms()
	old_initialized = SSatoms.old_initialized
	BadInitializeCalls = SSatoms.BadInitializeCalls

/datum/controller/subsystem/atoms/proc/setupGenetics()
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

/datum/controller/subsystem/atoms/proc/InitLog()
	. = ""
	for(var/path in BadInitializeCalls)
		. += "Path : [path] \n"
		var/fails = BadInitializeCalls[path]
		if(fails & BAD_INIT_DIDNT_INIT)
			. += "- Didn't call atom/Initialize()\n"
		if(fails & BAD_INIT_NO_HINT)
			. += "- Didn't return an Initialize hint\n"
		if(fails & BAD_INIT_QDEL_BEFORE)
			. += "- Qdel'd in New()\n"
		if(fails & BAD_INIT_SLEPT)
			. += "- Slept during Initialize()\n"

/datum/controller/subsystem/atoms/Shutdown()
	var/initlog = InitLog()
	if(initlog)
		log_world(initlog)

#undef BAD_INIT_QDEL_BEFORE
#undef BAD_INIT_DIDNT_INIT
#undef BAD_INIT_SLEPT
#undef BAD_INIT_NO_HINT