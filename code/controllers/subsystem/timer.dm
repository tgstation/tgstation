var/datum/subsystem/timer/SStimer

/datum/subsystem/timer
	name = "Timer"
	wait = 2 //SS_TICKER subsystem, so wait is in ticks
	init_order = 1
	display_order = 3
	can_fire = 0 //start disabled
	flags = SS_FIRE_IN_LOBBY|SS_TICKER|SS_POST_FIRE_TIMING|SS_NO_INIT

	var/list/datum/timedevent/processing
	var/list/hashes


/datum/subsystem/timer/New()
	processing = list()
	hashes = list()
	NEW_SS_GLOBAL(SStimer)


/datum/subsystem/timer/stat_entry(msg)
	..("P:[processing.len]")

/datum/subsystem/timer/fire()
	if(!processing.len)
		can_fire = 0 //nothing to do, lets stop firing.
		return
	for(var/datum/timedevent/event in processing)
		if(!event.thingToCall || qdeleted(event.thingToCall))
			qdel(event)
		if(event.timeToRun <= world.time)
			runevent(event)
			qdel(event)
		if (MC_TICK_CHECK)
			return

/datum/subsystem/timer/proc/runevent(datum/timedevent/event)
	set waitfor = 0
	if(event.thingToCall == GLOBAL_PROC && istext(event.procToCall))
		call("/proc/[event.procToCall]")(arglist(event.argList))
	else
		call(event.thingToCall, event.procToCall)(arglist(event.argList))

/datum/subsystem/timer/Recover()
	processing |= SStimer.processing
	hashes |= SStimer.hashes

/datum/timedevent
	var/thingToCall
	var/procToCall
	var/timeToRun
	var/argList
	var/id
	var/hash
	var/static/nextid = 1

/datum/timedevent/New()
	id = nextid++

/datum/timedevent/Destroy()
	SStimer.processing -= src
	SStimer.hashes -= hash
	return QDEL_HINT_IWILLGC

/proc/addtimer(thingToCall, procToCall, wait, unique = TIMER_NORMAL, ...)
	if (!thingToCall || !procToCall)
		return
	if (!SStimer.can_fire)
		SStimer.can_fire = 1

	var/datum/timedevent/event = new()
	event.thingToCall = thingToCall
	event.procToCall = procToCall
	event.timeToRun = world.time + wait
	var/hashlist = args.Copy()

	hashlist[1] = "[thingToCall](\ref[thingToCall])"
	event.hash = jointext(hashlist, null)

	var/bad_args = unique != TIMER_NORMAL && unique != TIMER_UNIQUE
	if(args.len > 4 || bad_args)
		if(bad_args)
			stack_trace("Invalid arguments in call to addtimer! Attempt to call [thingToCall] proc [procToCall]")
			event.argList = args.Copy(4)
		else
			event.argList = args.Copy(5)

	// Check for dupes if unique = 1.
	if(!bad_args && unique != TIMER_NORMAL)	//faster than checking if(unique == TIMER_UNIQUE)
		var/datum/timedevent/hash_event = SStimer.hashes[event.hash]
		if(hash_event)
			return hash_event.id
	SStimer.hashes[event.hash] = event
	if (wait <= 0)
		SStimer.runevent(event)
		SStimer.hashes -= event.hash
		return
	// If we are unique (or we're not checking that), add the timer and return the id.
	SStimer.processing += event

	return event.id

/proc/deltimer(id)
	for(var/datum/timedevent/event in SStimer.processing)
		if(event.id == id)
			qdel(event)
			return 1
	return 0
