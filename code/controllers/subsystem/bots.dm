var/datum/subsystem/bots/SSbot

/datum/subsystem/bots
	name = "Bots"
	priority = 8

	var/list/processing = list()

/datum/subsystem/bots/New()
	NEW_SS_GLOBAL(SSbot)

/datum/subsystem/bots/fire()
	var/seconds = wait * 0.1
	var/i=1
	for(var/obj/machinery/bot/b in processing)
		if(b && !b.gc_destroyed)
			spawn(-1)
				b.bot_process(seconds)
			++i
			continue
		processing.Cut(i, i+1)