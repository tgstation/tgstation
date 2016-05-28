#define SSTIMER_NONE 0 // or could be TIMER_DEFAULT
#define SSTIMER_WAIT 1 // Alters the wait of a unique event. Can be called from anywhere to increase or decrease it.
#define SSTIMER_DATA 2 // Alters the data of a unique event. Can be called from anywhere to modify the arg list.
#define SSTIMER_FULL 3 // Completely overwrites a unique event. Can be called from anywhere.

var/datum/subsystem/timer/SStimer

/datum/subsystem/timer
	name = "Timer"
	wait = 5
	priority = 1
	display = 3

	var/list/datum/timedevent/processing
	var/list/hashes
	var/list/unique

/datum/subsystem/timer/New()
	NEW_SS_GLOBAL(SStimer)
	processing = list()
	hashes = list()

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

/datum/subsystem/timer/proc/runevent(datum/timedevent/event)
	set waitfor = 0
	call(event.thingToCall, event.procToCall)(arglist(event.argList))

/datum/timedevent
	var/thingToCall
	var/procToCall
	var/timeToRun
	var/argList
	var/id
	var/hash
	var/static/nextid = 1

/datum/timedevent/New()
	id = nextid
	nextid++

/datum/timedevent/Destroy()
	SStimer.processing -= src
	SStimer.hashes -= hash
	SStimer.unique -= hash
	return QDEL_HINT_IWILLGC

/proc/addtimer(thingToCall, procToCall, wait, unique = 0, behaviour = SSTIMER_NONE, ...)
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
	if(unique)
		var/semihash = args.Copy(1,3)
		semihash += args.Copy(4,5)
		event.hash = jointext(semihash, null)
	else
		event.hash = jointext(args, null)
	if(args.len > 5)
		event.argList = args.Copy(6)
	
	// Check for dupes if unique = 1.
	switch(behaviour)
		if(SSTIMER_NONE) // Never Overwrites unique event.
			if(event.hash in SStimer.unique)
				qdel(src)
				return
			SStimer.unique[event.hash] = event
		if(SSTIMER_WAIT) // Overwrites unique event time.
			var/datum/timedevent/old = SStimer.unique[event.hash]
			if(old)
				event.argList = old.argList.Copy()
				SStimer.processing -= old
				qdel(old)
			SStimer.unique[event.hash] = event
		if(SSTIMER_DATA) // Overwrites unique event data.
			var/datum/timedevent/old = SStimer.unique[event.hash]
			if(old)
				event.timeToRun = old.timeToRun
				SStimer.processing -= old
				qdel(old)
			SStimer.unique[event.hash] = event
		if(SSTIMER_FULL) // Completely overwrites unique event.
			var/datum/timedevent/old = SStimer.unique[event.hash]
			if(old)
				SStimer.processing -= old
				qdel(old)
			SStimer.unique[event.hash] = event

	// If we are unique (or we're not checking that), add the timer and return the id.
	SStimer.processing += event
	SStimer.hashes += event.hash
	return event.id

/proc/deltimer(id)
	for(var/datum/timedevent/event in SStimer.processing)
		if(event.id == id)
			qdel(event)
			return 1
	return 0
