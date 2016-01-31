var/datum/subsystem/objects/SSobj

/datum/proc/process()
	set waitfor = 0
	SSobj.processing.Remove(src)
	return 0

/datum/subsystem/objects
	name = "Objects"
	priority = 12

	var/list/processing = list()
	var/list/burning = list()

/datum/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/objects/Initialize(timeofday, zlevel)
	setupGenetics()
	for(var/V in world)
		var/atom/A = V
		if (zlevel && A.z != zlevel)
			continue
		A.initialize()
	. = ..()


/datum/subsystem/objects/stat_entry()
	..("P:[processing.len]")


/datum/subsystem/objects/fire()
	for(var/thing in SSobj.processing)
		if(thing)
			thing:process(wait)
			continue
		SSobj.processing.Remove(thing)
	for(var/obj/burningobj in SSobj.burning)
		if(burningobj && (burningobj.burn_state == ON_FIRE))
			if(burningobj.burn_world_time < world.time)
				burningobj.burn()
		else
			SSobj.burning.Remove(burningobj)

/datum/subsystem/objects/proc/setup_template_objects(list/objects)
	for(var/A in objects)
		var/atom/B = A
		B.initialize()