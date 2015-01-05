var/datum/subsystem/objects/SSobj

/datum/subsystem/objects
	name = "Objects"
	priority = 12

	var/list/processing = list()

/datum/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/objects/Initialize()
	for(var/atom/movable/AM in machines)
		AM.initialize()
	for(var/turf/simulated/floor/F in machines)
		F.MakeDirty()
	..()


/datum/subsystem/objects/stat_entry()
	stat(name, "[round(cost,0.001)]ds\t(CPU:[round(cpu,1)]%)\t[processing.len]")


/datum/subsystem/objects/fire()
	var/i=1
	for(var/thing in SSobj.processing)
		if(thing)
			thing:process(wait)
			++i
			continue
		SSobj.processing.Cut(i, i+1)


/*	This is FPSS13 code, has not yet been ported/implemented
/obj/New()
	..()
	if(map_ready)
		spawn(0)
			if(garbage_collecting)
				return
			initialize()
*/