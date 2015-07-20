/datum/event	//NOTE: Times are measured in master controller ticks!
	var/startWhen		= 0	//When in the lifetime to call start().
	var/announceWhen	= 0	//When in the lifetime to call announce().
	var/endWhen			= 0	//When in the lifetime the event should end.
	var/oneShot			= 0	//If true, then the event removes itself from the list of potential events on creation.

	var/activeFor		= 0	//How long the event has existed. You don't need to change this.

//Called first before processing.
//Allows you to setup your event, such as randomly
//setting the startWhen and or announceWhen variables.
//Only called once.
/datum/event/proc/setup()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/event/proc/setup() called tick#: [world.time]")
	return

//Called when the tick is equal to the startWhen variable.
//Allows you to start before announcing or vice versa.
//Only called once.
/datum/event/proc/start()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/event/proc/start() called tick#: [world.time]")
	return

//Called when the tick is equal to the announceWhen variable.
//Allows you to announce before starting or vice versa.
//Only called once.
/datum/event/proc/announce()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/event/proc/announce() called tick#: [world.time]")
	return

//Called on or after the tick counter is equal to startWhen.
//You can include code related to your event or add your own
//time stamped events.
//Called more than once.
/datum/event/proc/tick()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/event/proc/tick() called tick#: [world.time]")
	return

//Called on or after the tick is equal or more than endWhen
//You can include code related to the event ending.
//Do not place spawn() in here, instead use tick() to check for
//the activeFor variable.
//For example: if(activeFor == myOwnVariable + 30) doStuff()
//Only called once.
/datum/event/proc/end()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/event/proc/end() called tick#: [world.time]")
	return



//Do not override this proc, instead use the appropiate procs.
//This proc will handle the calls to the appropiate procs.
/datum/event/proc/process()

	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/event/proc/process() called tick#: [world.time]")

	if(activeFor > startWhen && activeFor < endWhen)
		tick()

	if(activeFor == startWhen)
		start()

	if(activeFor == announceWhen)
		announce()

	if(activeFor == endWhen)
		end()

	// Everything is done, let's clean up.
	if(activeFor >= endWhen && activeFor >= announceWhen && activeFor >= startWhen)
		kill()

	activeFor++


//Garbage collects the event by removing it from the global events list,
//which should be the only place it's referenced.
//Called when start(), announce() and end() has all been called.
/datum/event/proc/kill()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/event/proc/kill() called tick#: [world.time]")
	events.Remove(src)


//Adds the event to the global events list, and removes it from the list
//of potential events.
/datum/event/New()
	setup()
	events.Add(src)
	/*if(oneShot)
		potentialRandomEvents.Remove(type)*/
	..()
