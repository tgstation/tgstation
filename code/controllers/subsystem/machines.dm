var/datum/subsystem/machines/SSmachine

/datum/subsystem/machines
	name = "Machines"
	priority = 9

	var/list/processing = list()


/datum/subsystem/machines/Initialize()
	fire()
	..()


/datum/subsystem/machines/New()
	NEW_SS_GLOBAL(SSmachine)


/datum/subsystem/machines/stat_entry()
	..("P:[processing.len]")


/datum/subsystem/machines/fire()
	var/seconds = wait * 0.1
	for(var/thing in processing)
		if(thing && (thing:process(seconds) != PROCESS_KILL))
			if(thing:use_power)
				thing:auto_use_power()
			continue
		processing.Remove(thing)

