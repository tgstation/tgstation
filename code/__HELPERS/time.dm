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


///Returns the current week of the current month, from 1 to 5.
/proc/week_of_the_month()
	var/day = time2text(world.timeofday, "DDD") 	// get the current day
	var/date = text2num(time2text(world.timeofday, "DD")) 	// get the current date

	switch(day)
		if(MONDAY)
			date -= 1
		if(TUESDAY)
			date -= 2
		if(WEDNESDAY)
			date -= 3
		if(THURSDAY)
			date -= 4
		if(FRIDAY)
			date -= 5
		if(SATURDAY)
			date -= 6
		if(SUNDAY)
			date -= 7

	return CEILING(date / 7, 1) + 1


///Returns the first day of the current month in number format, from 1 (monday) - 7 (sunday).
/proc/first_day_of_month()
	var/year = text2num(time2text(world.timeofday, "YY"))
	var/month = text2num(time2text(world.timeofday, "MM"))

	var/day = (1 + (((13 * month) + (13 * 1)) / 5) + (year) + (year/4) + (20/4) + (5 * 20)) % 7 //Zeller's congruence

	switch(day) //convert to 1-7 monday first format
		if(0)
			day = 6
		if(1)
			day = 7
		if(2)
			day = 1
		if(3)
			day = 2
		if(4)
			day = 3
		if(5)
			day = 4
		if(6)
			day = 5
	return day


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
