var/datum/subsystem/machines/SSmachine

/datum/subsystem/machines
	name = "Machines"
	priority = 9

	var/list/processing = list()
	var/list/powernets = list()


/datum/subsystem/machines/Initialize()
	makepowernets()
	fire()
	..()

/datum/subsystem/machines/proc/makepowernets(zlevel)
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()

	for(var/obj/structure/cable/PC in cable_list)
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/subsystem/machines/New()
	NEW_SS_GLOBAL(SSmachine)


/datum/subsystem/machines/stat_entry()
	..("M:[processing.len]|PN:[powernets.len]")


/datum/subsystem/machines/fire()
	for(var/datum/powernet/Powernet in powernets)
		Powernet.reset() //reset the power state.

	var/seconds = wait * 0.1
	for(var/thing in processing)
		if(thing && (thing:process(seconds) != PROCESS_KILL))
			if(thing:use_power)
				thing:auto_use_power() //add back the power state
			continue
		processing.Remove(thing)

