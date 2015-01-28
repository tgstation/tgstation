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
	for(var/obj/machinery/m in processing)
		if(m && (m.process(seconds) != PROCESS_KILL))
			if(m.use_power)
				m.auto_use_power()
			continue
		processing.Remove(m)

