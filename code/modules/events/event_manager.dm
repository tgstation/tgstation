var/list/allEvents = typesof(/datum/event) - /datum/event
var/list/potentialRandomEvents = typesof(/datum/event) - /datum/event
//var/list/potentialRandomEvents = typesof(/datum/event) - /datum/event - /datum/event/spider_infestation - /datum/event/alien_infestation

var/eventTimeLower = 6000	//10 minutes
var/eventTimeUpper = 12000	//20 minutes
var/scheduledEvent = null

/proc/checkEvent()
	if(!scheduledEvent)
		//The more players, the merrier
		var/playercount_modifier = 1
		switch(player_list.len)
			if(0 to 10)
				playercount_modifier = 1.25 //At this point even carps could KO the crew
			if(11 to 20)
				playercount_modifier = 1.15
			if(21 to 30)
				playercount_modifier = 1.05
			if(31 to 40)
				playercount_modifier = 1 //"Medium value"
			if(41 to 50)
				playercount_modifier = 0.95
			if(51 to 60)
				playercount_modifier = 0.90
			if(61 to 70)
				playercount_modifier = 0.85
			if(71 to 80)
				playercount_modifier = 0.80
			if(81 to INFINITY)
				playercount_modifier = 0.75 //At this point it's icing on the cake
		//Then, let's slowly ramp up events as the round goes on, SLOWLY I SAID
		//world.time is the number of ticks (1/10 of a second) since game start for reference
		var/roundlength_modifier = 1
		switch(world.time)
			if(0 to 18000) //30 first minutes
				roundlength_modifier = 1 //Don't particularly speed up event rate
			if(18000 to 36000) //Next thirty minutes
				roundlength_modifier = 0.95 //Start ramping up
			if(36000 to 54000)
				roundlength_modifier = 0.90
			if(54000 to INFINITY) //Round has been going for 1 hour and 30 minutes at least
				roundlength_modifier = 0.85

		var/next_event_delay = rand(eventTimeLower, eventTimeUpper)*playercount_modifier*roundlength_modifier
		scheduledEvent = world.timeofday + next_event_delay
		log_debug("Next event in [next_event_delay/600] minutes.")

	else if(world.timeofday > scheduledEvent)
		spawn_dynamic_event()

		scheduledEvent = null
		checkEvent()

/client/proc/forceEvent(var/type in allEvents)
	set name = "Trigger Event (Debug Only)"
	set category = "Debug"

	if(!holder)
		return

	if(ispath(type))
		new type
		message_admins("[key_name_admin(usr)] has triggered an event. ([type])", 1)