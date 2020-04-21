#define MIN_TICKLAG 0.4 //min value ticklag can be
#define OVERLOADED_WORLD_TICKLAG 0.8 //max value ticklag can be
#define TICKLAG_DILATION_INC 0.2 //how much to increase by when appropriate
#define TICKLAG_DILATION_DEC 0.2 //how much to decrease by when appropriate //MBCX I DONT KNOW WHY BUT MOST VALUES CAUSE ROUNDING ERRORS, ITS VERY IMPORTANT THAT THIS REMAINS 0.2 FIOR NOW
#define TICKLAG_DILATION_THRESHOLD 6
#define TICKLAG_NORMALIZATION_THRESHOLD 0.8

SUBSYSTEM_DEF(time_track)
	name = "Time Tracking"
	wait = 20
	flags = SS_NO_INIT|SS_NO_TICK_CHECK
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/time_dilation_current = 0

	var/time_dilation_avg_fast = 0
	var/time_dilation_avg = 0
	var/time_dilation_avg_slow = 0

	var/first_run = TRUE

	var/last_tick_realtime = 0
	var/last_tick_byond_time = 0
	var/last_tick_tickcount = 0
	var/current_tick_lag = MIN_TICKLAG

/datum/controller/subsystem/time_track/fire()

	var/current_realtime = REALTIMEOFDAY
	var/current_byondtime = world.time
	var/current_tickcount = world.time/world.tick_lag

	if (!first_run)
		var/tick_drift = max(0, (((current_realtime - last_tick_realtime) - (current_byondtime - last_tick_byond_time)) / world.tick_lag))
		time_dilation_current = tick_drift / (current_tickcount - last_tick_tickcount) * 100

		time_dilation_avg_fast = MC_AVERAGE_FAST(time_dilation_avg_fast, time_dilation_current)
		time_dilation_avg = MC_AVERAGE(time_dilation_avg, time_dilation_avg_fast)
		time_dilation_avg_slow = MC_AVERAGE_SLOW(time_dilation_avg_slow, time_dilation_avg)
		// Time Dilation tick_lag adjustment code, credit to MyBlueCorners and the rest of the goonstation dev team!
		var/last_interval_tick_offset = max(0, (current_realtime - last_tick_realtime) - (current_byondtime - last_tick_byond_time))

		var/dilated_tick_lag = world.tick_lag
		if(last_interval_tick_offset >= TICKLAG_DILATION_THRESHOLD)
			dilated_tick_lag = min(world.tick_lag + TICKLAG_DILATION_INC, OVERLOADED_WORLD_TICKLAG)
		else if(last_interval_tick_offset <= TICKLAG_NORMALIZATION_THRESHOLD)
			dilated_tick_lag = max(world.tick_lag - TICKLAG_DILATION_DEC, MIN_TICKLAG)

		if(world.tick_lag != dilated_tick_lag)
			world.change_tick_lag(dilated_tick_lag)
		current_tick_lag = world.tick_lag
	else
		first_run = FALSE
	last_tick_realtime = current_realtime
	last_tick_byond_time = current_byondtime
	last_tick_tickcount = current_tickcount
	SSblackbox.record_feedback("associative", "time_dilation_current", 1, list("[SQLtime()]" = list("current" = "[time_dilation_current]", "avg_fast" = "[time_dilation_avg_fast]", "avg" = "[time_dilation_avg]", "avg_slow" = "[time_dilation_avg_slow]")))
