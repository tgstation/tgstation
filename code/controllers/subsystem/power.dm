var/datum/subsystem/power/SSpower

/datum/subsystem/power
	name = "Power"
	priority = 10

	var/list/powernets = list()

/datum/subsystem/power/New()
	NEW_SS_GLOBAL(SSpower)

/datum/subsystem/power/Initialize()
	makepowernets()
	..()

/datum/subsystem/power/fire()
	for(var/datum/powernet/Powernet in powernets)
		Powernet.reset()