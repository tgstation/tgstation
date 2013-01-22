var/list/allEvents = typesof(/datum/event) - /datum/event
var/list/potentialRandomEvents = typesof(/datum/event) - /datum/event

var/eventTimeLower = 15000	//15 minutes
var/eventTimeUpper = 30000	//30 minutes

var/scheduledEvent = null


//Currently unused. Needs an admin panel for messing with events.
/proc/addPotentialEvent(var/type)
	potentialRandomEvents |= type

/proc/removePotentialEvent(var/type)
	potentialRandomEvents -= type


/proc/checkEvent()
	if(!scheduledEvent)
		scheduledEvent = world.timeofday + rand(eventTimeLower, eventTimeUpper)

	else if(world.timeofday > scheduledEvent)
		spawnEvent()

		scheduledEvent = null
		checkEvent()


/proc/spawnEvent()
	if(!config.allow_random_events)
		return

	var/Type = pick(potentialRandomEvents)
	if(!Type)
		return

	//The event will add itself to the MC's event list
	//and start working via the constructor.
	new Type

/client/proc/forceEvent(var/type in allEvents)
	set name = "Trigger Event (Debug Only)"
	set category = "Debug"

	if(!holder)
		return

	if(ispath(type))
		new type
		message_admins("[key_name_admin(usr)] has triggered an event. ([type])", 1)