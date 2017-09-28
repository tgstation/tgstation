/datum/round_event_control/falsealarm
	name 			= "False Alarm"
	typepath 		= /datum/round_event/falsealarm
	weight			= 20
	max_occurrences = 5

/datum/round_event_control/falsealarm/canSpawnEvent(players_amt, gamemode)
	return ..() && length(gather_false_events())

/datum/round_event/falsealarm
	announceWhen	= 0
	endWhen			= 1

/datum/round_event/falsealarm/announce()
	var/players_amt = get_active_player_count(alive_check = 1, afk_check = 1, human_check = 1)
	var/gamemode = SSticker.mode.config_tag

	var/events_list = gather_false_events(players_amt, gamemode)
	var/datum/round_event_control/event_control = pick(events_list)
	if(event_control)
		var/datum/round_event/Event = new event_control.typepath()
		message_admins("False Alarm: [Event]")
		Event.kill() 		//do not process this event - no starts, no ticks, no ends
		Event.announce() 	//just announce it like it's happening

/proc/gather_false_events(players_amt, gamemode)
	. = list()
	for(var/datum/round_event_control/E in SSevents.control)
		if(istype(E, /datum/round_event_control/falsealarm))
			continue
		if(!E.canSpawnEvent(players_amt, gamemode))
			continue

		var/datum/round_event/event = E.typepath
		if(initial(event.announceWhen) <= 0)
			continue
		. += E
