var/list/allEvents = typesof(/datum/event) - /datum/event
var/list/potentialRandomEvents = typesof(/datum/event) - /datum/event
//var/list/potentialRandomEvents = typesof(/datum/event) - /datum/event - /datum/event/spider_infestation - /datum/event/alien_infestation

var/eventTimeLower = 15000	//15 minutes
var/eventTimeUpper = 30000	//45 minutes

var/scheduledEvent = null


//Currently unused. Needs an admin panel for messing with events.
/*/proc/addPotentialEvent(var/type)
	potentialRandomEvents |= type

/proc/removePotentialEvent(var/type)
	potentialRandomEvents -= type*/


/proc/checkEvent()
	if(!scheduledEvent)
		//more players = more time between events, less players = less time between events
		var/playercount_modifier = 0.5
		switch(player_list.len)
			if(0 to 10)
				playercount_modifier = 1.2
			if(11 to 15)
				playercount_modifier = 1.1
			if(16 to 20)
				playercount_modifier = 1
			if(21 to 25)
				playercount_modifier = 0.9
			if(26 to 100000)
				playercount_modifier = 0.8
		scheduledEvent = world.timeofday + rand(eventTimeLower, eventTimeUpper) * playercount_modifier

	else if(world.timeofday > scheduledEvent)
		spawn_dynamic_event()

		scheduledEvent = null
		checkEvent()

//unused, see proc/dynamic_event()
/*
/proc/spawnEvent()
	if(!config.allow_random_events)
		return

	var/Type = pick(potentialRandomEvents)
	if(!Type)
		return

	//The event will add itself to the MC's event list
	//and start working via the constructor.
	new Type
*/

/client/proc/forceEvent(var/type in allEvents)
	set name = "Trigger Event (Debug Only)"
	set category = "Debug"

	if(!holder)
		return

	if(ispath(type))
		new type
		message_admins("[key_name_admin(usr)] has triggered an event. ([type])", 1)