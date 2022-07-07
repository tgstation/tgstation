

/**
 * STATION TIMES ARE 24 HR FORMAT
 */

SUBSYSTEM_DEF(day_night)
	name = "Day/Night Cycle"
	wait = 6 SECONDS // Every minute, the clock moves forward 1 minutes
	init_order = INIT_ORDER_DAY_NIGHT
	/// The current hour
	var/current_hour = 0
	/// The current minute
	var/current_minute = 0
	/// A list of all currently loaded controllers to be handled
	var/list/cached_controllers = list()
	/// The amount of time we add every tick
	var/tick_time = DAY_NIGHT_SUBSYSTEM_FIRE_INCREMENT
	/// If it is our first time firing, we will update maps accordingly as atoms that have initialised will have overriden luminosity.
	var/first_tick = TRUE

/datum/controller/subsystem/day_night/Initialize(start_timeofday)
	current_hour = rand(0, 23) // We set the starting station time to something random.
	load_day_night_controller()
	return ..()

/datum/controller/subsystem/day_night/fire(resumed)
	tick_tock(tick_time)
	if(first_tick)
		update_controllers(current_hour)
		first_tick = FALSE
/**
 * Our internal ticky tocky time machine that will move time forward by the a set amount.
 * Arguments:
 * * time_to_tick - The amount of time we will be adding to our internal clock
 */
/datum/controller/subsystem/day_night/proc/tick_tock(time_to_tick)
	current_minute += time_to_tick

	if(current_minute >= HOUR_INCREMENT)
		var/time_delta = (current_minute - HOUR_INCREMENT) > 0 ? current_minute - HOUR_INCREMENT : 0
		current_minute = time_delta
		current_hour += 1
		if(current_hour >= MIDNIGHT_RESET)
			current_hour = 0
		update_controllers(current_hour) // dispite the fast run time, we only update every time it reaches an hour

	SEND_SIGNAL(src, COMSIG_DAY_NIGHT_CONTROLLER_TIME_TICK, current_hour, current_minute)

/**
 * Loads the currently chosen day night controller from config, if there is one.
 */
/datum/controller/subsystem/day_night/proc/load_day_night_controller()
	if(!SSmapping.config.day_night_controller)
		return
	var/list/z_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	add_controller(SSmapping.config.day_night_controller, z_levels[LAZYLEN(z_levels)])

/**
 * Adds and loads a controller into the subsystem for processing.
 */
/datum/controller/subsystem/day_night/proc/add_controller(new_controller_type, list/affected_z_list)
	cached_controllers += new new_controller_type(affected_z_list)
	update_controllers(current_hour)

/**
 * Gets the current 24hr time in text format to be displayed on the statpanel.
 *
 * Returns HH:MM
 */
/datum/controller/subsystem/day_night/proc/get_twentyfourhour_timestamp()
	var/hour_entry = current_hour < 10 ? "0[current_hour]" : current_hour
	var/minute_entry = current_minute < 10 ? "0[current_minute]" : current_minute
	return "[hour_entry]:[minute_entry]"

/**
 * Gets the current 12hr time in text format to be displayed on the statpanel.
 *
 * Returns HH:MM PM/AM
 */
/datum/controller/subsystem/day_night/proc/get_twelvehour_timestamp()
	var/am_or_pm = current_hour < 12 ? "AM" : "PM"
	var/hour_entry = current_hour > 12 ? "[current_hour - 12]" : current_hour < 10 ? "0[current_hour]" : current_hour
	var/minute_entry = current_minute < 10 ? "0[current_minute]" : current_minute
	return "[hour_entry]:[minute_entry] [am_or_pm]"

/**
 * Returns the current time, unformatted, as a list, current hour and current minute.
 */
/datum/controller/subsystem/day_night/proc/return_raw_time()
	return list(current_hour, current_minute)

/**
 * Checks if the current hour is within a given timeframe.
 */
/datum/controller/subsystem/day_night/proc/check_timeframe(start_hour, end_hour)
	return ((current_hour >= start_hour) && (current_hour <= end_hour))

/**
 * Checks if the current time is within a given timeframe.
 */
/datum/controller/subsystem/day_night/proc/check_specific_timeframe(list/start_time, list/end_time)
	if(current_hour > start_time[1] && current_hour < end_time[1])
		return TRUE
	if(current_hour == start_time[1] && current_minute >= start_time[2])
		return TRUE
	if(current_hour == end_time[1] && current_minute <= end_time[2])
		return TRUE
	return FALSE


/**
 * Checks if a Z level has a corresponding day night controller.
 *
 * Returns the controller if it does.
 */
/datum/controller/subsystem/day_night/proc/get_controller(z_level)
	for(var/datum/day_night_controller/iterating_controller in cached_controllers)
		if(iterating_controller.affected_z_level == z_level)
			return iterating_controller

/**
 * Updates all cached controllers to the new hour.
 * Arguments:
 * * hour - The updating hour which we will sent to the controller controllers
 */
/datum/controller/subsystem/day_night/proc/update_controllers(hour)
	for(var/datum/day_night_controller/iterating_controller as anything in cached_controllers)
		iterating_controller.update_time(hour)
