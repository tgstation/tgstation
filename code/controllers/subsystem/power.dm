var/datum/subsystem/power/SSpower

/datum/subsystem/power
	name = "Power"
	priority = 10

	var/list/powernets = list()

/datum/subsystem/power/New()
	NEW_SS_GLOBAL(SSpower)

/datum/subsystem/power/stat_entry(msg)
	..("P:[powernets.len]")

/datum/subsystem/power/Initialize(timeofday, zlevel)
	makepowernets(zlevel)
	..()

// rebuild all power networks from scratch - only called at world creation or by the admin verb
/datum/subsystem/power/proc/makepowernets(zlevel)
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()

	for(var/obj/structure/cable/PC in cable_list)
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/subsystem/power/fire()
	for(var/datum/powernet/Powernet in powernets)
		Powernet.reset()