var/datum/subsystem/diseases/SSdisease

/datum/subsystem/diseases
	name = "Diseases"
	priority = 7

	var/list/processing = list()

/datum/subsystem/diseases/New()
	NEW_SS_GLOBAL(SSdisease)

/datum/subsystem/diseases/stat_entry(msg)
	..("P:[processing.len]")

/datum/subsystem/diseases/fire()
	for(var/thing in processing)
		if(thing)
			thing:process()
			continue
		processing.Remove(thing)
