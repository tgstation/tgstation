// So you can be all 10 SECONDS
#define SECONDS * 10
#define MINUTES * 600
#define HOURS   * 36000

#define TimeOfGame (get_game_time())
#define TimeOfTick (world.tick_usage*0.01*world.tick_lag)

/proc/get_game_time()
	var/global/time_offset = 0
	var/global/last_time = 0
	var/global/last_usage = 0

	var/wtime = world.time
	var/wusage = world.tick_usage * 0.01

	if(last_time < wtime && last_usage > 1)
		time_offset += last_usage - 1

	last_time = wtime
	last_usage = wusage

	return wtime + (time_offset + wusage) * world.tick_lag

//Returns the world time in english
/proc/worldtime2text(timestamp = world.time)
	return "[(round(timestamp / 36000) + 12) % 24]:[(timestamp / 600 % 60) < 10 ? add_zero(timestamp / 600 % 60, 1) : timestamp / 600 % 60]"


/proc/formatTimeDuration(var/deciseconds)
	var/m = round(deciseconds / 600)
	var/s = (deciseconds % 600)/10
	var/h = round(m / 60)
	m = m % 60
	if(h>0)
		. += "[h]:"
	if(h>0 || m > 0)
		. += "[(m<10)?"0":""][m]:"
	. += "[(s<10)?"0":""][s]"

/proc/altFormatTimeDuration(var/deciseconds)
	var/m = round(deciseconds / 600)
	var/s = (deciseconds % 600)/10
	var/h = round(m / 60)
	m = m % 60
	if(h > 0)
		. += "[h]h "
	if(m > 0)
		. += "[m]m "
	. += "[s]s"

/proc/time_stamp()
	return time2text(world.timeofday, "hh:mm:ss")

/* Preserving this so future generations can see how fucking retarded some people are
/proc/time_stamp()
	var/hh = text2num(time2text(world.timeofday, "hh")) // Set the hour
	var/mm = text2num(time2text(world.timeofday, "mm")) // Set the minute
	var/ss = text2num(time2text(world.timeofday, "ss")) // Set the second
	var/ph
	var/pm
	var/ps
	if(hh < 10) ph = "0"
	if(mm < 10) pm = "0"
	if(ss < 10) ps = "0"
	return"[ph][hh]:[pm][mm]:[ps][ss]"
*/

/* Returns 1 if it is the selected month and day */
/proc/isDay(var/month, var/day)
	if(isnum(month) && isnum(day))
		var/MM = text2num(time2text(world.timeofday, "MM")) // get the current month
		var/DD = text2num(time2text(world.timeofday, "DD")) // get the current day
		if(month == MM && day == DD)
			return 1

		// Uncomment this out when debugging!
		//else
			//return 1

/**
 * Returns "watch handle" (really just a timestamp :V)
 */
/proc/start_watch()
	return TimeOfGame

/**
 * Returns number of seconds elapsed.
 * @param wh number The "Watch Handle" from start_watch(). (timestamp)
 */
/proc/stop_watch(wh)
	return round(0.1 * ( TimeOfGame - wh), 0.1)

//returns timestamp in a sql and ISO 8601 friendly format
/proc/SQLtime()
	return time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")