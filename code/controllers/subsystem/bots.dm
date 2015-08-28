var/datum/subsystem/bots/SSbot

/datum/subsystem/bots
	name = "Bots"
	priority = 8

	var/list/processing = list()

/datum/subsystem/bots/New()
	NEW_SS_GLOBAL(SSbot)

/datum/subsystem/bots/stat_entry(msg)
	..("P:[processing.len]")

/datum/subsystem/bots/fire()
	var/seconds = wait * 0.1
	for(var/thing in processing)
		if(thing && !thing:gc_destroyed)
			spawn(-1)
				thing:bot_process(seconds)
			continue
		processing.Remove(thing)