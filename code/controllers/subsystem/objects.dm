var/datum/subsystem/objects/SSobj

/datum/proc/process()
	SSobj.processing.Remove(src)
	return 0

/datum/subsystem/objects
	name = "Objects"
	priority = 12

	var/list/processing = list()

/datum/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/objects/Initialize(timeofday, zlevel)
	for(var/atom/movable/AM in world)
		if (zlevel && AM.z != zlevel)
			continue
		AM.initialize()
	if (zlevel)
		return ..()
	for(var/turf/simulated/floor/F in world)
		F.MakeDirty()
	..()


/datum/subsystem/objects/stat_entry()
	..("P:[processing.len]")


/datum/subsystem/objects/fire()
	var/i=1
	for(var/thing in SSobj.processing)
		if(thing)
			thing:process(wait)
			++i
			continue
		SSobj.processing.Cut(i, i+1)


