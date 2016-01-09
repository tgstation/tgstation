/*
 * WARRANTY VOID IF CODE USED
 */


/datum/events
	var/list/events

/datum/events/New()
	..()
	events = new

/datum/events/proc/addEventType(event_type as text)
	if(!(event_type in events) || !islist(events[event_type]))
		events[event_type] = list()
		return 1
	return


//	Arguments: event_type as text, proc_holder as datum, proc_name as text
//	Returns: New event, null on error.
/datum/events/proc/addEvent(event_type as text, proc_holder, proc_name as text)
	if(!event_type || !proc_holder || !proc_name)
		return
	addEventType(event_type)
	var/list/event = events[event_type]
	var/datum/event/E = new /datum/event(proc_holder,proc_name)
	event += E
	return E

//  Arguments: event_type as text, any number of additional arguments to pass to event handler
//  Returns: null
/datum/events/proc/fireEvent()
	//world << "Events in [args[1]] called"
	var/list/event = listgetindex(events,args[1])
	if(istype(event))
		spawn(0)
			for(var/datum/event/E in event)
				if(!E.Fire(arglist(args.Copy(2))))
					clearEvent(args[1],E)
	return

// Arguments: event_type as text, E as /datum/event
// Returns: 1 if event cleared, null on error

/datum/events/proc/clearEvent(event_type as text, datum/event/E)
	if(!event_type || !E)
		return
	var/list/event = listgetindex(events,event_type)
	event -= E
	return 1


/datum/event
	var/listener
	var/proc_name

/datum/event/New(tlistener,tprocname)
	listener = tlistener
	proc_name = tprocname
	return ..()

/datum/event/proc/Fire()
	//world << "Event fired"
	if(listener)
		call(listener,proc_name)(arglist(args))
		return 1
	return
