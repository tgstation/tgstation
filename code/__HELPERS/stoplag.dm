
///Increases delay as the server gets more overloaded, as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(TICK_USAGE, world.cpu) / 100) * max(Master.sleep_delta-1,1)), 1)

///try to sleep for at least initial_delay deciseconds, but if the sever is overloaded when it wakes back up it goes back to sleep again for some ticks.
///critical for making code yield more efficiently for performance reasons without implementing a subsystem for it.
///returns the number of ticks slept. if initial_delay isnt given then tries to sleep for 1 tick.
/proc/stoplag(initial_delay)
	if (!Master || !(Master.current_runlevel & RUNLEVELS_DEFAULT))
		Master.stoplag_threads++
		sleep(world.tick_lag)
		Master.stoplag_threads--
		return 1
	if (!initial_delay)
		initial_delay = world.tick_lag
	Master.stoplag_threads++
	. = 0
	var/i = DS2TICKS(initial_delay)
	do
		. += CEILING(i * DELTA_CALC, 1)
		sleep(i * world.tick_lag * DELTA_CALC)
		i *= 2
	while (TICK_USAGE > min(TICK_LIMIT_TO_RUN, Master.current_ticklimit))

	Master.stoplag_threads--

#undef DELTA_CALC

#define UNTIL(X) while(!(X)) stoplag()
