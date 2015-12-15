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
		if(E.holidayID || E.wizardevent)
			continue
		if(E.earliest_start >= world.time)
			continue
		var/datum/round_event/event = E.typepath
		if(initial(event.announceWhen) <= 0)
			continue
		events_list += E
	
	var/datum/round_event_control/event_control = pick(events_list)
	if(event_control)
		var/datum/round_event/Event = new event_control.typepath()
		message_admins("False Alarm: [Event]")
		Event.kill() 		//do not process this event - no starts, no ticks, no ends
		Event.announce() 	//just announce it like it's happening

	
