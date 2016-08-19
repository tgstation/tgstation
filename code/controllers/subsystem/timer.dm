var/datum/subsystem/timer/SStimer

/datum/subsystem/timer
	name = "Timer"
	wait = 5
	priority = 1

	var/list/datum/timedevent/processing


/datum/subsystem/timer/New()
	NEW_SS_GLOBAL(SStimer)
	processing = list()


/datum/subsystem/timer/stat_entry(msg)
	..("P:[processing.len]")

/datum/subsystem/timer/fire()
	if (!processing.len)
		can_fire = 0 //nothing to do, lets stop firing.
		return
	for (var/datum/timedevent/event in processing)
		//                    hacky i know, but its the only way to ensure this works with clients
		if (!event.thingToCall || qdeleted(event.thingToCall))
			qdel(event)
		if (event.timeToRun <= world.time)
			spawn(-1)
				call(event.thingToCall,event.procToCall)(arglist(event.argList))
			qdel(event)

/datum/timedevent
	var/thingToCall
	var/procToCall
	var/timeToRun
	var/argList
	var/id
	var/static/nextid = 1

/datum/timedevent/New()
	id = nextid
	nextid++

/datum/timedevent/Destroy()
	SStimer.processing -= src
	return ..()

/proc/addtimer(thingToCall, procToCall, wait, argList = list())
	if (!SStimer) //can't run timers before the mc has been created
		return
	if (!thingToCall || !procToCall || wait <= 0)
		return
	if (!SStimer.can_fire)
		SStimer.can_fire = 1
		SStimer.next_fire = world.time + SStimer.wait

	var/datum/timedevent/event = new()
	event.thingToCall = thingToCall
	event.procToCall = procToCall
	event.timeToRun = world.time + wait
	event.argList = argList

	SStimer.processing += event

	return event.id

/proc/deltimer(id)
	for (var/datum/timedevent/event in SStimer.processing)
		if (event.id == id)
			qdel(event)
			return 1
	return 0