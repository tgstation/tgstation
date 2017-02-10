var/datum/subsystem/processing/machines/SSmachine

/datum/subsystem/processing/machines
	name = "Machines"
	init_order = 9
	display_order = 3
	flags = SS_KEEP_TIMING
	stat_tag = "Mach"

	var/list/powernets = list()

/datum/subsystem/processing/machines/New()
	NEW_SS_GLOBAL(SSmachine)

/datum/subsystem/processing/machines/Initialize()
	makepowernets()
	fire()
	..()

/datum/subsystem/processing/machines/proc/makepowernets()
	for(var/datum/powernet/PN in powernets)
		qdel(PN)
	powernets.Cut()

	for(var/obj/structure/cable/PC in cable_list)
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/subsystem/processing/machines/stat_entry()
	..("|PN:[powernets.len]")

/datum/subsystem/processing/machines/fire(resumed = 0)
	if (!resumed)
		for(var/datum/powernet/Powernet in powernets)
			Powernet.reset() //reset the power state.
	..()

/datum/subsystem/processing/machines/proc/setup_template_powernets(list/cables)
	for(var/A in cables)
		var/obj/structure/cable/PC = A
		if(!PC.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(PC)
			propagate_network(PC,PC.powernet)

/datum/subsystem/processing/machines/Recover()
	powernets = SSmachine.powernets
	..(SSmachine)