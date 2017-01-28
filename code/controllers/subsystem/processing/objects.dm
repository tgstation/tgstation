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

	var/initialized = FALSE
	var/old_initialized
	var/list/atom_spawners = list()
	var/list/processing = list()
	var/list/currentrun = list()

/datum/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/objects/Initialize(timeofdayl)
	fire_overlay.appearance_flags = RESET_COLOR
	setupGenetics() //to set the mutations' place in structural enzymes, so monkey.initialize() knows where to put the monkey mutation.
	trigger_atom_spawners()
	for(var/thing in world)
		var/atom/A = thing
		A.Initialize(TRUE)
		CHECK_TICK
	initialized = TRUE
	. = ..()

/datum/subsystem/objects/proc/map_loader_begin()
	old_initialized = initialized
	initialized = FALSE

/datum/subsystem/objects/proc/map_loader_stop()
	initialized = old_initialized

/datum/subsystem/objects/proc/trigger_atom_spawners(zlevel, ignore_z=FALSE)
	for(var/V in atom_spawners)
		var/atom/A = V
		if (!ignore_z && (zlevel && A.z != zlevel))
			continue
		A.spawn_atom_to_world()

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


/datum/subsystem/objects/proc/setup_template_objects(list/objects)
	trigger_atom_spawners(0, ignore_z=TRUE)
	if(initialized)
		for(var/A in objects)
			var/atom/B = A
			B.Initialize(TRUE)

/datum/subsystem/objects/Recover()
	initialized = SSobj.initialized
	old_initialized = SSobj.old_initialized
	if (istype(SSobj.atom_spawners))
		atom_spawners = SSobj.atom_spawners
	if (istype(SSobj.processing))
		processing = SSobj.processing
