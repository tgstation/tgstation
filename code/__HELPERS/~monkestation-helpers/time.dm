/// Generate a game-world time value in deciseconds.
/proc/station_time(reference_time = world.time)
	return ((((reference_time - SSticker.round_start_time) * SSticker.station_time_rate_multiplier) + SSticker.gametime_offset) % (24 HOURS))

/proc/stationtime2text(format = "hh:mm:ss", reference_time = world.time)
	return time2text(station_time(reference_time), format, 0)

/proc/stationdate2text()
	var/static/next_station_date_change = 1 DAY
	var/static/station_date = ""
	var/update_time = FALSE
	if(STATION_TIME_TICKS > next_station_date_change)
		next_station_date_change += 1 DAY
		update_time = TRUE
	if(!station_date || update_time)
		var/extra_days = round(STATION_TIME_TICKS / (1 DAY)) DAYS
		var/timeofday = world.timeofday + extra_days
		station_date = time2text(timeofday, "DD-MM") + "-" + num2text(CURRENT_STATION_YEAR)
	return station_date
