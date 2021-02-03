//Returns the world time in english
/proc/worldtime2text()
	return gameTimestamp("hh:mm:ss", world.time)

/proc/time_stamp(format = "hh:mm:ss", show_ds)
	var/time_string = time2text(world.timeofday, format)
	return show_ds ? "[time_string]:[world.timeofday % 10]" : time_string

/proc/gameTimestamp(format = "hh:mm:ss", wtime=null)
	if(!wtime)
		wtime = world.time
	return time2text(wtime - GLOB.timezoneOffset, format)

/proc/station_time(display_only = FALSE, wtime=world.time)
	return ((((wtime - SSticker.round_start_time) * SSticker.station_time_rate_multiplier) + SSticker.gametime_offset) % 864000) - (display_only? GLOB.timezoneOffset : 0)

/proc/station_time_timestamp(format = "hh:mm:ss", wtime)
	return time2text(station_time(TRUE, wtime), format)

/proc/station_time_debug(force_set)
	if(isnum(force_set))
		SSticker.gametime_offset = force_set
		return
	SSticker.gametime_offset = rand(0, 864000)		//hours in day * minutes in hour * seconds in minute * deciseconds in second
	if(prob(50))
		SSticker.gametime_offset = FLOOR(SSticker.gametime_offset, 3600)
	else
		SSticker.gametime_offset = CEILING(SSticker.gametime_offset, 3600)

//returns timestamp in a sql and a not-quite-compliant ISO 8601 friendly format
/proc/SQLtime(timevar)
	return time2text(timevar || world.timeofday, "YYYY-MM-DD hh:mm:ss")


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

///Returns the first day of the given year and month in number format, from 1 (monday) - 7 (sunday).
/proc/first_day_of_month(year, month)
	// https://en.wikipedia.org/wiki/Zeller%27s_congruence
	var/m = month < 3 ? month + 12 : month // month (march = 3, april = 4...february = 14)
	var/K = year % 100 // year of century
	var/J = round(year / 100) // zero-based century
	// day 0-6 saturday to sunday:
	var/h = (1 + round(13 * (m + 1) / 5) + K + round(K / 4) + round(J / 4) - 2 * J) % 7
	//convert to ISO 1-7 monday first format
	return ((h + 5) % 7) + 1


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
