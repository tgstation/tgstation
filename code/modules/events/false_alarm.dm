/datum/round_event_control/falsealarm
	name 			= "False Alarm"
	typepath 		= /datum/round_event/falsealarm
	weight			= 9
	max_occurrences = 5

/datum/round_event/falsealarm
	announceWhen	= 0
	endWhen			= 1

/datum/round_event/falsealarm/announce()
	var/datum/round_event_control/E = pick(events.control)
	if(E.holidayID)
		return //No holiday cheer allowed during non-holidays. Not even fake holiday cheer.
	var/datum/round_event/Event = new E.typepath()
	message_admins("False Alarm: [Event]")
	Event.kill() 		//do not process this event - no starts, no ticks, no ends
	Event.announce() 	//just announce it like it's happening