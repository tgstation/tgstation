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

	var/list/atom_spawners = list()
	var/list/processing = list()
	var/list/currentrun = list()
	var/list/burning = list()

/datum/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/objects/Initialize(timeofdayl)
	trigger_atom_spawners()
	setupGenetics()
	for(var/thing in world)
		var/atom/A = thing
		A.initialize()
		CHECK_TICK
	. = ..()

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

	for(var/obj/burningobj in SSobj.burning)
		if(burningobj && (burningobj.burn_state == ON_FIRE))
			if(burningobj.burn_world_time < world.time)
				burningobj.burn()
		else
			SSobj.burning.Remove(burningobj)

/datum/subsystem/objects/proc/setup_template_objects(list/objects)
	trigger_atom_spawners(0, ignore_z=TRUE)
	for(var/A in objects)
		var/atom/B = A
		B.initialize()

/datum/subsystem/objects/Recover()
	if (istype(SSobj.atom_spawners))
		atom_spawners = SSobj.atom_spawners
	if (istype(SSobj.processing))
		processing = SSobj.processing
	if (istype(SSobj.burning))
		burning = SSobj.burning