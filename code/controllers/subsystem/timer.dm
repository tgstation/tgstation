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
		if(event.timeToRun <= world.time)
			event.callback.InvokeAsync()
			qdel(event)
		if (MC_TICK_CHECK)
			return

/datum/subsystem/timer/Recover()
	processing |= SStimer.processing
	hashes |= SStimer.hashes

/datum/timedevent
	var/datum/callback/callback
	var/timeToRun
	var/id
	var/hash
	var/static/nextid = 1

/datum/timedevent/New()
	id = nextid++

/datum/timedevent/Destroy()
	SStimer.processing -= src
	SStimer.hashes -= hash
	return QDEL_HINT_IWILLGC

/proc/addtimer(datum/callback/callback, wait, unique = TIMER_NORMAL)
	if (!callback)
		return
	if (!SStimer.can_fire)
		SStimer.can_fire = 1

	var/datum/timedevent/event = new()
	event.callback = callback
	event.timeToRun = world.time + wait
	var/list/hashlist = args.Copy()

	hashlist[1] = "[callback.object](\ref[callback.object])"
	hashlist.Insert(2, callback.delegate, callback.arguments)
	event.hash = jointext(hashlist, null)

	if(unique == TIMER_UNIQUE)
		var/datum/timedevent/hash_event = SStimer.hashes[event.hash]
		if(hash_event)
			return hash_event.id

	SStimer.hashes[event.hash] = event
	if (wait <= 0)
		callback.InvokeAsync()
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
