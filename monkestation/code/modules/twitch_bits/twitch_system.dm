/datum/config_entry/string/twitch_key
	default = "changethisplease"

SUBSYSTEM_DEF(twitch)
	name = "Twitch Events"
	wait = 0.5 SECONDS
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	priority = FIRE_PRIORITY_TWITCH
	init_order = INIT_ORDER_TWITCH


	///list of all running events with their running times
	var/list/running_events = list()
	///list of deferred handlers
	var/list/deferred_handlers = list()
	///assoc list of instances of all twitch events keyed by their type
	var/list/twitch_events_by_type = list()

	var/datum/twitch_event/last_event
	var/last_event_execution = 0
	var/last_executor

/datum/controller/subsystem/twitch/Initialize()
	for(var/event as anything in subtypesof(/datum/twitch_event))
		twitch_events_by_type[event] = new event
	return SS_INIT_SUCCESS

/datum/controller/subsystem/twitch/stat_entry(msg)
	msg += "Running Events:[running_events.len]"
	return ..()

/datum/controller/subsystem/twitch/fire(resumed)
	if(deferred_handlers && SSticker.current_state == GAME_STATE_PLAYING)
		run_deferred()
	if(!running_events.len)
		return
	for(var/listed_event in running_events)
		if(running_events[listed_event] > world.time)
			continue
		var/datum/twitch_event/valued_event = listed_event
		valued_event.end_event()
		running_events -= running_events

/datum/controller/subsystem/twitch/proc/handle_topic(list/incoming)
	if(incoming[2] != CONFIG_GET(string/twitch_key))
		return


	var/datum/twitch_event/chosen_one
	for(var/datum/twitch_event/listed_events as anything in subtypesof(/datum/twitch_event))
		if(incoming[3] != initial(listed_events.id_tag))
			continue
		chosen_one = twitch_events_by_type[listed_events]
	if(!chosen_one)
		return

	if(last_event != chosen_one)
		last_event = chosen_one
		last_event_execution = world.time
		last_executor = incoming[4]
	else
		if((world.time < last_event_execution + 2 SECONDS) && last_executor == incoming[4])
			return

	switch(SSticker.current_state)
		if(GAME_STATE_STARTUP, GAME_STATE_PREGAME, GAME_STATE_SETTING_UP)
			deferred_handlers += incoming[3]
			return
		else
			for(var/datum/twitch_event/listed_event as anything in running_events)
				if(listed_event.type == chosen_one.type)
					running_events[listed_event] = running_events[listed_event] + chosen_one.event_duration
					minor_announce("[listed_event.event_name] has just been extended by [incoming[4]].", "The Observers")
					return

			chosen_one.run_event(incoming[4])
			running_events[chosen_one] = world.time + chosen_one.event_duration

/datum/controller/subsystem/twitch/proc/run_deferred()
	for(var/listed_item in deferred_handlers)
		var/datum/twitch_event/chosen_one
		for(var/datum/twitch_event/listed_events as anything in subtypesof(/datum/twitch_event))
			if(listed_item != initial(listed_events.id_tag))
				continue
			chosen_one = twitch_events_by_type[listed_events]
		if(!chosen_one)
			return
		chosen_one.run_event()
		running_events[chosen_one] = world.time + chosen_one.event_duration
		deferred_handlers -= listed_item

/datum/controller/subsystem/twitch/proc/add_to_queue(choice_id)
	deferred_handlers += choice_id


