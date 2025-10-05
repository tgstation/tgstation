#define RANDOM_EVENT_ADMIN_INTERVENTION_TIME (10 SECONDS)

//this singleton datum is used by the events controller to dictate how it selects events
/datum/round_event_control
	var/name //The human-readable name of the event
	var/category //The category of the event
	var/description //The description of the event
	var/typepath //The typepath of the event datum /datum/round_event

	var/weight = 10 //The weight this event has in the random-selection process.
									//Higher weights are more likely to be picked.
									//10 is the default weight. 20 is twice more likely; 5 is half as likely as this default.
									//0 here does NOT disable the event, it just makes it extremely unlikely

	var/earliest_start = 20 MINUTES //The earliest world.time that an event can start (round-duration in deciseconds) default: 20 mins
	var/min_players = 0 //The minimum amount of alive, non-AFK human players on server required to start the event.

	var/occurrences = 0 //How many times this event has occurred
	var/max_occurrences = 20 //The maximum number of times this event can occur (naturally), it can still be forced.
									//By setting this to 0 you can effectively disable an event.

	var/holidayID = "" //string which should be in the SSeventss.holidays list if you wish this event to be holiday-specific
									//anything with a (non-null) holidayID which does not match holiday, cannot run.
	var/wizardevent = FALSE
	var/alert_observers = TRUE //should we let the ghosts know this event is firing
									//should be disabled on events that fire a lot

	/// Minimum wizard rituals at which to trigger this event, inclusive
	var/min_wizard_trigger_potency = NEVER_TRIGGERED_BY_WIZARDS
	/// Maximum wizard rituals at which to trigger this event, inclusive
	var/max_wizard_trigger_potency = NEVER_TRIGGERED_BY_WIZARDS

	var/triggering //admin cancellation

	/// Datum that will handle admin options for forcing the event.
	/// If there are no options, just leave it as an empty list.
	var/list/datum/event_admin_setup/admin_setup = list()
	/// Flags dictating whether this event should be run on certain kinds of map
	var/map_flags = NONE

/datum/round_event_control/New()
	if(!length(admin_setup))
		return
	var/list/admin_setup_types = admin_setup.Copy()
	admin_setup.Cut()
	for(var/admin_setup_type in admin_setup_types)
		admin_setup += new admin_setup_type(src)

/datum/round_event_control/wizard
	category = EVENT_CATEGORY_WIZARD
	wizardevent = TRUE

/// Returns true if event can run in current map
/datum/round_event_control/proc/valid_for_map()
	if (!map_flags)
		return TRUE
	if (SSmapping.is_planetary())
		if (map_flags & EVENT_SPACE_ONLY)
			return FALSE
	else
		if (map_flags & EVENT_PLANETARY_ONLY)
			return FALSE
	return TRUE

// Checks if the event can be spawned. Used by event controller and "false alarm" event.
// Admin-created events override this.
/datum/round_event_control/proc/can_spawn_event(players_amt, allow_magic = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	if(occurrences >= max_occurrences)
		return FALSE
	if(earliest_start >= world.time-SSticker.round_start_time)
		return FALSE
	if(!allow_magic && wizardevent != SSevents.wizardmode)
		return FALSE
	if(players_amt < min_players)
		return FALSE
	if(holidayID && !check_holidays(holidayID))
		return FALSE
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		return FALSE
	if(ispath(typepath, /datum/round_event/ghost_role) && !(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
		return FALSE

	return TRUE

/datum/round_event_control/proc/preRunEvent()
	if(!ispath(typepath, /datum/round_event))
		return EVENT_CANT_RUN

	if (SEND_GLOBAL_SIGNAL(COMSIG_GLOB_PRE_RANDOM_EVENT, src) & CANCEL_PRE_RANDOM_EVENT)
		return EVENT_INTERRUPTED

	triggering = TRUE

	// We sleep HERE, in pre-event setup (because there's no sense doing it in run_event() since the event is already running!) for the given amount of time to make an admin has enough time to cancel an event un-fitting of the present round or at least reroll it.
	message_admins("Random Event triggering in [DisplayTimeText(RANDOM_EVENT_ADMIN_INTERVENTION_TIME)]: [name]. (<a href='byond://?src=[REF(src)];cancel=1'>CANCEL</a>) (<a href='byond://?src=[REF(src)];different_event=1'>SOMETHING ELSE</a>)")
	sleep(RANDOM_EVENT_ADMIN_INTERVENTION_TIME)
	var/players_amt = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	if(!can_spawn_event(players_amt))
		message_admins("Second pre-condition check for [name] failed, rerolling...")
		SSevents.spawnEvent(excluded_event = src)
		return EVENT_INTERRUPTED

	if(!triggering)
		return EVENT_CANCELLED //admin cancelled
	triggering = FALSE
	return EVENT_READY

/datum/round_event_control/Topic(href, href_list)
	..()
	if(href_list["cancel"])
		if(!triggering)
			to_chat(usr, span_admin("You are too late to cancel that event"))
			return
		triggering = FALSE
		message_admins("[key_name_admin(usr)] cancelled event [name].")
		log_admin_private("[key_name(usr)] cancelled event [name].")
		SSblackbox.record_feedback("tally", "event_admin_cancelled", 1, typepath)
	if(href_list["different_event"])
		if(!triggering)
			to_chat(usr, span_admin("Too late to change events now!"))
			return
		triggering = FALSE
		message_admins("[key_name_admin(usr)] chose to have event [name] rolled into a different event.")
		log_admin_private("[key_name(usr)] rerolled event [name].")
		SSblackbox.record_feedback("tally", "event_admin_rerolled", 1, typepath)
		SSevents.spawnEvent(excluded_event = src)

/*
Runs the event
* Arguments:
* - random: shows if the event was triggered randomly, or by on purpose by an admin or an item
* - announce_chance_override: if the value is not null, overrides the announcement chance when an admin calls an event
*/
/datum/round_event_control/proc/run_event(random = FALSE, announce_chance_override = null, admin_forced = FALSE, event_cause)
	/*
	* We clear our signals first so we don't cancel a wanted event by accident,
	* the majority of time the admin will probably want to cancel a single midround spawned random events
	* and not multiple events called by others admins
	* * In the worst case scenario we can still recall a event which we cancelled by accident, which is much better then to have a unwanted event
	*/
	UnregisterSignal(SSdcs, COMSIG_GLOB_RANDOM_EVENT)
	var/datum/round_event/round_event = new typepath(TRUE, src)
	if(admin_forced && length(admin_setup))
		//not part of the signal because it's conditional and relies on usr heavily
		for(var/datum/event_admin_setup/admin_setup_datum in admin_setup)
			admin_setup_datum.apply_to_event(round_event)
	SEND_SIGNAL(src, COMSIG_CREATED_ROUND_EVENT, round_event)
	round_event.setup()
	round_event.current_players = get_active_player_count(alive_check = 1, afk_check = 1, human_check = 1)
	occurrences++

	if(announce_chance_override != null)
		round_event.announce_chance = announce_chance_override

	testing("[time2text(world.time, "hh:mm:ss", 0)] [round_event.type]")
	triggering = TRUE

	if(!triggering)
		RegisterSignal(SSdcs, COMSIG_GLOB_RANDOM_EVENT, PROC_REF(stop_random_event))
		round_event.cancel_event = TRUE
		return round_event

	triggering = FALSE
	log_game("[random ? "Random" : "Forced"] Event triggering: [name] ([typepath]).")

	if(alert_observers)
		round_event.announce_deadchat(random, event_cause)

	SSblackbox.record_feedback("tally", "event_ran", 1, "[round_event]")
	return round_event

//Returns the component for the listener
/datum/round_event_control/proc/stop_random_event()
	SIGNAL_HANDLER
	return CANCEL_RANDOM_EVENT

/datum/round_event //NOTE: Times are measured in master controller ticks!
	var/processing = TRUE
	var/datum/round_event_control/control

	/// When in the lifetime to call start().
	/// This is in seconds - so 1 = ~2 seconds in.
	var/start_when = 0
	/// When in the lifetime to call announce(). If you don't want it to announce use announce_chance, below.
	/// This is in seconds - so 1 = ~2 seconds in.
	var/announce_when = 0
	/// Probability of announcing, used in prob(), 0 to 100, default 100. Called in process, and for a second time in the ion storm event.
	var/announce_chance = 100
	/// When in the lifetime the event should end.
	/// This is in seconds - so 1 = ~2 seconds in.
	var/end_when = 0

	/// How long the event has existed. You don't need to change this.
	var/activeFor = 0
	/// Amount of of alive, non-AFK human players on server at the time of event start
	var/current_players = 0
	/// Can be faked by fake news event.
	var/fakeable = TRUE
	/// Whether a admin wants this event to be cancelled
	var/cancel_event = FALSE

//Called first before processing.
//Allows you to setup your event, such as randomly
//setting the start_when and or announce_when variables.
//Only called once.
//EDIT: if there's anything you want to override within the new() call, it will not be overridden by the time this proc is called.
//It will only have been overridden by the time we get to announce() start() tick() or end() (anything but setup basically).
//This is really only for setting defaults which can be overridden later when New() finishes.
/datum/round_event/proc/setup()
	SHOULD_CALL_PARENT(FALSE)
	return

///Announces the event name to deadchat, override this if what an event should show to deadchat is different to its event name.
/datum/round_event/proc/announce_deadchat(random, cause)
	deadchat_broadcast(" has just been[random ? " randomly" : ""] triggered[cause ? " by [cause]" : ""]!", "<b>[control.name]</b>", message_type=DEADCHAT_ANNOUNCEMENT) //STOP ASSUMING IT'S BADMINS!

//Called when the tick is equal to the start_when variable.
//Allows you to start before announcing or vice versa.
//Only called once.
/datum/round_event/proc/start()
	SHOULD_CALL_PARENT(FALSE)
	return

//Called after something followable has been spawned by an event
//Provides ghosts a follow link to an atom if possible
//Only called once.
/datum/round_event/proc/announce_to_ghosts(atom/atom_of_interest)
	if(control.alert_observers)
		if (atom_of_interest)
			notify_ghosts(
				"[control.name] has an object of interest: [atom_of_interest]!",
				source = atom_of_interest,
			)
	return

//Called when the tick is equal to the announce_when variable.
//Allows you to announce before starting or vice versa.
//Only called once.
/datum/round_event/proc/announce(fake)
	return

//Called on or after the tick counter is equal to start_when.
//You can include code related to your event or add your own
//time stamped events.
//Called more than once.
/datum/round_event/proc/tick()
	return

//Called on or after the tick is equal or more than end_when
//You can include code related to the event ending.
//Do not place spawn() in here, instead use tick() to check for
//the activeFor variable.
//For example: if(activeFor == myOwnVariable + 30) doStuff()
//Only called once.
/datum/round_event/proc/end()
	return



//Do not override this proc, instead use the appropriate procs.
//This proc will handle the calls to the appropriate procs.
/datum/round_event/process()
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!processing)
		return

	if(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_RANDOM_EVENT, src) & CANCEL_RANDOM_EVENT)
		processing = FALSE
		kill()
		return

	if(activeFor == start_when)
		processing = FALSE
		start()
		processing = TRUE

	if(activeFor == announce_when && prob(announce_chance))
		processing = FALSE
		announce(FALSE)
		processing = TRUE

	if(start_when < activeFor && activeFor < end_when)
		processing = FALSE
		tick()
		processing = TRUE

	if(activeFor == end_when)
		processing = FALSE
		end()
		processing = TRUE

	// Everything is done, let's clean up.
	if(activeFor >= end_when && activeFor >= announce_when && activeFor >= start_when)
		processing = FALSE
		kill()

	activeFor++


//Garbage collects the event by removing it from the global events list,
//which should be the only place it's referenced.
//Called when start(), announce() and end() has all been called.
/datum/round_event/proc/kill()
	SSevents.running -= src


//Sets up the event then adds the event to the the list of running events
/datum/round_event/New(my_processing = TRUE, datum/round_event_control/event_controller)
	control = event_controller
	processing = my_processing
	SSevents.running += src
	return ..()

#undef RANDOM_EVENT_ADMIN_INTERVENTION_TIME
