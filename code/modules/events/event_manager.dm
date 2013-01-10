var/list/allEvents = typesof(/datum/event) - /datum/event
var/list/potentialRandomEvents = typesof(/datum/event) - /datum/event

var/eventTimeLower = 5000
var/eventTimeUpper = 10000

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