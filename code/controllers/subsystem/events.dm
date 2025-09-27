SUBSYSTEM_DEF(events)
	name = "Events"
	dependencies = list(
		/datum/controller/subsystem/processing/station,
	)
	runlevels = RUNLEVEL_GAME
	///list of all datum/round_event_control. Used for selecting events based on weight and occurrences.
	var/list/control = list()
	///assoc list of all datum/round_event_control, ordered by name. name => event
	var/list/events_by_name = list()
	///list of all existing /datum/round_event currently being run.
	var/list/running = list()
	///cache of currently running events, for lag checking.
	var/list/currentrun = list()
	///The next world.time that a naturally occurring random event can be selected.
	var/scheduled = 0
	///The lower bound for how soon another random event can be scheduled.
	var/frequency_lower = 2.5 MINUTES
	///The upper bound for how soon another random event can be scheduled.
	var/frequency_upper = 7 MINUTES
	///Will wizard events be included in the event pool?
	var/wizardmode = FALSE

/datum/controller/subsystem/events/Initialize()
	for(var/type in typesof(/datum/round_event_control))
		var/datum/round_event_control/event = new type()
		if(!event.typepath || !event.valid_for_map())
			continue //don't want this one! leave it for the garbage collector
		control += event //add it to the list of all events (controls)
		events_by_name[event.name] = event

	frequency_lower = CONFIG_GET(number/events_frequency_lower)
	frequency_upper = CONFIG_GET(number/events_frequency_upper)

	if(CONFIG_GET(flag/events_config_enabled))
		setup_config()

	reschedule()
	// Instantiate our holidays list if it hasn't been already
	if(isnull(GLOB.holidays))
		fill_holidays()
	return SS_INIT_SUCCESS

///Takes the events config json and applies any var edits made there to their respective event.
/datum/controller/subsystem/events/proc/setup_config()
	var/json_file = file("[global.config.directory]/events.json")
	if(!fexists(json_file))
		return
	var/list/configuration = json_decode(file2text(json_file))
	for(var/variable in configuration)
		var/datum/round_event_control/event = events_by_name[variable]
		if(!event)
			stack_trace("Invalid event [event] attempting to be configured.")
			continue
		for(var/event_variable in configuration[variable])
			if(!(event.vars.Find(event_variable)))
				stack_trace("Invalid event configuration variable [event_variable] in variable changes for [variable].")
				continue
			event.vars[event_variable] = configuration[variable][event_variable]

/datum/controller/subsystem/events/fire(resumed = FALSE)
	if(!resumed)
		checkEvent() //only check these if we aren't resuming a paused fire
		src.currentrun = running.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.process(wait * 0.1)
		else
			running.Remove(thing)
		if (MC_TICK_CHECK)
			return

//checks if we should select a random event yet, and reschedules if necessary
/datum/controller/subsystem/events/proc/checkEvent()
	if(scheduled <= world.time)
#ifdef MAP_TEST
		message_admins("Random event skipped (Game is compiled in MAP_TEST mode)")
#else
		spawnEvent()
#endif
		reschedule()

//decides which world.time we should select another random event at.
/datum/controller/subsystem/events/proc/reschedule()
	scheduled = world.time + rand(frequency_lower, max(frequency_lower,frequency_upper))

/**
 * Selects a random event based on whether it can occur and its 'weight'(probability)
 *
 * Arguments:
 * * excluded_event - The event path we will be foregoing, if present.
 */
/datum/controller/subsystem/events/proc/spawnEvent(datum/round_event_control/excluded_event)
	set waitfor = FALSE //for the admin prompt
	if(!CONFIG_GET(flag/allow_random_events))
		return

	var/players_amt = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	// Only alive, non-AFK human players count towards this.

	var/list/event_roster = list()

	for(var/datum/round_event_control/event_to_check in control)
		if(excluded_event && event_to_check.typepath == excluded_event.typepath) //If an event has been rerolled we won't just roll the same one again.
			continue
		if(!event_to_check.can_spawn_event(players_amt))
			continue
		if(event_to_check.weight < 0) //for round-start events etc.
			var/res = TriggerEvent(event_to_check)
			if(res == EVENT_INTERRUPTED)
				continue //like it never happened
			if(res == EVENT_CANT_RUN)
				return
		else
			event_roster[event_to_check] = event_to_check.weight

	var/datum/round_event_control/event_to_run = pick_weight(event_roster)
	if(event_to_run)
		TriggerEvent(event_to_run)

///Does the last pre-flight checks for the passed event, and runs it if the event is ready.
/datum/controller/subsystem/events/proc/TriggerEvent(datum/round_event_control/event_to_trigger)
	. = event_to_trigger.preRunEvent()
	if(. == EVENT_CANT_RUN)//we couldn't run this event for some reason, set its max_occurrences to 0
		event_to_trigger.max_occurrences = 0
	else if(. == EVENT_READY)
		event_to_trigger.run_event(random = TRUE)

///Toggles whether or not wizard events will be in the event pool, and sends a notification to the admins.
/datum/controller/subsystem/events/proc/toggleWizardmode()
	wizardmode = !wizardmode
	message_admins("Summon Events has been [wizardmode ? "enabled, events will occur every [SSevents.frequency_lower / 600] to [SSevents.frequency_upper / 600] minutes" : "disabled"]!")
	log_game("Summon Events was [wizardmode ? "enabled" : "disabled"]!")

///Sets the event frequency bounds back to their initial value.
/datum/controller/subsystem/events/proc/resetFrequency()
	frequency_lower = CONFIG_GET(number/events_frequency_lower)
	frequency_upper = CONFIG_GET(number/events_frequency_upper)

/**
 * HOLIDAYS
 *
 * Uncommenting ALLOW_HOLIDAYS in config.txt will enable holidays
 *
 * It's easy to add stuff. Just add a holiday datum in code/modules/holiday/holidays.dm
 * You can then check if it's a special day in any code in the game by calling check_holidays("Groundhog Day")
 *
 * You can also make holiday random events easily thanks to Pete/Gia's system.
 * simply make a random event normally, then assign it a holidayID string which matches the holiday's name.
 * Anything with a holidayID, which isn't in the holidays list, will never occur.
 *
 * Please, Don't spam stuff up with stupid stuff (key example being april-fools Pooh/ERP/etc),
 * and don't forget: CHECK YOUR CODE!!!! We don't want any zero-day bugs which happen only on holidays and never get found/fixed!
 */
GLOBAL_LIST(holidays)

/**
 * Checks that the passed holiday is located in the global holidays list.
 *
 * Returns a holiday datum, or null if it's not that holiday.
 */
/proc/check_holidays(holiday_to_find)
	if(!CONFIG_GET(flag/allow_holidays))
		return // Holiday stuff was not enabled in the config!

	if(isnull(GLOB.holidays) && !fill_holidays())
		return // Failed to generate holidays, for some reason

	return GLOB.holidays[holiday_to_find]

/**
 * Fills the holidays list if applicable, or leaves it an empty list.
 */
/proc/fill_holidays()
	if(!CONFIG_GET(flag/allow_holidays))
		return FALSE // Holiday stuff was not enabled in the config!

	GLOB.holidays = list()
	for(var/holiday_type in subtypesof(/datum/holiday))
		var/datum/holiday/holiday = new holiday_type()
		var/delete_holiday = TRUE
		for(var/timezone in holiday.timezones)
			var/time_in_timezone = world.realtime + timezone HOURS

			var/YYYY = text2num(time2text(time_in_timezone, "YYYY", world.timezone)) // get the current year
			var/MM = text2num(time2text(time_in_timezone, "MM", world.timezone)) // get the current month
			var/DD = text2num(time2text(time_in_timezone, "DD", world.timezone)) // get the current day
			var/DDD = time2text(time_in_timezone, "DDD", world.timezone) // get the current weekday

			if(holiday.shouldCelebrate(DD, MM, YYYY, DDD))
				holiday.celebrate()
				GLOB.holidays[holiday.name] = holiday
				delete_holiday = FALSE
				break
		if(delete_holiday)
			qdel(holiday)

	if(GLOB.holidays.len)
		shuffle_inplace(GLOB.holidays)
		// regenerate station name because holiday prefixes.
		set_station_name(new_station_name())
		world.update_status()

	return TRUE
