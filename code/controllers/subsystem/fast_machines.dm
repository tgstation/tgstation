/*
	This subsystem is for when you want a machine that processes faster than other machines.
	Machines in this subsystem process every 0.5 seconds instead of every 2 seconds.
*/

var/datum/subsystem/fast_machines/SSfast_machine

/datum/subsystem/fast_machines
	name = "Fast Machines"
	priority = 9
	wait = 5

	var/list/processing = list()

/datum/subsystem/fast_machines/New()
	NEW_SS_GLOBAL(SSfast_machine)


/datum/subsystem/fast_machines/stat_entry()
	..("M:[processing.len]")

/datum/subsystem/fast_machines/fire()
	var/seconds = wait * 0.1
	for(var/thing in processing)
		if(thing && (thing:process(seconds) != PROCESS_KILL))
			if(thing:use_power)
				thing:auto_use_power() //add back the power state
			continue
		processing.Remove(thing)

