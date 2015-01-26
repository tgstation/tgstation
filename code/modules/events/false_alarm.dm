/datum/round_event_control/falsealarm
	name 			= "False Alarm"
	typepath 		= /datum/round_event/falsealarm
	weight			= 20
	max_occurrences = 5

/datum/round_event/falsealarm
	announceWhen	= 0
	endWhen			= 1

/datum/round_event/falsealarm/announce()
	var/list/events_list = list()
	for(var/datum/round_event_control/E in SSevent.control)
		if(!E.wizardevent && !E.holidayID) //No holiday cheer allowed during non-holidays. Not even fake holiday cheer.
			events_list += E //No holiday cheer allowed during non-holidays. Not even fake holiday cheer.
	var/datum/round_event_control/event_control = pick(events_list)
	if(event_control)
		var/datum/round_event/Event = new event_control.typepath()
		message_admins("False Alarm: [Event]")
		Event.kill() 		//do not process this event - no starts, no ticks, no ends
		Event.announce() 	//just announce it like it's happening