/*

	New events system, by Sukasa
	 * Much easier to add to
	 * Very, very simple code, easy to maintain

*/

var/list/DisallowedEvents = list(/datum/event/spaceninja, /datum/event/prisonbreak, /datum/event/immovablerod, /datum/event/gravitationalanomaly, /datum/event/alieninfestation)
var/list/EventTypes = typesof(/datum/event) - /datum/event - DisallowedEvents
var/list/OneTimeEvents = list(/datum/event/spacecarp)
var/datum/event/ActiveEvent = null
var/datum/event/LongTermEvent = null
var/is_ninjad_yet = 0

/proc/SpawnEvent()
	if(!EventsOn || ActiveEvent || !config.allow_random_events)
		return
	if((world.time/10)>=3600 && toggle_space_ninja && !sent_ninja_to_station && !is_ninjad_yet)
		EventTypes |= /datum/event/spaceninja
		is_ninjad_yet = 1
	var/Type = pick(EventTypes)
	if(Type in OneTimeEvents)
		EventTypes -= Type
	ActiveEvent = new Type()
	ActiveEvent.Announce()
	if (!ActiveEvent)
		return
	spawn(0)
		while (ActiveEvent.ActiveFor < ActiveEvent.Lifetime)
			ActiveEvent.Tick()
			ActiveEvent.ActiveFor++
			sleep(10)
		ActiveEvent.Die()
		del ActiveEvent

client/proc/Force_Event_admin(Type as null|anything in typesof(/datum/event))
	set category = "Debug"
	set name = "Force Event"
	if(!EventsOn)
		src << "Events are not enabled."
		return
	if(ActiveEvent)
		src << "There is an active event."
		return
	if(istype(Type,/datum/event/viralinfection))
		var/answer = alert("Do you want this to be a random disease or do you have something in mind?",,"Virus2","Choose")
		if(answer == "Choose")
			var/list/viruses = list("fake gbs","gbs","magnitis","wizarditis",/*"beesease",*/"brain rot","cold","retrovirus","flu","pierrot's throat","rhumba beat")
			var/V = input("Choose the virus to spread", "BIOHAZARD") in viruses
			Force_Event(/datum/event/viralinfection, V)
		else
			Force_Event(/datum/event/viralinfection, "virus2")
	else
		Force_Event(Type)
	message_admins("[key_name_admin(usr)] has triggered an (non-viral) event.", 1)

/proc/Force_Event(var/Type in typesof(/datum/event), var/args = null)
	if(!EventsOn)
		src << "Events are not enabled."
		return
	if(ActiveEvent)
		src << "There is an active event."
		return
	src << "Started Event: [Type]"
	ActiveEvent = new Type()
	if(istype(ActiveEvent,/datum/event/viralinfection) && args && args != "virus2")
		var/datum/event/viralinfection/V = ActiveEvent
		V.virus = args
		ActiveEvent = V
	ActiveEvent.Announce()
	if (!ActiveEvent)
		return
	spawn(0)
		while (ActiveEvent.ActiveFor < ActiveEvent.Lifetime)
			ActiveEvent.Tick()
			ActiveEvent.ActiveFor++
			sleep(10)
		ActiveEvent.Die()
		del ActiveEvent
