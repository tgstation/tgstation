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
	stat(name, "[round(cost,0.001)]ds (CPU:[round(cpu,1)]%)\t[processing.len]")


/datum/subsystem/machines/fire()
	var/seconds = wait * 0.1
	var/i = 1
	for(var/thing in processing)
		if(thing && (thing:process(seconds) != PROCESS_KILL))
			if(thing:use_power)
				thing:auto_use_power()
			++i
			continue
		processing.Cut(i,i+1)

