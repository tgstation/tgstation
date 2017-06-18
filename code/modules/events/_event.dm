//this datum is used by the events controller to dictate how it selects events
/datum/round_event_control
	var/name					//The human-readable name of the event
	var/typepath				//The typepath of the event datum /datum/round_event

	var/weight = 10				//The weight this event has in the random-selection process.
								//Higher weights are more likely to be picked.
								//10 is the default weight. 20 is twice more likely; 5 is half as likely as this default.
								//0 here does NOT disable the event, it just makes it extremely unlikely

	var/earliest_start = 12000	//The earliest world.time that an event can start (round-duration in deciseconds) default: 20 mins
	var/min_players = 0			//The minimum amount of alive, non-AFK human players on server required to start the event.

	var/occurrences = 0			//How many times this event has occured
	var/max_occurrences = 20	//The maximum number of times this event can occur (naturally), it can still be forced.
								//By setting this to 0 you can effectively disable an event.

	var/holidayID = ""			//string which should be in the SSeventss.holidays list if you wish this event to be holiday-specific
								//anything with a (non-null) holidayID which does not match holiday, cannot run.
	var/wizardevent = 0

	var/alertadmins = 1			//should we let the admins know this event is firing
								//should be disabled on events that fire a lot

	var/list/gamemode_blacklist = list() // Event won't happen in these gamemodes
	var/list/gamemode_whitelist = list() // Event will happen ONLY in these gamemodes if not empty

	var/triggering	//admin cancellation

/datum/round_event_control/New()
	..()
	if(config && !wizardevent) // Magic is unaffected by configs
		earliest_start = Ceiling(earliest_start * config.events_min_time_mul)
		min_players = Ceiling(min_players * config.events_min_players_mul)

/datum/round_event_control/wizard
	wizardevent = 1

// Checks if the event can be spawned. Used by event controller and "false alarm" event.
// Admin-created events override this.
/datum/round_event_control/proc/canSpawnEvent(var/players_amt, var/gamemode)
	if(occurrences >= max_occurrences)
		return FALSE
	if(earliest_start >= world.time)
		return FALSE
	if(wizardevent != SSevents.wizardmode)
		return FALSE
	if(players_amt < min_players)
		return FALSE
	if(gamemode_blacklist.len && (gamemode in gamemode_blacklist))
		return FALSE
	if(gamemode_whitelist.len && !(gamemode in gamemode_whitelist))
		return FALSE
	if(holidayID && (!SSevents.holidays || !SSevents.holidays[holidayID]))
		return FALSE
	return TRUE

/datum/round_event_control/proc/preRunEvent()
	if(!ispath(typepath,/datum/round_event))
		return EVENT_CANT_RUN

	triggering = TRUE
	if (alertadmins)
		message_admins("Random Event triggering in 10 seconds: [name] ([typepath]) (<a href='?src=\ref[src];cancel=1'>CANCEL</a>)")
		sleep(100)
		if(!canSpawnEvent())
			message_admins("Second pre-condition check for [name] failed, skipping...")
			return EVENT_INTERRUPTED

	if(!triggering)
		return EVENT_CANCELLED	//admin cancelled
	triggering = FALSE
	return EVENT_READY

/datum/round_event_control/Topic(href, href_list)
	..()
	if(href_list["cancel"])
		if(!triggering)
			to_chat(usr, "<span class='admin'>You are too late to cancel that event</span>")
			return
		triggering = FALSE
		message_admins("[key_name_admin(usr)] cancelled event [name].")
		log_admin_private("[key_name(usr)] cancelled event [name].")
		SSblackbox.add_details("event_admin_cancelled","[typepath]")

/datum/round_event_control/proc/runEvent(random)
	var/datum/round_event/E = new typepath()
	E.current_players = get_active_player_count(alive_check = 1, afk_check = 1, human_check = 1)
	E.control = src
	SSblackbox.add_details("event_ran","[E]")
	occurrences++

	testing("[time2text(world.time, "hh:mm:ss")] [E.type]")
	if(random)
		if(alertadmins)
			deadchat_broadcast("<span class='deadsay'><b>[name]</b> has just been randomly triggered!</span>") //STOP ASSUMING IT'S BADMINS!
		log_game("Random Event triggering: [name] ([typepath])")

	return E

/datum/round_event	//NOTE: Times are measured in master controller ticks!
	var/processing = TRUE
	var/datum/round_event_control/control

	var/startWhen		= 0	//When in the lifetime to call start().
	var/announceWhen	= 0	//When in the lifetime to call announce(). Set an event's announceWhen to >0 if there is an announcement.
	var/endWhen			= 0	//When in the lifetime the event should end.

	var/activeFor		= 0	//How long the event has existed. You don't need to change this.
	var/current_players	= 0 //Amount of of alive, non-AFK human players on server at the time of event start

//Called first before processing.
//Allows you to setup your event, such as randomly
//setting the startWhen and or announceWhen variables.
//Only called once.
//EDIT: if there's anything you want to override within the new() call, it will not be overridden by the time this proc is called.
//It will only have been overridden by the time we get to announce() start() tick() or end() (anything but setup basically).
//This is really only for setting defaults which can be overridden later when New() finishes.
/datum/round_event/proc/setup()
	return

//Called when the tick is equal to the startWhen variable.
//Allows you to start before announcing or vice versa.
//Only called once.
/datum/round_event/proc/start()
	return

//Called when the tick is equal to the announceWhen variable.
//Allows you to announce before starting or vice versa.
//Only called once.
/datum/round_event/proc/announce()
	return

//Called on or after the tick counter is equal to startWhen.
//You can include code related to your event or add your own
//time stamped events.
//Called more than once.
/datum/round_event/proc/tick()
	return

//Called on or after the tick is equal or more than endWhen
//You can include code related to the event ending.
//Do not place spawn() in here, instead use tick() to check for
//the activeFor variable.
//For example: if(activeFor == myOwnVariable + 30) doStuff()
//Only called once.
/datum/round_event/proc/end()
	return



//Do not override this proc, instead use the appropiate procs.
//This proc will handle the calls to the appropiate procs.
/datum/round_event/process()
	if(!processing)
		return

	if(activeFor == startWhen)
		start()

	if(activeFor == announceWhen)
		announce()

	if(startWhen < activeFor && activeFor < endWhen)
		tick()

	if(activeFor == endWhen)
		end()

	// Everything is done, let's clean up.
	if(activeFor >= endWhen && activeFor >= announceWhen && activeFor >= startWhen)
		kill()

	activeFor++


//Garbage collects the event by removing it from the global events list,
//which should be the only place it's referenced.
//Called when start(), announce() and end() has all been called.
/datum/round_event/proc/kill()
	SSevents.running -= src


//Sets up the event then adds the event to the the list of running events
/datum/round_event/New(my_processing = TRUE)
	setup()
	processing = my_processing
	SSevents.running += src
	return ..()
