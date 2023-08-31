//Key thing that stops lag. Cornerstone of performance in ss13, Just sitting here, in unsorted.dm. Now with dedicated file!

///Increases delay as the server gets more overloaded, as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(TICK_USAGE, world.cpu) / 100) * max(Master.sleep_delta-1,1)), 1)

///returns the number of ticks slept
/proc/stoplag(initial_delay)
	if (!Master || Master.init_stage_completed < INITSTAGE_MAX)
		sleep(world.tick_lag)
		return 1
	if (!initial_delay)
		initial_delay = world.tick_lag
// Unit tests are not the normal environemnt. The mc can get absolutely thigh crushed, and sleeping procs running for ages is much more common
// We don't want spurious hard deletes off this, so let's only sleep for the requested period of time here yeah?
#ifdef UNIT_TESTS
	sleep(initial_delay)
	return CEILING(DS2TICKS(initial_delay), 1)
#else
	. = 0
	var/i = DS2TICKS(initial_delay)
	do
		. += CEILING(i * DELTA_CALC, 1)
		sleep(i * world.tick_lag * DELTA_CALC)
		i *= 2
	while (TICK_USAGE > min(TICK_LIMIT_TO_RUN, Master.current_ticklimit))
#endif

#undef DELTA_CALC
