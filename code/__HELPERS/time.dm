/// Returns UTC timestamp with the specifified format and optionally deciseconds
/proc/time_stamp(format = "hh:mm:ss", show_ds)
	var/time_string = time2text(world.timeofday, format, TIMEZONE_UTC)
	return show_ds ? "[time_string]:[world.timeofday % 10]" : time_string

/// Returns timestamp since the server started, for use with world.time
/proc/gameTimestamp(format = "hh:mm:ss", wtime=world.time)
	return time2text(wtime, format, NO_TIMEZONE)

///returns the current IC station time in a world.time format
/proc/station_time(display_only = FALSE, wtime=world.time)
	return ((((wtime - SSticker.round_start_time) * SSticker.station_time_rate_multiplier) + SSticker.gametime_offset) % 864000) - (display_only? GLOB.timezoneOffset : 0)

///returns the current IC station time in a human readable format
/proc/station_time_timestamp(format = "hh:mm:ss", wtime)
	return time2text(station_time(TRUE, wtime), format, NO_TIMEZONE)

/proc/station_time_debug(force_set)
	if(isnum(force_set))
		SSticker.gametime_offset = force_set
		return
	SSticker.gametime_offset = rand(0, 864000) //hours in day * minutes in hour * seconds in minute * deciseconds in second
	if(prob(50))
		SSticker.gametime_offset = FLOOR(SSticker.gametime_offset, 3600)
	else
		SSticker.gametime_offset = CEILING(SSticker.gametime_offset, 3600)

///returns timestamp in a sql and a not-quite-compliant ISO 8601 friendly format. Do not use for SQL, use NOW() instead
/proc/ISOtime(timevar)
	return time2text(timevar || world.timeofday, "YYYY-MM-DD hh:mm:ss", world.timezone)


GLOBAL_VAR_INIT(midnight_rollovers, 0)
GLOBAL_VAR_INIT(rollovercheck_last_timeofday, 0)
/proc/update_midnight_rollover()
	if (world.timeofday < GLOB.rollovercheck_last_timeofday) //TIME IS GOING BACKWARDS!
		GLOB.midnight_rollovers++
	GLOB.rollovercheck_last_timeofday = world.timeofday
	return GLOB.midnight_rollovers


///Returns a string day as an integer in ISO format 1 (Monday) - 7 (Sunday)
/proc/weekday_to_iso(ddd)
	switch (ddd)
		if (MONDAY)
			return 1
		if (TUESDAY)
			return 2
		if (WEDNESDAY)
			return 3
		if (THURSDAY)
			return 4
		if (FRIDAY)
			return 5
		if (SATURDAY)
			return 6
		if (SUNDAY)
			return 7

///Returns an integer in ISO format 1 (Monday) - 7 (Sunday) as a string day
/proc/iso_to_weekday(ddd)
	switch (ddd)
		if (1)
			return MONDAY
		if (2)
			return TUESDAY
		if (3)
			return WEDNESDAY
		if (4)
			return THURSDAY
		if (5)
			return FRIDAY
		if (6)
			return SATURDAY
		if (7)
			return SUNDAY

/// Returns the day (mon, tues, wen...) in number format, 1 (monday) - 7 (sunday) from the passed in date (year, month, day)
/// All inputs are expected indexed at 1
/proc/day_of_month(year, month, day)
	// https://en.wikipedia.org/wiki/Zeller%27s_congruence
	var/m = month < 3 ? month + 12 : month // month (march = 3, april = 4...february = 14)
	var/K = year % 100 // year of century
	var/J = round(year / 100) // zero-based century
	// day 0-6 saturday to friday:
	var/h = (day + round(13 * (m + 1) / 5) + K + round(K / 4) + round(J / 4) - 2 * J) % 7
	//convert to ISO 1-7 monday first format
	return ((h + 5) % 7) + 1

/proc/first_day_of_month(year, month)
	return day_of_month(year, month, 1)

//Takes a value of time in deciseconds.
//Returns a text value of that number in hours, minutes, or seconds.
/proc/DisplayTimeText(time_value, round_seconds_to = 0.1)
	var/second = FLOOR(time_value * 0.1, round_seconds_to)
	if(!second)
		return "right now"
	if(second < 60)
		return "[second] second[(second != 1)? "s":""]"
	var/minute = FLOOR(second / 60, 1)
	second = FLOOR(MODULUS(second, 60), round_seconds_to)
	var/secondT
	if(second)
		secondT = " and [second] second[(second != 1)? "s":""]"
	if(minute < 60)
		return "[minute] minute[(minute != 1)? "s":""][secondT]"
	var/hour = FLOOR(minute / 60, 1)
	minute = MODULUS(minute, 60)
	var/minuteT
	if(minute)
		minuteT = " and [minute] minute[(minute != 1)? "s":""]"
	if(hour < 24)
		return "[hour] hour[(hour != 1)? "s":""][minuteT][secondT]"
	var/day = FLOOR(hour / 24, 1)
	hour = MODULUS(hour, 24)
	var/hourT
	if(hour)
		hourT = " and [hour] hour[(hour != 1)? "s":""]"
	return "[day] day[(day != 1)? "s":""][hourT][minuteT][secondT]"


/proc/daysSince(realtimev)
	return round((world.realtime - realtimev) / (24 HOURS))

/**
 * Converts a time expressed in deciseconds (like world.time) to the 12-hour time format.
 * the format arg is the format passed down to time2text() (e.g. "hh:mm" is hours and minutes but not seconds).
 * the timezone is the time value offset from the local time. It's to be applied outside time2text() to get the AM/PM right.
 */
/proc/time_to_twelve_hour(time, format = "hh:mm:ss", timezone = TIMEZONE_UTC)
	time = MODULUS(time + (timezone - GLOB.timezoneOffset) HOURS, 24 HOURS)
	var/am_pm = "AM"
	if(time > 12 HOURS)
		am_pm = "PM"
		if(time > 13 HOURS)
			time -= 12 HOURS // e.g. 4:16 PM but not 00:42 PM
	else if (time < 1 HOURS)
		time += 12 HOURS // e.g. 12.23 AM
	return "[time2text(time, format)] [am_pm]"
